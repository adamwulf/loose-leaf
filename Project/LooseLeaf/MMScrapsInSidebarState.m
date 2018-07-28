//
//  MMScrapsInSidebarState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/14/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapsInSidebarState.h"
#import "MMScrapView.h"
#import "NSThread+BlockAdditions.h"
#import "MMImmutableScrapsOnPaperState.h"
#import "MMScrapContainerView.h"
#import "MMImmutableScrapsInSidebarState.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMTrashManager.h"
#import "Constants.h"
#import "Mixpanel.h"

#define kPageUUIDForBezelCollectionState @"Bezel"


@implementation MMScrapsInSidebarState {
    // all of the loaded properties for all this state's scraps
    NSMutableArray* allPropertiesForScraps;
}

@dynamic delegate;

- (id)initWithDelegate:(NSObject<MMScrapsInSidebarStateDelegate>*)_delegate {
    if (self = [super init]) {
        delegate = _delegate;
        allPropertiesForScraps = [NSMutableArray array];
    }
    return self;
}

- (int)fullByteSize {
    int totalBytes = 0;
    @synchronized(allLoadedScraps) {
        for (MMScrapView* scrap in allLoadedScraps) {
            totalBytes += scrap.fullByteSize;
        }
    }
    return totalBytes;
}

#pragma mark - Save and Load

- (void)loadStateAsynchronously:(BOOL)async atPath:(NSString*)scrapIDsPath andMakeEditable:(BOOL)makeEditable andAdjustForScale:(BOOL)adjustForScale {
    CheckThreadMatches([NSThread isMainThread] || [MMTrashManager isTrashManagerQueue]);
    if (![self isStateLoaded] && ![self isLoading]) {
        __block NSArray* scrapProps;
        @synchronized(self) {
            [self setIsLoading:YES];
        }

        void (^block2)() = ^(void) {
            @autoreleasepool {
                dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
                NSDictionary* allScrapStateInfo = [NSDictionary dictionaryWithContentsOfFile:scrapIDsPath];

                scrapProps = [allScrapStateInfo objectForKey:@"allScrapProperties"];

                NSMutableArray* scrapPropsWithState = [NSMutableArray array];

                dispatch_group_t serviceGroup = dispatch_group_create();

                // load all the states async
                for (NSDictionary* scrapProperties in scrapProps) {
                    NSString* pageUUID = [scrapProperties objectForKey:@"pageUUID"];
                    NSString* scrapUUID = [scrapProperties objectForKey:@"uuid"];
                    MMScrapCollectionState* paperStateForScrap = [self.delegate paperStateForPageUUID:pageUUID];
                    if ([pageUUID isEqualToString:kPageUUIDForBezelCollectionState]) {
                        paperStateForScrap = self;
                    }

                    NSAssert(paperStateForScrap, @"must have paperStateForScrap");

                    dispatch_group_enter(serviceGroup);
                    [paperStateForScrap runBlockWhenLoaded:^{
                        MMScrapView* scrapFromPaperState = [paperStateForScrap scrapForUUID:scrapUUID];

                        if (scrapFromPaperState) {
                            //                        DebugLog(@"sidebar found scrap from page %@", scrapFromPaperState.uuid);
                            NSMutableDictionary* props = [NSMutableDictionary dictionaryWithDictionary:scrapProperties];
                            [props setObject:scrapFromPaperState forKey:@"scrap"];
                            [scrapPropsWithState addObject:props];
                        } else {
                            // couldn't find already built scrap, so load a state and
                            // we'll build a scrap
                            if (paperStateForScrap) {
                                __block MMScrapViewState* state = nil;
                                [NSThread performBlockOnMainThreadSync:^{
                                    state = [[MMScrapViewState alloc] initWithUUID:scrapUUID andPaperState:paperStateForScrap];
                                }];
                                if (state) {
                                    NSMutableDictionary* props = [NSMutableDictionary dictionaryWithDictionary:scrapProperties];
                                    [props setObject:state forKey:@"state"];
                                    [scrapPropsWithState addObject:props];
                                } else {
                                    DebugLog(@"couldn't find state for %@", scrapUUID);
                                }
                            } else {
                                DebugLog(@"couldn't find scrap's page state for %@ in page %@", scrapUUID, pageUUID);
                            }
                        }

                        dispatch_group_leave(serviceGroup);
                    }];
                }

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    dispatch_group_wait(serviceGroup, DISPATCH_TIME_FOREVER);

                    [NSThread performBlockOnMainThread:^{
                        for (NSDictionary* scrapProperties in scrapPropsWithState) {
                            @synchronized(self) {
                                if (isUnloading) {
                                    @throw [NSException exceptionWithName:@"StateInconsistentException" reason:@"loading during unloading" userInfo:nil];
                                }
                            }
                            MMScrapView* scrap = nil;
                            if ([scrapProperties objectForKey:@"scrap"]) {
                                scrap = [scrapProperties objectForKey:@"scrap"];
                                //                            DebugLog(@"reused scrap %@", scrap.uuid);
                            } else {
                                MMScrapViewState* scrapState = [scrapProperties objectForKey:@"state"];
                                scrap = [[MMScrapView alloc] initWithScrapViewState:scrapState];
                                //                            DebugLog(@"built scrap %@", scrap.uuid);
                                [scrap setPropertiesDictionary:scrapProperties];
                            }
                            if (scrap) {
                                @synchronized(allLoadedScraps) {
                                    [allLoadedScraps addObject:scrap];
                                    [allPropertiesForScraps addObject:scrapProperties];
                                }

                                [self.delegate didLoadScrapInContainer:scrap];

                                if (makeEditable) {
                                    [scrap loadScrapStateAsynchronously:async];
                                }
                            } else {
                                DebugLog(@"couldn't load scrap for %@", scrapProperties);
                            }
                        }
                        @synchronized(self) {
                            isLoaded = YES;
                            [self setIsLoading:NO];
                            MMImmutableScrapCollectionState* immutableState = [self immutableStateForPath:nil];
                            expectedUndoHash = [immutableState undoHash];
                            lastSavedUndoHash = [immutableState undoHash];
                        }
                        [self.delegate didLoadAllScrapsFor:self];
                        dispatch_semaphore_signal(sema1);
                    }];
                    dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
                });
            }
        };

        if (async) {
            dispatch_async([MMScrapCollectionState importExportStateQueue], block2);
        } else {
            block2();
        }
    } else if ([self isStateLoaded] && makeEditable) {
        void (^block2)() = ^(void) {
            @autoreleasepool {
                if ([self isStateLoaded]) {
                    @synchronized(allLoadedScraps) {
                        for (MMScrapView* scrap in allLoadedScraps) {
                            [scrap loadScrapStateAsynchronously:async];
                            @synchronized(self) {
                                if (isUnloading) {
                                    @throw [NSException exceptionWithName:@"StateInconsistentException" reason:@"loading during unloading" userInfo:nil];
                                }
                            }
                        }
                    }
                }
            }
        };
        if (async) {
            dispatch_async([MMScrapCollectionState importExportStateQueue], block2);
        } else {
            block2();
        }
    }
}

- (MMImmutableScrapsInSidebarState*)immutableStateForPath:(NSString*)scrapIDsPath {
    CheckMainThread;
    if ([self isStateLoaded]) {
        @synchronized(allLoadedScraps) {
            hasEditsToSave = NO;
            MMImmutableScrapsInSidebarState* immutable = [[MMImmutableScrapsInSidebarState alloc] initWithScrapIDsPath:scrapIDsPath andAllScrapProperties:allPropertiesForScraps andOwnerState:self];
            expectedUndoHash = [immutable undoHash];
            return immutable;
        }
    }
    return nil;
}

#pragma mark - Saving Helpers

- (void)wasSavedAtUndoHash:(NSUInteger)savedUndoHash {
    @synchronized(self) {
        lastSavedUndoHash = savedUndoHash;
    }
}


#pragma mark - Manage Scraps

- (void)scrapVisibilityWasUpdated:(MMScrapView*)scrap {
    // noop
}

- (MMScrapView*)scrapForUUID:(NSString*)uuid {
    @synchronized(allLoadedScraps) {
        for (MMScrapView* scrap in allLoadedScraps) {
            if ([scrap.uuid isEqualToString:uuid]) {
                return scrap;
            }
        }
    }
    return nil;
}

- (void)scrapIsAddedToSidebar:(MMScrapView*)scrap {
    @synchronized(allLoadedScraps) {
        if (![allLoadedScraps containsObject:scrap]) {
            if (scrap) {
                NSMutableDictionary* props = [NSMutableDictionary dictionaryWithDictionary:[scrap propertiesDictionary]];
                [props setObject:[scrap owningPageUUID] ?: kPageUUIDForBezelCollectionState forKey:@"pageUUID"];

                [[Mixpanel sharedInstance] track:kMPEventCrashAverted properties:@{ @"Issue #": @(1523),
                                                                                    @"scrap": @(YES),
                                                                                    @"scrapState.scrapsOnPaperState": scrap.state.scrapsOnPaperState ? @(YES) : @(NO),
                                                                                    @"scrapState.scrapsOnPaperState.delegate": scrap.state.scrapsOnPaperState.delegate ? @(YES) : @(NO) }];

                [allPropertiesForScraps insertObject:props atIndex:0];
                [allLoadedScraps insertObject:scrap atIndex:0];
                hasEditsToSave = YES;
            } else {
                [[Mixpanel sharedInstance] track:kMPEventCrashAverted properties:@{ @"Issue #": @(1523),
                                                                                    @"scrap": @(NO) }];
            }
        }
    }
}

- (void)scrapIsRemovedFromSidebar:(MMScrapView*)scrap {
    @synchronized(allLoadedScraps) {
        NSUInteger index = [allLoadedScraps indexOfObject:scrap];
        if (index != NSNotFound) {
            [allPropertiesForScraps removeObjectAtIndex:index];
            [allLoadedScraps removeObjectAtIndex:index];
            hasEditsToSave = YES;
        }
    }
}

#pragma mark - Paths

- (NSString*)directoryPathForScrapUUID:(NSString*)uuid {
    NSString* documentsPath = [NSFileManager documentsPath];
    NSString* bezelStateDirectory = [documentsPath stringByAppendingPathComponent:@"Bezel"];
    NSString* scrapPath = [[bezelStateDirectory stringByAppendingPathComponent:@"Scraps"] stringByAppendingPathComponent:uuid];
    return scrapPath;
}

- (NSString*)bundledDirectoryPathForScrapUUID:(NSString*)uuid {
    NSString* documentsPath = [[NSBundle mainBundle] pathForResource:@"Documents" ofType:nil];
    NSString* bezelStateDirectory = [documentsPath stringByAppendingPathComponent:@"Bezel"];
    NSString* scrapPath = [[bezelStateDirectory stringByAppendingPathComponent:@"Scraps"] stringByAppendingPathComponent:uuid];
    return scrapPath;
}

#pragma mark - Scrap Stealing

- (void)stealScrap:(NSString*)scrapUUID fromScrapCollectionState:(MMScrapCollectionState*)formerScrapCollectionState {
    // make sure we've written all files to that directory
    [[JotDiskAssetManager sharedManager] blockUntilCompletedForDirectory:[formerScrapCollectionState directoryPathForScrapUUID:scrapUUID]];

    [super stealScrap:scrapUUID fromScrapCollectionState:formerScrapCollectionState];

    @synchronized(allLoadedScraps) {
        for (int i = 0; i < [allPropertiesForScraps count]; i++) {
            NSDictionary* aScrapProps = [allPropertiesForScraps objectAtIndex:i];
            if ([[aScrapProps objectForKey:@"uuid"] isEqualToString:scrapUUID]) {
                // edit this entry
                NSMutableDictionary* replacementProps = [NSMutableDictionary dictionaryWithDictionary:aScrapProps];
                [replacementProps setObject:kPageUUIDForBezelCollectionState forKey:@"pageUUID"];
                [allPropertiesForScraps replaceObjectAtIndex:i withObject:replacementProps];
                hasEditsToSave = YES;
                break;
            }
        }
    }
}

- (void)deleteScrapWithUUID:(NSString*)scrapUUID shouldRespectOthers:(BOOL)respectOthers {
    //    DebugLog(@"sidebar needs to delete assets for %@", scrapUUID);

    dispatch_async([[MMTrashManager sharedInstance] trashManagerQueue], ^{
        @autoreleasepool {
            NSString* directoryForScrap = [self directoryPathForScrapUUID:scrapUUID];

            if (![[NSFileManager defaultManager] fileExistsAtPath:directoryForScrap]) {
                //                DebugLog(@"asking sidebar to delete a scrap that doesn't exist on the filesystem: %@", directoryForScrap);
            } else {
                NSError* err = nil;
                [[NSFileManager defaultManager] removeItemAtPath:directoryForScrap error:&err];
                if (err) {
                    DebugLog(@"error deleted scrap assets from sidebar: %@, %@", directoryForScrap, err);
                } else {
                    //                    DebugLog(@"deleted scrap assets from sidebar: %@", directoryForScrap);
                }
            }
        }
    });
}

@end
