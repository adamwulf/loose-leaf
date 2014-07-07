//
//  MMPageCacheManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/21/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPageCacheManager.h"
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
            [pagesWithLoadedCacheImages addObject:pageBelow];
        }
    }
    if([page isKindOfClass:[MMEditablePaperView class]]){
        [(MMEditablePaperView*)page loadCachedPreview];
        [pagesWithLoadedCacheImages addObject:page];
        if([[self.delegate pagesInCurrentBezelGesture] count] > 6 &&
           [pagesWithLoadedCacheImages count] > 6){
            // fetch and unload middle ish object
            MMPaperView* page = [pagesWithLoadedCacheImages objectAtIndex:[pagesWithLoadedCacheImages count] / 2];
            if([page isKindOfClass:[MMEditablePaperView class]]){
                // we have a pretty impressive bezel going on here,
                // so start to unload the pages that are pretty much
                // invisible in the bezel stack
                [(MMEditablePaperView*)page unloadCachedPreview];
                [pagesWithLoadedCacheImages removeObject:page];
            }
        }
    }

    if(page && ![recentlySuggestedPageUUID isEqualToString:page.uuid]){
        recentlySuggestedPageUUID = page.uuid;
        [self loadStateForPage:page];
        debug_NSLog(@"may change top page to: %@ %d", page.uuid, (int) [stateLoadedPages count]);
    }
}

-(void) willChangeTopPageTo:(MMPaperView*)page{
    if(!page){
        @throw [NSException exceptionWithName:@"will change to nil page" reason:@"unknown" userInfo:nil];
    }
    if(page && !([recentlySuggestedPageUUID isEqualToString:page.uuid] ||
                 [recentlyConfirmedPageUUID isEqualToString:page.uuid])){
        [self loadStateForPage:page];
    }
    if(page && ![recentlySuggestedPageUUID isEqualToString:page.uuid]){
        recentlySuggestedPageUUID = page.uuid;
        debug_NSLog(@"will switch top page to %@", page.uuid);
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
            // too many pages, kick one out
            [[stateLoadedPages lastObject] unloadState];
            [stateLoadedPages removeLastObject];
        }
        if([page isKindOfClass:[MMEditablePaperView class]]){
            // finally, tell that page to load its state
            MMEditablePaperView* editablePage = (MMEditablePaperView*)page;
            [editablePage loadStateAsynchronously:YES withSize:[drawableView pagePixelSize] andContext:[drawableView context]];
        }
    }
}

-(void) ensureTopPageIsLoaded:(MMPaperView*)topPage{
    if(!topPage || [topPage isKindOfClass:[MMEditablePaperView class]]){
        MMUndoablePaperView* editableTopPage = (MMUndoablePaperView*)topPage;
        
        if(currentEditablePage != editableTopPage){
            // only care if the page is changing
            if(![currentEditablePage hasEditsToSave] && (!editableTopPage || [editableTopPage hasStateLoaded])){
                // the outgoing page is saved to disk
                // and the incoming page has its
                // state loaded
                if([delegate isShowingPageView]){
                    // only swap the drawable view if we're showing
                    // the page view
                    [currentEditablePage setDrawableView:nil];
                    [currentEditablePage setEditable:NO];
                    [currentEditablePage setCanvasVisible:NO];
                    currentEditablePage = editableTopPage;
                    //                debug_NSLog(@"did switch top page to %@", currentEditablePage.uuid);
                    [currentEditablePage setDrawableView:drawableView];
                }
            }else{
                if(![editableTopPage hasStateLoaded]){
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


-(void) updateVisiblePageImageCache{
    NSArray* visiblePages = [self.delegate findPagesInVisibleRowsOfListView];
    NSIndexSet* indexes = [pagesWithLoadedCacheImages indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger indx, BOOL*stop){
        return ![visiblePages containsObject:obj];
    }];
    NSArray* invisiblePages = [pagesWithLoadedCacheImages objectsAtIndexes:indexes];
    for(MMEditablePaperView* page in invisiblePages){
        if(![stateLoadedPages containsObject:page]){
            // only allowed to unload pages that we haven't
            // asked to load their full state
            [page unloadCachedPreview];
            [pagesWithLoadedCacheImages removeObject:page];
        }
    }
    for(MMEditablePaperView* page in visiblePages){
        [page loadCachedPreview];
    }
    [pagesWithLoadedCacheImages addObjectsFromArray:visiblePages];
}

#pragma mark - Profiling Helpers

-(NSInteger) numberOfStateLoadedPages{
    return [stateLoadedPages count];
}

-(NSInteger) numberOfPagesWithLoadedPreviewImage{
    return [pagesWithLoadedCacheImages count];
}

-(int) memoryOfStateLoadedPages{
    int totalBytes = 0;
    NSArray* pages = [NSArray arrayWithArray:stateLoadedPages];
    for(MMPaperView* page in pages){
        totalBytes += page.fullByteSize;
    }
    return totalBytes;
}


@end
