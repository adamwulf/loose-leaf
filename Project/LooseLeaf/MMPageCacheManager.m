//
//  MMPageCacheManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/21/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPageCacheManager.h"
#import "MMJotViewNilState.h"
#import "Constants.h"

@implementation MMPageCacheManager{
    // this is the UUID of the page that has
    // most recently been suggested that it might
    // be the top page soon
    NSString* recentlySuggestedPageUUID;
    NSString* recentlyConfirmedPageUUID;
    MMEditablePaperView* currentlyTopPage;
    MMUndoablePaperView* currentEditablePage;
    NSMutableArray* stateLoadedPages;
    NSMutableOrderedSet* pagesWithLoadedCacheImages;
    BOOL hasEverLoadedAPageState;
}

@synthesize delegate;
@synthesize drawableView;
@synthesize currentEditablePage;

static MMPageCacheManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        _instance = self;
        stateLoadedPages = [NSMutableArray array];
        pagesWithLoadedCacheImages = [NSMutableOrderedSet orderedSet];
        hasEverLoadedAPageState = NO;
    }
    return _instance;
}

+(MMPageCacheManager*) sharedInstance{
    if(!_instance){
        _instance = [[MMPageCacheManager alloc] init];
    }
    return _instance;
}

#pragma mark - Public

-(void) mayChangeTopPageTo:(MMPaperView*)page{
    if([self.delegate isPageInVisibleStack:page]){
        MMPaperView* pageBelow = [self.delegate getPageBelow:page];
        if([pageBelow isKindOfClass:[MMEditablePaperView class]]){
            [(MMEditablePaperView*)pageBelow loadCachedPreview];
            @synchronized(stateLoadedPages){
                [pagesWithLoadedCacheImages addObject:pageBelow];
            }
        }
    }
    // reset location of current top page
    if(currentEditablePage){
        @synchronized(stateLoadedPages){
            [pagesWithLoadedCacheImages removeObject:currentEditablePage];
            [pagesWithLoadedCacheImages addObject:currentEditablePage];
        }
    }
    // now unload any extra pages
    if([page isKindOfClass:[MMEditablePaperView class]]){
        [(MMEditablePaperView*)page loadCachedPreview];
        MMEditablePaperView* pageToUnloadFromCacheIfAny = nil;
        @synchronized(stateLoadedPages){
            [pagesWithLoadedCacheImages addObject:page];
            if([[self.delegate pagesInCurrentBezelGesture] count] > 6 &&
               [pagesWithLoadedCacheImages count] > 6){
                // fetch and unload middle ish object
                pageToUnloadFromCacheIfAny = [pagesWithLoadedCacheImages objectAtIndex:[pagesWithLoadedCacheImages count] / 2];
                if([pageToUnloadFromCacheIfAny isKindOfClass:[MMEditablePaperView class]]){
                    // we have a pretty impressive bezel going on here,
                    // so start to unload the pages that are pretty much
                    // invisible in the bezel stack
                    [pagesWithLoadedCacheImages removeObject:pageToUnloadFromCacheIfAny];
                }
            }
        }
        if(pageToUnloadFromCacheIfAny){
            [pageToUnloadFromCacheIfAny unloadCachedPreview];
        }
    }

    if(page && ![recentlySuggestedPageUUID isEqualToString:page.uuid]){
        recentlySuggestedPageUUID = page.uuid;
        [self loadStateForPage:page];
        debug_NSLog(@"may change top page to: %@ %d", page.uuid, (int) [stateLoadedPages count]);
    }
}

-(void) willChangeTopPageTo:(MMPaperView*)page{
    if(!page && [delegate countAllPages]){
        // don't allow changing to nil page unless
        // there are no pages to change to (count is zero)
        @throw [NSException exceptionWithName:@"NilPageException" reason:@"will change to nil page" userInfo:nil];
    }
    if(page && !([recentlySuggestedPageUUID isEqualToString:page.uuid] ||
                 [recentlyConfirmedPageUUID isEqualToString:page.uuid])){
        [self loadStateForPage:page];
    }
    if(page && ![recentlySuggestedPageUUID isEqualToString:page.uuid]){
        recentlySuggestedPageUUID = page.uuid;
        debug_NSLog(@"will switch top page to %@", page.uuid);
    }
    if(!page){
        recentlySuggestedPageUUID = nil;
        recentlyConfirmedPageUUID = nil;
        currentEditablePage = nil;
        currentlyTopPage = nil;
        [stateLoadedPages removeAllObjects];
        [pagesWithLoadedCacheImages removeAllObjects];
    }
}

// returns YES if we changed the top cached page
// returns NO otherwise
-(BOOL) didChangeToTopPage:(MMPaperView*)topPage{
    [self ensureTopPageIsLoaded:topPage];
    if(topPage && ![recentlyConfirmedPageUUID isEqualToString:topPage.uuid]){
        recentlyConfirmedPageUUID = topPage.uuid;
        currentlyTopPage = (MMEditablePaperView*) topPage;
        [self updateVisiblePageImageCache];
        debug_NSLog(@"did change top page to %@", topPage.uuid);
        return YES;
    }
    return NO;
}

-(void) willNotChangeTopPageTo:(MMPaperView*)page{
    debug_NSLog(@"will NOT change top page to: %@", page.uuid);
}



#pragma mark - Page Saving Notifications

-(void) didSavePage:(MMPaperView*)page{
    if(currentlyTopPage.scale < kMinPageZoom){
        [self ensureTopPageIsLoaded:currentlyTopPage];
    }
}

-(void) didLoadStateForPage:(MMEditablePaperView *)page{
    if(page == currentlyTopPage || page == currentEditablePage){
        //        NSLog(@"didLoadStateForPage: %@", page.uuid);
        if(page.scale > kMinPageZoom){
            [self ensureTopPageIsLoaded:currentlyTopPage];
        }
    }
    if(!hasEverLoadedAPageState){
        hasEverLoadedAPageState = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kPageCacheManagerHasLoadedAnyPage object:self];
        });
    }
}

-(void) didUnloadStateForPage:(MMEditablePaperView*) page{
    if(page == currentlyTopPage || page == currentEditablePage){
        //        NSLog(@"didUnloadStateForPage: %@", page.uuid);
        if(page.scale > kMinPageZoom){
            [self ensureTopPageIsLoaded:currentlyTopPage];
        }
    }
}



#pragma mark - Protected


-(void) loadStateForPage:(MMPaperView*)page{
    if(page){
        // add the page to the beginning
        @synchronized(stateLoadedPages){
            [stateLoadedPages removeObject:page];
            [stateLoadedPages insertObject:page atIndex:0];
            if(currentEditablePage){
                // ensure the currently editable page never
                // gets kicked out of the cache. it's always
                // the most recent
                [stateLoadedPages removeObject:currentEditablePage];
                [stateLoadedPages insertObject:currentEditablePage atIndex:0];
            }
            if([stateLoadedPages count] > kMMPageCacheManagerSize){
                if([stateLoadedPages lastObject] == currentEditablePage){
                    NSLog(@"what");
                }
                // too many pages, kick one out
                [[stateLoadedPages lastObject] unloadState];
                [stateLoadedPages removeLastObject];
            }
        }
        if([page isKindOfClass:[MMEditablePaperView class]]){
            // finally, tell that page to load its state
            MMEditablePaperView* editablePage = (MMEditablePaperView*)page;
            [editablePage loadStateAsynchronously:YES withSize:drawableView.pagePtSize andScale:drawableView.scale andContext:[drawableView context]];
        }
    }
}

-(void) ensureTopPageIsLoaded:(MMPaperView*)topPage{
    if(!topPage || [topPage isKindOfClass:[MMEditablePaperView class]]){
        MMUndoablePaperView* editableTopPage = (MMUndoablePaperView*)topPage;
        
        if(currentEditablePage != editableTopPage){
            // only care if the page is changing
            if(![currentEditablePage hasEditsToSave] && (!editableTopPage || [editableTopPage isStateLoaded])){
                // the outgoing page is saved to disk
                // and the incoming page has its
                // state loaded
                if([delegate isShowingPageView]){
                    // only swap the drawable view if we're showing
                    // the page view
                    [currentEditablePage setDrawableView:nil];
                    [currentEditablePage setEditable:NO];
                    currentEditablePage = editableTopPage;
                    //                debug_NSLog(@"did switch top page to %@", currentEditablePage.uuid);
                    [currentEditablePage setDrawableView:drawableView];
                }
            }else{
                if(![editableTopPage isStateLoaded]){
                    // load the state for the new top page
                    //                    debug_NSLog(@"load state for future top page: %@", editableTopPage.uuid);
                    [self loadStateForPage:editableTopPage];
                }else{
                    // we're saving the top page to disk
                }
            }
        }else{
            // just double check that we're in editable state
            [currentEditablePage setDrawableView:drawableView];
        }
    }
}

-(void) pageWasDeleted:(MMPaperView*)page{
    if(page){
        @synchronized(stateLoadedPages){
            [stateLoadedPages removeObject:page];
        }
        [pagesWithLoadedCacheImages removeObject:page];
        if(currentlyTopPage == page){
            currentlyTopPage = nil;
        }
        if(currentEditablePage == page){
            currentEditablePage = nil;
            [drawableView loadState:[MMJotViewNilState sharedInstance]];
        }
    }
}


-(void) updateVisiblePageImageCache{
    NSArray* visiblePages = [self.delegate findPagesInVisibleRowsOfListView];
    NSIndexSet* indexes = [pagesWithLoadedCacheImages indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger indx, BOOL*stop){
        return ![visiblePages containsObject:obj];
    }];
    NSArray* invisiblePages = [pagesWithLoadedCacheImages objectsAtIndexes:indexes];
    for(MMEditablePaperView* page in invisiblePages){
        @synchronized(stateLoadedPages){
            if(![stateLoadedPages containsObject:page]){
                // only allowed to unload pages that we haven't
                // asked to load their full state
                [page unloadCachedPreview];
                [pagesWithLoadedCacheImages removeObject:page];
            }
        }
    }
    for(MMEditablePaperView* page in visiblePages){
        [page loadCachedPreview];
    }
    @synchronized(stateLoadedPages){
        [pagesWithLoadedCacheImages addObjectsFromArray:visiblePages];
    }
}

-(void) forgetAboutPage:(MMPaperView*)page{
    @synchronized(stateLoadedPages){
        if([stateLoadedPages containsObject:page]){
            [stateLoadedPages removeObject:page];
        }
        if([pagesWithLoadedCacheImages containsObject:page]){
            [pagesWithLoadedCacheImages removeObject:page];
        }
        if(currentEditablePage == page){
            currentEditablePage = nil;
        }
        if(currentlyTopPage == page){
            currentEditablePage = nil;
        }
    }
}

#pragma mark - Profiling Helpers

-(NSInteger) numberOfStateLoadedPages{
    @synchronized(stateLoadedPages){
        return [stateLoadedPages count];
    }
}

-(NSInteger) numberOfPagesWithLoadedPreviewImage{
    @synchronized(stateLoadedPages){
        return [pagesWithLoadedCacheImages count];
    }
}

-(int) memoryOfStateLoadedPages{
    int totalBytes = 0;
    @synchronized(stateLoadedPages){
        for(MMPaperView* page in stateLoadedPages){
            totalBytes += page.fullByteSize;
        }
    }
    return totalBytes;
}


@end
