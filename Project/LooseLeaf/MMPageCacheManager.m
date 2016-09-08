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


@implementation MMPageCacheManager {
    // this is the UUID of the page that has
    // most recently been suggested that it might
    // be the top page soon
    NSString* recentlySuggestedPageUUID;
    NSString* recentlyConfirmedPageUUID;
    MMUndoablePaperView* currentlyTopPage;
    MMUndoablePaperView* currentEditablePage;
    NSMutableArray* stateLoadedPages;
    NSMutableOrderedSet* pagesWithLoadedCacheImages;
    BOOL hasEverLoadedAPageState;
}

@synthesize delegate;
@synthesize drawableView;
@synthesize currentEditablePage;

static MMPageCacheManager* _instance = nil;

- (id)init {
    if (_instance)
        return _instance;
    if ((self = [super init])) {
        _instance = self;
        stateLoadedPages = [NSMutableArray array];
        pagesWithLoadedCacheImages = [NSMutableOrderedSet orderedSet];
        hasEverLoadedAPageState = NO;
    }
    return _instance;
}

+ (MMPageCacheManager*)sharedInstance {
    if (!_instance) {
        _instance = [[MMPageCacheManager alloc] init];
    }
    return _instance;
}

#pragma mark - Public

- (void)mayChangeTopPageTo:(MMPaperView*)page {
    CheckMainThread;
    if ([self.delegate isPageInVisibleStack:page]) {
        MMPaperView* pageBelow = [self.delegate getPageBelow:page];
        if ([pageBelow isKindOfClass:[MMEditablePaperView class]]) {
            [(MMEditablePaperView*)pageBelow loadCachedPreview];
            @synchronized(stateLoadedPages) {
                [pagesWithLoadedCacheImages addObject:pageBelow];
            }
        }
    }
    // reset location of current top page
    if (currentEditablePage) {
        @synchronized(stateLoadedPages) {
            [pagesWithLoadedCacheImages removeObject:currentEditablePage];
            [pagesWithLoadedCacheImages addObject:currentEditablePage];
        }
    }
    // now unload any extra pages
    if ([page isKindOfClass:[MMEditablePaperView class]]) {
        [(MMEditablePaperView*)page loadCachedPreview];
        MMEditablePaperView* pageToUnloadFromCacheIfAny = nil;
        @synchronized(stateLoadedPages) {
            [pagesWithLoadedCacheImages addObject:page];
            if ([[self.delegate pagesInCurrentBezelGesture] count] > 6 &&
                [pagesWithLoadedCacheImages count] > 6) {
                // fetch and unload middle ish object
                pageToUnloadFromCacheIfAny = [pagesWithLoadedCacheImages objectAtIndex:[pagesWithLoadedCacheImages count] / 2];
                if ([pageToUnloadFromCacheIfAny isKindOfClass:[MMEditablePaperView class]]) {
                    // we have a pretty impressive bezel going on here,
                    // so start to unload the pages that are pretty much
                    // invisible in the bezel stack
                    [pagesWithLoadedCacheImages removeObject:pageToUnloadFromCacheIfAny];
                }
            }
        }
        if (pageToUnloadFromCacheIfAny) {
            [pageToUnloadFromCacheIfAny unloadCachedPreview];
        }
    }
}

- (void)willChangeTopPageTo:(MMEditablePaperView*)page {
    CheckMainThread;
    if (!page && [delegate countAllPages]) {
        // don't allow changing to nil page unless
        // there are no pages to change to (count is zero)
        @throw [NSException exceptionWithName:@"NilPageException" reason:@"will change to nil page" userInfo:nil];
    }
    [self ensureTopPageIsLoaded:currentlyTopPage];
    if (!page) {
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
- (BOOL)didChangeToTopPage:(MMPaperView*)topPage {
    CheckMainThread;
    [self ensureTopPageIsLoaded:topPage];
    if (topPage && ![recentlyConfirmedPageUUID isEqualToString:topPage.uuid]) {
        recentlyConfirmedPageUUID = topPage.uuid;
        [self ensureTopPageIsLoaded:topPage];
        [self updateVisiblePageImageCache];
        DebugLog(@"did change top page to %@", topPage.uuid);
        return YES;
    }
    return NO;
}

- (void)willNotChangeTopPageTo:(MMPaperView*)page {
    CheckMainThread;
    //    DebugLog(@"will NOT change top page to: %@", page.uuid);
}


#pragma mark - Page Saving Notifications

- (void)didSavePage:(MMPaperView*)page {
    if (currentlyTopPage.scale < kMinPageZoom) {
        [self ensureTopPageIsLoaded:currentlyTopPage];
    }
}

- (void)didLoadStateForPage:(MMEditablePaperView*)page {
    @synchronized(stateLoadedPages) {
        [stateLoadedPages addObject:page];
    }
    //    DebugLog(@"MMPageCacheManager did load state for %@", page.uuid);
    if (page == currentlyTopPage || page == currentEditablePage) {
        //        DebugLog(@"didLoadStateForPage: %@", page.uuid);
        if (page.scale > kMinPageZoom) {
            [self ensureTopPageIsLoaded:currentlyTopPage];
        }
    }
    if (!hasEverLoadedAPageState) {
        hasEverLoadedAPageState = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            @autoreleasepool {
                [[NSNotificationCenter defaultCenter] postNotificationName:kPageCacheManagerHasLoadedAnyPage object:self];
            }
        });
    }
}

- (void)didUnloadStateForPage:(MMEditablePaperView*)page {
    @synchronized(stateLoadedPages) {
        [stateLoadedPages removeObject:currentEditablePage];
    }
    //    DebugLog(@"MMPageCacheManager did UNLOAD state for %@", page.uuid);
    if (page == currentlyTopPage || page == currentEditablePage) {
        //        DebugLog(@"didUnloadStateForPage: %@", page.uuid);
        if (page == currentEditablePage && page != currentlyTopPage) {
            [currentEditablePage setDrawableView:nil];
            [currentEditablePage setEditable:NO];
            [drawableView loadState:[MMJotViewNilState sharedInstance]];
            currentEditablePage = nil;
        }
        if (page.scale > kMinPageZoom) {
            [self ensureTopPageIsLoaded:currentlyTopPage];
        }
    }
}


#pragma mark - Protected

- (BOOL)isEditablePageStable {
    BOOL (^isPageLoadedHuh)(MMUndoablePaperView*) = ^(MMUndoablePaperView* page) {
        __block BOOL allStatesAreLoaded = [page isStateLoaded];
        [[currentEditablePage scrapsOnPaper] enumerateObjectsUsingBlock:^(MMScrapView* obj, NSUInteger idx, BOOL* stop) {
            allStatesAreLoaded = allStatesAreLoaded && [[obj state] isScrapStateLoaded];
        }];
        return allStatesAreLoaded;
    };

    BOOL topIsEditable = !currentEditablePage || currentEditablePage == currentlyTopPage;
    BOOL topIsLoaded = !currentlyTopPage || isPageLoadedHuh(currentlyTopPage);

    return (topIsEditable && topIsLoaded);
}

- (void)ensureTopPageIsLoaded:(MMPaperView*)topPage {
    CheckMainThread;
    if (!topPage || [topPage isKindOfClass:[MMEditablePaperView class]]) {
        MMUndoablePaperView* replacementEditablePage = (MMUndoablePaperView*)topPage;
        //        DebugLog(@"MMPageCacheManager was told %@ is top page", topPage.uuid);
        @synchronized(stateLoadedPages) {
            if (currentlyTopPage != currentEditablePage &&
                currentlyTopPage != replacementEditablePage) {
                // we tried to load a different top page
                // but switched to another too fast. unload it
                [currentlyTopPage unloadState];
                //                DebugLog(@"MMPageCacheManager flipped to different top page while editable was still unloading %@ vs %@", currentlyTopPage.uuid, topPage.uuid);
            }
            currentlyTopPage = replacementEditablePage;
            if (currentEditablePage != replacementEditablePage) {
                if ([currentEditablePage hasEditsToSave]) {
                    // if the currently editable page has edits, then save it
                    [currentEditablePage saveToDisk:nil];
                    //                    DebugLog(@"MMPageCacheManager saving %@ to make room for %@", currentEditablePage.uuid, topPage.uuid);
                } else if ([currentEditablePage isStateLoaded]) {
                    // current editable is saved, so now we need to unload it
                    // so we can load in the newly editable page
                    [currentEditablePage unloadState];
                    //                    DebugLog(@"MMPageCacheManager unloading %@ to make room for %@", currentEditablePage.uuid, topPage.uuid);
                } else if (![replacementEditablePage isStateLoaded]) {
                    // now we need to load the state for the page
                    // that will become editable
                    DebugLog(@"MMPageCacheManager loading new top page %@", topPage.uuid);
                    [replacementEditablePage loadStateAsynchronously:YES withSize:drawableView.pagePtSize andScale:drawableView.scale andContext:drawableView.context];
                } else {
                    DebugLog(@"MMPageCacheManager new current editable %@", topPage.uuid);
                    // now the old editable page is unloaded,
                    // and the new editable page is loaded,
                    // so give the drawable view to the new page
                    // and turn it on
                    [currentEditablePage setDrawableView:nil];
                    [currentEditablePage setEditable:NO];
                    currentEditablePage = replacementEditablePage;
                    [currentEditablePage setDrawableView:drawableView];
                }
            } else {
                //                DebugLog(@"MMPageCacheManager same editable top page %@", topPage.uuid);
                // just double check that we're in editable state
                [currentEditablePage setDrawableView:drawableView];
            }
        }
    }
}

- (void)pageWasDeleted:(MMPaperView*)page {
    CheckMainThread;
    if (page) {
        //        DebugLog(@"MMPageCacheManager page was deleted %@", page.uuid);
        @synchronized(stateLoadedPages) {
            [stateLoadedPages removeObject:page];
        }
        [pagesWithLoadedCacheImages removeObject:page];
        if (currentlyTopPage == page) {
            currentlyTopPage = nil;
        }
        if (currentEditablePage == page) {
            currentEditablePage = nil;
            [drawableView loadState:[MMJotViewNilState sharedInstance]];
        }
    }
}


- (void)updateVisiblePageImageCache {
    NSArray* visiblePages = [self.delegate findPagesInVisibleRowsOfListView];
    NSIndexSet* indexes = [pagesWithLoadedCacheImages indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger indx, BOOL* stop) {
        return ![visiblePages containsObject:obj];
    }];
    NSArray* invisiblePages = [pagesWithLoadedCacheImages objectsAtIndexes:indexes];
    for (MMEditablePaperView* page in invisiblePages) {
        @synchronized(stateLoadedPages) {
            if (![stateLoadedPages containsObject:page]) {
                // only allowed to unload pages that we haven't
                // asked to load their full state
                [page unloadCachedPreview];
                [pagesWithLoadedCacheImages removeObject:page];
            }
        }
    }
    for (MMEditablePaperView* page in visiblePages) {
        [self loadPageThumbnailToCache:page];
    }
}

- (void)loadPageThumbnailToCache:(MMEditablePaperView*)page {
    [page loadCachedPreview];
    @synchronized(stateLoadedPages) {
        [pagesWithLoadedCacheImages addObject:page];
    }
}

- (void)forgetAboutPage:(MMEditablePaperView*)page {
    @synchronized(stateLoadedPages) {
        if ([stateLoadedPages containsObject:page]) {
            [stateLoadedPages removeObject:page];
        }
        if ([pagesWithLoadedCacheImages containsObject:page]) {
            [page unloadCachedPreview];
            [pagesWithLoadedCacheImages removeObject:page];
        }
        if (currentEditablePage == page) {
            currentEditablePage = nil;
        }
        if (currentlyTopPage == page) {
            currentEditablePage = nil;
        }
    }
}

#pragma mark - Profiling Helpers

- (NSInteger)numberOfStateLoadedPages {
    @synchronized(stateLoadedPages) {
        return [stateLoadedPages count];
    }
}

- (NSInteger)numberOfPagesWithLoadedPreviewImage {
    @synchronized(stateLoadedPages) {
        return [pagesWithLoadedCacheImages count];
    }
}

- (int)memoryOfStateLoadedPages {
    int totalBytes = 0;
    NSArray* pagesToCountBytes;
    @synchronized(stateLoadedPages) {
        pagesToCountBytes = [stateLoadedPages copy];
    }
    for (MMPaperView* page in pagesToCountBytes) {
        totalBytes += page.fullByteSize;
    }
    return totalBytes;
}


@end
