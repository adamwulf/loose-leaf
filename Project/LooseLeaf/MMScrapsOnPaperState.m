//
//  MMScrapsOnPaperState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapsOnPaperState.h"
#import "MMScrapView.h"
#import "MMScrapViewState.h"
#import "MMImmutableScrapsOnPaperState.h"
#import "MMScrapContainerView.h"
#import "NSThread+BlockAdditions.h"
#import "UIView+Debug.h"
#import "Constants.h"
#import "MMPageCacheManager.h"
#import "MMScrapsInBezelContainerView.h"
#import "MMTrashManager.h"
#import "Mixpanel.h"


@interface MMImmutableScrapsOnPaperState (Private)

- (NSUInteger)undoHash;

@end

/**
 * similar to the MMPaperState, this object will
 * track the state for all scraps within a single page
 */
@implementation MMScrapsOnPaperState {
    // the container to hold the scraps
    MMScrapContainerView* scrapContainerView;
    NSMutableArray* scrapsPendingRemoval;
}

@dynamic delegate;
@synthesize scrapContainerView;

- (id)initWithDelegate:(NSObject<MMScrapsOnPaperStateDelegate>*)_delegate withScrapContainerSize:(CGSize)scrapContainerSize {
    if (self = [super init]) {
        delegate = _delegate;
        scrapContainerView = [[MMScrapContainerView alloc] initWithFrame:CGRectMake(0, 0, scrapContainerSize.width, scrapContainerSize.height)
                                                   forScrapsOnPaperState:self];
        // anchor the view to the top left,
        // so that when we scale down, the drawable view
        // stays in place
        scrapContainerView.layer.anchorPoint = CGPointMake(0, 0);
        scrapContainerView.layer.position = CGPointMake(0, 0);
        scrapsPendingRemoval = [NSMutableArray array];
    }
    return self;
}

- (int)fullByteSize {
    int totalBytes = 0;
    NSArray* scrapsToCountBytes;
    @synchronized(allLoadedScraps) {
        scrapsToCountBytes = [allLoadedScraps copy];
    }
    for (MMScrapView* scrap in scrapsToCountBytes) {
        totalBytes += scrap.fullByteSize;
    }
    return totalBytes;
}

#pragma mark - Save and Load

- (void)loadStateAsynchronously:(BOOL)async atPath:(NSString*)scrapIDsPath andMakeEditable:(BOOL)makeEditable andAdjustForScale:(BOOL)adjustForScale {
    if (self.isForgetful) {
        return;
    }
    CheckThreadMatches([NSThread isMainThread] || [MMTrashManager isTrashManagerQueue]);
    if (![self isStateLoaded]) {
        __block NSArray* scrapProps;
        __block NSArray* scrapIDsOnPage;
        __block CGSize scrapStatePageSize;
        BOOL wasAlreadyLoading = [self isLoading];
        @synchronized(self) {
            [self setIsLoading:YES];
            if (makeEditable) {
                targetLoadedState = MMScrapCollectionStateTargetLoadedEditable;
            } else if (targetLoadedState == MMScrapCollectionStateTargetUnloaded) {
                // only set to loaded+notEditable if our current target is unloaded
                targetLoadedState = MMScrapCollectionStateTargetLoadedNotEditable;
            }
        }

        NSMutableArray* scrapPropsWithState = [NSMutableArray array];

        __block BOOL hasBailedOnLoadingBecauseOfMismatchedTargetState = NO;

        void (^blockForImportExportStateQueue)() = ^(void) {
            CheckThreadMatches([NSThread isMainThread] || [MMTrashManager isTrashManagerQueue] || [MMScrapCollectionState isImportExportStateQueue]);
            @autoreleasepool {
                if (self.isForgetful) {
                    return;
                }
                @synchronized(self) {
                    if (targetLoadedState == MMScrapCollectionStateTargetUnloaded) {
                        DebugLog(@"MMScrapsOnPaperState bailing early");
                        hasBailedOnLoadingBecauseOfMismatchedTargetState = YES;
                        return;
                    }
                }
                NSDictionary* allScrapStateInfo = [NSDictionary dictionaryWithContentsOfFile:scrapIDsPath];

                if ([[NSFileManager defaultManager] fileExistsAtPath:scrapIDsPath] && !allScrapStateInfo) {
                    DebugLog(@"corruped file at %@", scrapIDsPath);
                }
                scrapIDsOnPage = [allScrapStateInfo objectForKey:@"scrapsOnPageIDs"];
                scrapProps = [allScrapStateInfo objectForKey:@"allScrapProperties"];
                scrapStatePageSize = CGSizeMake([allScrapStateInfo[@"screenSize.width"] floatValue], [allScrapStateInfo[@"screenSize.height"] floatValue]);
            }
        };
        void (^blockForMainThread)() = ^{
            @autoreleasepool {
                BOOL adjustForScaleWasNeededAfterAll = NO;
                if (self.isForgetful) {
                    return;
                }
                if ([self isStateLoaded]) {
                    // it's possible that we were asked to load asynchronously
                    // which would add this block to the main thread, then asked
                    // again to load synchronously, which would run before
                    // this block would've had the chance. so always
                    // double check if we've already loaded before we thought
                    // we needed to.
                    return;
                }
                if (hasBailedOnLoadingBecauseOfMismatchedTargetState) {
                    DebugLog(@"MMScrapsOnPaperState main thread bailing early");
                    isLoaded = NO;
                    [self setIsLoading:NO];
                    return;
                }
                // load all the states async
                if ([scrapIDsOnPage count]) {
                    for (NSString* scrapUUID in scrapIDsOnPage) {
                        if (self.isForgetful) {
                            return;
                        }
                        @synchronized(self) {
                            if (targetLoadedState == MMScrapCollectionStateTargetUnloaded) {
                                hasBailedOnLoadingBecauseOfMismatchedTargetState = YES;
                                isLoaded = NO;
                                [self setIsLoading:NO];
                                return;
                            }
                        }

                        NSDictionary* scrapProperties = [scrapProps jotReduce:^id(NSDictionary* obj, NSUInteger index, id accum) {
                            if ([obj[@"uuid"] isEqualToString:scrapUUID]) {
                                return obj;
                            }
                            return accum;
                        }];

                        if (!scrapProperties) {
                            [[Mixpanel sharedInstance] track:kMPEventCrashAverted properties:@{ @"Issue #": @(1722) }];

                            CGRect screenBounds = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds];
                            scrapProperties = @{ @"uuid": scrapUUID,
                                                 @"center.x": @(CGRectGetWidth(screenBounds) / 2),
                                                 @"center.y": @(CGRectGetHeight(screenBounds) / 2),
                                                 @"scale": @(1),
                                                 @"rotation": @(0),
                                                 @"subviewIndex": @(0) };
                        }

                        MMScrapView* scrap = [delegate scrapForUUIDIfAlreadyExistsInOtherContainer:scrapUUID];

                        NSMutableDictionary* props = [NSMutableDictionary dictionaryWithDictionary:scrapProperties];
                        if (scrap && scrap.state.scrapsOnPaperState == self) {
                            //                        DebugLog(@"page found scrap on sidebar %@", scrapUUID);
                            [props setObject:scrap forKey:@"scrap"];
                            [scrapPropsWithState addObject:props];
                        } else {
                            __block MMScrapViewState* state = nil;
                            state = [[MMScrapViewState alloc] initWithUUID:scrapUUID andPaperState:self];
                            if (state) {
                                [props setObject:state forKey:@"state"];
                                [scrapPropsWithState addObject:props];
                            } else {
                                // failed to load scrap
                                DebugLog(@"failed to load %@ at %@", scrapUUID, scrapIDsPath);
                            }
                        }
                    }
                }

                // maintain order of loaded scraps, so that they are added to the page
                // in the correct order as they load
                [scrapPropsWithState sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    return [scrapIDsOnPage indexOfObject:[obj1 objectForKey:@"uuid"]] < [scrapIDsOnPage indexOfObject:[obj2 objectForKey:@"uuid"]] ? NSOrderedAscending : NSOrderedDescending;
                }];
                for (__strong NSDictionary* scrapProperties in scrapPropsWithState) {
                    if (self.isForgetful) {
                        return;
                    }

                    if (adjustForScale || !CGSizeEqualToSize(scrapStatePageSize, CGSizeZero)) {
                        if (CGSizeEqualToSize(scrapStatePageSize, CGSizeZero)) {
                            scrapStatePageSize.width = 768;
                            scrapStatePageSize.height = 1024;
                        }
                        // https://github.com/adamwulf/loose-leaf/issues/1611
                        // bundled pages are from 768x1024 pages, so we need to scale them for iPad Pro
                        // this works as long as the width/height ratios are equal.
                        // if/when Apple releases a device w/ different screen ratio then I'll need
                        // to update this to handle aspect fill/fit/whatever

                        CGRect screenBounds = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds];
                        if (CGRectGetWidth(screenBounds) != scrapStatePageSize.width && CGRectGetHeight(screenBounds) != scrapStatePageSize.height) {
                            CGFloat widthRatio = CGRectGetWidth(screenBounds) / scrapStatePageSize.width;
                            CGFloat heightRatio = CGRectGetHeight(screenBounds) / scrapStatePageSize.height;

                            NSMutableDictionary* adjustedProperties = [scrapProperties mutableCopy];
                            adjustedProperties[@"center.x"] = @([scrapProperties[@"center.x"] floatValue] * widthRatio);
                            adjustedProperties[@"center.y"] = @([scrapProperties[@"center.y"] floatValue] * heightRatio);
                            adjustedProperties[@"scale"] = @([scrapProperties[@"scale"] floatValue] * widthRatio);

                            scrapProperties = adjustedProperties;
                            adjustForScaleWasNeededAfterAll = YES;
                        }
                    }


                    MMScrapView* scrap = nil;
                    if ([scrapProperties objectForKey:@"scrap"]) {
                        scrap = [scrapProperties objectForKey:@"scrap"];
                        //                            DebugLog(@"page %@ reused scrap %@", delegate.uuid, scrap.uuid);
                    } else {
                        MMScrapViewState* scrapState = [scrapProperties objectForKey:@"state"];
                        scrap = [[MMScrapView alloc] initWithScrapViewState:scrapState];
                        //                            DebugLog(@"page %@ built scrap %@", delegate.uuid, scrap.uuid);
                        // only set properties if we built the scrap,
                        // otherwise it's in the sidebar and we don't
                        // own it right now
                        [scrap setPropertiesDictionary:scrapProperties];
                    }
                    if (scrap) {
                        @synchronized(allLoadedScraps) {
                            [allLoadedScraps addObject:scrap];
                        }

                        BOOL isShownOnPage = NO;
                        if ([scrapIDsOnPage containsObject:scrap.uuid]) {
                            [self.delegate didLoadScrapInContainer:scrap];
                            [self showScrap:scrap];
                            isShownOnPage = YES;
                        } else {
                            [self.delegate didLoadScrapOutOfContainer:scrap];
                        }

                        if (isShownOnPage && makeEditable) {
                            [scrap loadScrapStateAsynchronously:async];
                        } else {
                            [scrap unloadStateButKeepThumbnailIfAny];
                            if ([self.delegate scrapForUUIDIfAlreadyExistsInOtherContainer:scrap.uuid]) {
                                // noop, let the bezel handle its own thumbnails
                            } else if (isShownOnPage) {
                                [scrap.state loadCachedScrapPreview];
                            } else {
                                [scrap.state unloadCachedScrapPreview];
                            }
                        }
                    }
                }
                @synchronized(self) {
                    isLoaded = YES;
                    [self setIsLoading:NO];
                    MMImmutableScrapCollectionState* immutableState = [self immutableStateForPath:nil];
                    expectedUndoHash = [immutableState undoHash];
                    if (!adjustForScaleWasNeededAfterAll) {
                        // if we're adjusting for scale, then we'll need to
                        // save our edits no matter what
                        lastSavedUndoHash = [immutableState undoHash];
                    }
                    //                        DebugLog(@"loaded scrapsOnPaperState at: %lu", (unsigned long)lastSavedUndoHash);
                }
                [self.delegate didLoadAllScrapsFor:self];

                // we were asked to unload halfway through loading,
                // so in case that unload already finished while we
                // were creating scraps, we should re-fire the unload
                // call, just in case
                @synchronized(self) {
                    if (targetLoadedState == MMScrapCollectionStateTargetUnloaded) {
                        DebugLog(@"MMScrapsOnPaperState: loaded a scrapsOnPaperState, but was asked to unload it after all");
                        dispatch_async([MMScrapCollectionState importExportStateQueue], ^{
                            @autoreleasepool {
                                [self unloadPaperState];
                            }
                        });
                    }
                }
            }
        };

        if (!async) {
            // this will load from the background thread synchronously
            // and then will run the main thread synchronously.
            // if already on the main thread, it won't block waiting
            // on itself
            blockForImportExportStateQueue();
            [NSThread performBlockOnMainThreadSync:blockForMainThread];
        } else if (wasAlreadyLoading) {
            // noop, it's already loading asynchornously
            // so we don't need to do anything extra
        } else if (async) {
            // we're not yet loading and we want to load
            // asynchronously
            //
            // this will load from disk on the background queue,
            // and then will add the block to the main thread
            // after that
            dispatch_async([MMScrapCollectionState importExportStateQueue], blockForImportExportStateQueue);
            dispatch_async([MMScrapCollectionState importExportStateQueue], ^{
                [NSThread performBlockOnMainThread:blockForMainThread];
            });
        }
    } else if ([self isStateLoaded] && makeEditable) {
        void (^loadScrapsForAlreadyLoadedState)() = ^(void) {
            @autoreleasepool {
                if ([self isStateLoaded]) {
                    for (MMScrapView* scrap in self.scrapsOnPaper) {
                        [scrap loadScrapStateAsynchronously:async];
                    }
                }
                @synchronized(self) {
                    if (targetLoadedState == MMScrapCollectionStateTargetUnloaded) {
                        DebugLog(@"MMScrapsOnPaperState: loaded a scrapsOnPaperState, but was asked to unload it after all");
                        dispatch_async([MMScrapCollectionState importExportStateQueue], ^{
                            @autoreleasepool {
                                [self unloadPaperState];
                            }
                        });
                    }
                }
            }
        };
        if (async) {
            dispatch_async([MMScrapCollectionState importExportStateQueue], loadScrapsForAlreadyLoadedState);
        } else {
            // we're already on the correct thread, so just run it now
            loadScrapsForAlreadyLoadedState();
        }
    }
}

- (void)unloadPaperState {
    CheckThreadMatches([MMScrapCollectionState isImportExportStateQueue]);
    [super unloadPaperState];
}

- (MMImmutableScrapsOnPaperState*)immutableStateForPath:(NSString*)scrapIDsPath {
    CheckMainThread;
    if ([self isStateLoaded]) {
        hasEditsToSave = NO;
        @synchronized(allLoadedScraps) {
            MMImmutableScrapsOnPaperState* immutable = [[MMImmutableScrapsOnPaperState alloc] initWithScrapIDsPath:scrapIDsPath
                                                                                                      andAllScraps:allLoadedScraps
                                                                                                   andScrapsOnPage:self.scrapsOnPaper
                                                                                                     andOwnerState:self];
            expectedUndoHash = [immutable undoHash];
            return immutable;
        }
    }
    return nil;
}

- (void)performBlockForUnloadedScrapStateSynchronously:(void (^)())block onBlockComplete:(void (^)())onComplete andLoadFrom:(NSString*)scrapIDsPath withBundledScrapIDsPath:(NSString*)bundledScrapIDsPath andImmediatelyUnloadState:(BOOL)shouldImmediatelyUnload {
    CheckThreadMatches([NSThread isMainThread] || [MMTrashManager isTrashManagerQueue]);
    if ([self isStateLoaded]) {
        @throw [NSException exceptionWithName:@"LoadedStateForUnloadedBlockException"
                                       reason:@"Cannot run block on unloaded state when state is already loaded"
                                     userInfo:nil];
    }
    @autoreleasepool {
        //
        // the following loadState: call will run a portion of
        // its load synchronously on [MMScrapCollectionState importExportStateQueue]
        // which means that the importExportStateQueue will be effectively empty.
        //
        // this method is not allowed to be called from the importExportStateQueue
        // itself, so the load method below won't be run with pending blocks already
        // on the queue.
        if ([[NSFileManager defaultManager] fileExistsAtPath:scrapIDsPath]) {
            [self loadStateAsynchronously:NO atPath:scrapIDsPath andMakeEditable:YES andAdjustForScale:NO];
        } else {
            [self loadStateAsynchronously:NO atPath:bundledScrapIDsPath andMakeEditable:YES andAdjustForScale:YES];
        }
    }
    block();
    dispatch_async([MMScrapCollectionState importExportStateQueue], ^(void) {
        // the importExportStateQueue might be being used by another scrapsOnPaperState
        // to save itself to disk, so its not necessarily empty at this point. we
        // must call the onComplete asynchronously.
        @autoreleasepool {
            onComplete();
            if (shouldImmediatelyUnload) {
                //
                // this will add the unload block to be the very next block to run
                // asynchrously from the currently empty importExportStateQueue queue
                dispatch_async([MMScrapCollectionState importExportStateQueue], ^(void) {
                    @autoreleasepool {
                        [self unloadPaperState];
                    }
                });
            }
        }
    });
}

#pragma mark - Create Scraps

- (MMScrapView*)addScrapWithPath:(UIBezierPath*)path andRotation:(CGFloat)rotation andScale:(CGFloat)scale {
    if (![self isStateLoaded]) {
        @throw [NSException exceptionWithName:@"ModifyingUnloadedScrapsOnPaperStateException" reason:@"cannot add scrap to unloaded ScrapsOnPaperState" userInfo:nil];
    }


    __block MMScrapView* newScrap;

    // timing start
    CGFloat duration = [NSThread timeBlock:^{
        newScrap = [[MMScrapView alloc] initWithBezierPath:path andScale:scale andRotation:rotation andPaperState:self];
    }];
    DebugLog(@"time to build scrap = %f", duration);
    // timing end


    @synchronized(allLoadedScraps) {
        [allLoadedScraps addObject:newScrap];
    }
    return newScrap;
}

#pragma mark - Manage Scraps

- (NSArray*)scrapsOnPaper {
    // we'll be calling this method quite often,
    // so don't create a new auto-released array
    // all the time. instead, just return our subview
    // array, so that if the caller just needs count
    // or to iterate on the main thread, we don't
    // spend unnecessary resources copying a potentially
    // long array.
    @synchronized(scrapContainerView) {
        NSMutableArray* scrapsOnPaper = [NSMutableArray arrayWithArray:scrapContainerView.subviews];
        @synchronized(scrapsPendingRemoval) {
            [scrapsOnPaper removeObjectsInArray:scrapsPendingRemoval];
        }
        return scrapsOnPaper;
    }
}

- (void)showScrap:(MMScrapView*)scrap atIndex:(NSUInteger)subviewIndex {
    [self showScrap:scrap];
    [scrap.superview insertSubview:scrap atIndex:subviewIndex];
}

- (void)showScrap:(MMScrapView*)scrap {
    CheckMainThread;
    if (!scrap.state.scrapsOnPaperState) {
        // if the scrap doesn't have a paperstate,
        // then its loading while being deleted,
        // so just fail silently
        return;
    }
    if (scrap.state.scrapsOnPaperState != self) {
        @throw [NSException exceptionWithName:@"ScrapAddedToWrongPageException" reason:@"This scrap was added to a page that doesn't own it" userInfo:nil];
    }
    @synchronized(scrapContainerView) {
        [scrapContainerView addSubview:scrap];
    }
    [scrap setShouldShowShadow:self.delegate.isEditable];
    if (isLoaded || [self isLoading]) {
        [scrap loadScrapStateAsynchronously:YES];
    } else {
        [scrap unloadState];
    }
}

- (void)hideScrap:(MMScrapView*)scrap {
    @synchronized(scrapContainerView) {
        if (scrapContainerView == scrap.superview) {
            [scrap setShouldShowShadow:NO];
            [scrap removeFromSuperview];
        } else {
            @throw [NSException exceptionWithName:@"MMScrapContainerException" reason:@"Removing scrap from a container that doesn't own it" userInfo:nil];
        }
    }
}

- (BOOL)isScrapVisible:(MMScrapView*)scrap {
    return [self.scrapsOnPaper containsObject:scrap];
}

- (void)scrapVisibilityWasUpdated:(MMScrapView*)scrap {
    if ([self isStateLoaded] && ![self isLoading] && !isUnloading) {
        // something changed w/ scrap visibility
        // we only care if we're fully loaded, not if
        // we're loading or unloading.
        hasEditsToSave = YES;
    }
}

- (MMScrapView*)mostRecentScrap {
    @synchronized(allLoadedScraps) {
        return [allLoadedScraps lastObject];
    }
}


#pragma mark - Saving Helpers

- (MMScrapView*)removeScrapWithUUID:(NSString*)scrapUUID {
    MMScrapView* removedScrap = nil;
    @synchronized(allLoadedScraps) {
        NSMutableArray* otherArray = [NSMutableArray array];
        for (MMScrapView* scrap in allLoadedScraps) {
            if (![scrap.uuid isEqualToString:scrapUUID]) {
                [otherArray addObject:scrap];
            } else {
                removedScrap = scrap;
            }
        }
        allLoadedScraps = otherArray;
        hasEditsToSave = YES;
    }
    if (removedScrap) {
        @synchronized(scrapsPendingRemoval) {
            [scrapsPendingRemoval addObject:removedScrap];
        }
        [NSThread performBlockOnMainThread:^{
            if (removedScrap.superview == scrapContainerView) {
                [removedScrap removeFromSuperview];
            }
            @synchronized(scrapsPendingRemoval) {
                [scrapsPendingRemoval removeObject:removedScrap];
            }
        }];
    }
    return removedScrap;
}

#pragma mark - Paths

- (NSString*)directoryPathForScrapUUID:(NSString*)uuid {
    NSString* scrapPath = [[self.delegate.pagesPath stringByAppendingPathComponent:@"Scraps"] stringByAppendingPathComponent:uuid];
    return scrapPath;
}

- (NSString*)bundledDirectoryPathForScrapUUID:(NSString*)uuid {
    NSString* scrapPath = [[self.delegate.bundledPagesPath stringByAppendingPathComponent:@"Scraps"] stringByAppendingPathComponent:uuid];
    return scrapPath;
}

#pragma mark - Deleting Assets

- (void)deleteScrapWithUUID:(NSString*)scrapUUID shouldRespectOthers:(BOOL)respectOthers {
    // for scrapsOnPaperState, we need to ask
    // the page to delete the scrap, as we don't
    // own all of the assets for it
    [self.delegate deleteScrapWithUUID:scrapUUID shouldRespectOthers:respectOthers];
}

@end
