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

@interface MMImmutableScrapsOnPaperState (Private)

-(NSUInteger) undoHash;

@end

/**
 * similar to the MMPaperState, this object will
 * track the state for all scraps within a single page
 */
@implementation MMScrapsOnPaperState{
    // the container to hold the scraps
    MMScrapContainerView* scrapContainerView;
}

@dynamic delegate;
@synthesize scrapContainerView;

-(id) initWithDelegate:(NSObject<MMScrapsOnPaperStateDelegate>*)_delegate withScrapContainerSize:(CGSize)scrapContainerSize{
    if(self = [super init]){
        delegate = _delegate;
        scrapContainerView = [[MMScrapContainerView alloc] initWithFrame:CGRectMake(0, 0, scrapContainerSize.width, scrapContainerSize.height)
                                                   forScrapsOnPaperState:self];
        // anchor the view to the top left,
        // so that when we scale down, the drawable view
        // stays in place
        scrapContainerView.layer.anchorPoint = CGPointMake(0,0);
        scrapContainerView.layer.position = CGPointMake(0,0);
    }
    return self;
}

-(int) fullByteSize{
    int totalBytes = 0;
    for(MMScrapView* scrap in allLoadedScraps){
        totalBytes += scrap.fullByteSize;
    }
    return totalBytes;
}

#pragma mark - Save and Load

-(void) loadStateAsynchronously:(BOOL)async atPath:(NSString*)scrapIDsPath andMakeEditable:(BOOL)makeEditable{
    if(![self isStateLoaded] && !isLoading){
        __block NSArray* scrapProps;
        @synchronized(self){
            isLoading = YES;
        }
        
        void (^block2)() = ^(void) {
            @autoreleasepool {
                dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
                NSDictionary* allScrapStateInfo = [NSDictionary dictionaryWithContentsOfFile:scrapIDsPath];

                NSArray* scrapIDsOnPage = [allScrapStateInfo objectForKey:@"scrapsOnPageIDs"];
                scrapProps = [allScrapStateInfo objectForKey:@"allScrapProperties"];

                NSMutableArray* scrapPropsWithState = [NSMutableArray array];
                
                // load all the states async
                for(NSDictionary* scrapProperties in scrapProps){
                    NSString* scrapUUID = [scrapProperties objectForKey:@"uuid"];
                    
                    MMScrapView* scrap = [delegate scrapForUUIDIfAlreadyExistsInOtherContainer:scrapUUID];

                    NSMutableDictionary* props = [NSMutableDictionary dictionaryWithDictionary:scrapProperties];
                    if(scrap){
//                        NSLog(@"page found scrap on sidebar %@", scrapUUID);
                        [props setObject:scrap forKey:@"scrap"];
                        [scrapPropsWithState addObject:props];
                    }else{
                        MMScrapViewState* state = [[MMScrapViewState alloc] initWithUUID:scrapUUID andPaperState:self];
                        if(state){
                            [props setObject:state forKey:@"state"];
                            [scrapPropsWithState addObject:props];
                        }else{
                            // failed to load scrap
                        }
                    }
                }
                
                // maintain order of loaded scraps, so that they are added to the page
                // in the correct order as they load
                [scrapPropsWithState sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    return [scrapIDsOnPage indexOfObject:[obj1 objectForKey:@"uuid"]] < [scrapIDsOnPage indexOfObject:[obj2 objectForKey:@"uuid"]] ? NSOrderedAscending : NSOrderedDescending;
                }];
                
                [NSThread performBlockOnMainThread:^{
                    for(NSDictionary* scrapProperties in scrapPropsWithState){
                        @synchronized(self){
                            if(isUnloading){
                                @throw [NSException exceptionWithName:@"StateInconsistentException" reason:@"loading during unloading" userInfo:nil];
                            }
                        }
                        MMScrapView* scrap = nil;
                        if([scrapProperties objectForKey:@"scrap"]){
                            scrap = [scrapProperties objectForKey:@"scrap"];
//                            NSLog(@"page %@ reused scrap %@", delegate.uuid, scrap.uuid);
                        }else{
                            MMScrapViewState* scrapState = [scrapProperties objectForKey:@"state"];
                            scrap = [[MMScrapView alloc] initWithScrapViewState:scrapState];
//                            NSLog(@"page %@ built scrap %@", delegate.uuid, scrap.uuid);
                            // only set properties if we built the scrap,
                            // otherwise it's in the sidebar and we don't
                            // own it right now
                            [scrap setPropertiesDictionary:scrapProperties];
                        }
                        if(scrap){
                            [allLoadedScraps addObject:scrap];
                            
                            if([scrapIDsOnPage containsObject:scrap.uuid]){
                                [self.delegate didLoadScrapInContainer:scrap];
                                [self showScrap:scrap];
                            }else{
                                [self.delegate didLoadScrapOutOfContainer:scrap];
                            }
                            
                            if(makeEditable){
                                [scrap loadScrapStateAsynchronously:async];
                            }
                        }
                    }
                    @synchronized(self){
                        isLoaded = YES;
                        isLoading = NO;
                        MMImmutableScrapCollectionState* immutableState = [self immutableStateForPath:nil];
                        expectedUndoHash = [immutableState undoHash];
                        lastSavedUndoHash = [immutableState undoHash];
//                        NSLog(@"loaded scrapsOnPaperState at: %lu", (unsigned long)lastSavedUndoHash);
                    }
                    [self.delegate didLoadAllScrapsFor:self];
                    dispatch_semaphore_signal(sema1);
                }];
                dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
//                dispatch_release(sema1); ARC handles this
            }
        };

        if(async){
            dispatch_async([MMScrapCollectionState importExportStateQueue], block2);
        }else{
            block2();
        }
    }else if([self isStateLoaded] && makeEditable){
        void (^block2)() = ^(void) {
            if([self isStateLoaded]){
                for(MMScrapView* scrap in self.scrapsOnPaper){
                    [scrap loadScrapStateAsynchronously:async];
                    @synchronized(self){
                        if(isUnloading){
                            @throw [NSException exceptionWithName:@"StateInconsistentException" reason:@"loading during unloading" userInfo:nil];
                        }
                    }
                }
            }
        };
        if(async){
            dispatch_async([MMScrapCollectionState importExportStateQueue], block2);
        }else{
            block2();
        }
    }
}

-(void) unload{
    if(self.delegate == [[MMPageCacheManager sharedInstance] currentEditablePage]){
        NSLog(@"what");
    }
    [super unload];
}

-(MMImmutableScrapsOnPaperState*) immutableStateForPath:(NSString*)scrapIDsPath{
    if([self isStateLoaded]){
        hasEditsToSave = NO;
        MMImmutableScrapsOnPaperState* immutable = [[MMImmutableScrapsOnPaperState alloc] initWithScrapIDsPath:scrapIDsPath andAllScraps:allLoadedScraps andScrapsOnPage:self.scrapsOnPaper andOwnerState:self];
        expectedUndoHash = [immutable undoHash];
        return immutable;
    }
    return nil;
}

#pragma mark - Create Scraps

-(MMScrapView*) addScrapWithPath:(UIBezierPath*)path andRotation:(CGFloat)rotation andScale:(CGFloat)scale{
    if(![self isStateLoaded]){
        @throw [NSException exceptionWithName:@"ModifyingUnloadedScrapsOnPaperStateException" reason:@"cannot add scrap to unloaded ScrapsOnPaperState" userInfo:nil];
    }
    MMScrapView* newScrap = [[MMScrapView alloc] initWithBezierPath:path andScale:scale andRotation:rotation andPaperState:self];
    [allLoadedScraps addObject:newScrap];
    return newScrap;
}

#pragma mark - Manage Scraps

-(NSArray*) scrapsOnPaper{
    // we'll be calling this method quite often,
    // so don't create a new auto-released array
    // all the time. instead, just return our subview
    // array, so that if the caller just needs count
    // or to iterate on the main thread, we don't
    // spend unnecessary resources copying a potentially
    // long array.
    @synchronized(scrapContainerView){
        return scrapContainerView.subviews;
    }
}

-(void) showScrap:(MMScrapView*)scrap atIndex:(NSUInteger)subviewIndex{
    [self showScrap:scrap];
    [scrap.superview insertSubview:scrap atIndex:subviewIndex];
}

-(void) showScrap:(MMScrapView*)scrap{
    CheckMainThread;
    if(scrap.state.scrapsOnPaperState != self){
        @throw [NSException exceptionWithName:@"ScrapAddedToWrongPageException" reason:@"This scrap was added to a page that doesn't own it" userInfo:nil];
    }
    @synchronized(scrapContainerView){
        [scrapContainerView addSubview:scrap];
    }
    [scrap setShouldShowShadow:self.delegate.isEditable];
    if(isLoaded || isLoading){
        [scrap loadScrapStateAsynchronously:YES];
    }else{
        [scrap unloadState];
    }
}

-(void) hideScrap:(MMScrapView*)scrap{
    @synchronized(scrapContainerView){
        if(scrapContainerView == scrap.superview){
            [scrap setShouldShowShadow:NO];
            [scrap removeFromSuperview];
        }else{
            @throw [NSException exceptionWithName:@"MMScrapContainerException" reason:@"Removing scrap from a container that doesn't own it" userInfo:nil];
        }
    }
}

-(BOOL) isScrapVisible:(MMScrapView*)scrap{
    return [self.scrapsOnPaper containsObject:scrap];
}

-(void) scrapVisibilityWasUpdated:(MMScrapView*)scrap{
    if([self isStateLoaded] && !isLoading && !isUnloading){
        // something changed w/ scrap visibility
        // we only care if we're fully loaded, not if
        // we're loading or unloading.
        hasEditsToSave = YES;
    }
}

-(MMScrapView*) scrapForUUID:(NSString*)uuid{
    @synchronized(allLoadedScraps){
        for(MMScrapView*scrap in allLoadedScraps){
            if([scrap.uuid isEqualToString:uuid]){
                return scrap;
            }
        }
    }
    return nil;
}

-(MMScrapView*) mostRecentScrap{
    return [allLoadedScraps lastObject];
}


#pragma mark - Saving Helpers

-(void) removeScrapWithUUID:(NSString*)scrapUUID{
    @synchronized(allLoadedScraps){
        NSMutableArray* otherArray = [NSMutableArray array];
        for(MMScrapView* scrap in allLoadedScraps){
            if(![scrap.uuid isEqualToString:scrapUUID]){
                [otherArray addObject:scrap];
            }else{
                NSLog(@"permanently removed scrap %@ from page %@", scrapUUID, self.delegate.uuid);
            }
        }
        allLoadedScraps = otherArray;
        hasEditsToSave = YES;
    }
}

#pragma mark - Paths

-(NSString*) directoryPathForScrapUUID:(NSString*)uuid{
    NSString* scrapPath = [[self.delegate.pagesPath stringByAppendingPathComponent:@"Scraps"] stringByAppendingPathComponent:uuid];
    return scrapPath;
}

-(NSString*) bundledDirectoryPathForScrapUUID:(NSString*)uuid{
    NSString* scrapPath = [[self.delegate.bundledPagesPath stringByAppendingPathComponent:@"Scraps"] stringByAppendingPathComponent:uuid];
    return scrapPath;
}

@end
