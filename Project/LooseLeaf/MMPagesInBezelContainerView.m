//
//  MMPagesInBezelContainerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/27/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMPagesInBezelContainerView.h"
#import "MMPageBubbleButton.h"
#import "NSThread+BlockAdditions.h"
#import "MMImmutableScrapsOnPaperState.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMRotationManager.h"
#import "UIView+Debug.h"
#import "MMImmutableScrapsInSidebarState.h"
#import "MMTrashManager.h"
#import "MMSidebarButtonTapGestureRecognizer.h"
#import "MMBlockOperation.h"
#import "MMAllStacksManager.h"
#import "MMSingleStackManager.h"
#import "MMTutorialStackView.h"
#import "MMEditablePaperView.h"
#import "MMPagesSidebarButton.h"
#import "MMCollapsableStackView.h"
#import "NSArray+Map.h"
#import "UIScreen+MMSizing.h"

#define kAnimationDuration 0.3


@implementation MMPagesInBezelContainerView {
    BOOL hasLoaded;
    NSOperationQueue* opQueue;

    NSArray* pagesMeta;

    // We'll use a stack as a container for all the pages that are added
    // to the sidebar.
    MMCollapsableStackView* pageSidebarStack;
}

@dynamic bubbleDelegate;

- (id)initWithFrame:(CGRect)frame andCountButton:(MMCountBubbleButton*)_countButton {
    if (self = [super initWithFrame:frame andCountButton:_countButton]) {
        pageSidebarStack = [[MMCollapsableStackView alloc] initWithFrame:frame andUUID:@"PageSidebar"];

        contentView = [[MMCountableSidebarContentView alloc] initWithFrame:[slidingSidebarView contentBounds]];
        contentView.delegate = self;
        contentView.shouldReverseInSidebar = YES;
        [slidingSidebarView addSubview:contentView];
        opQueue = [[NSOperationQueue alloc] init];
        [opQueue setMaxConcurrentOperationCount:1];

        pagesMeta = [[NSArray alloc] initWithContentsOfFile:[MMPagesInBezelContainerView pathToPlist]];


        NSMutableArray* pagesSoFar = [NSMutableArray array];

        pagesMeta = [pagesMeta filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary* _Nullable evaluatedObject, NSDictionary<NSString*, id>* _Nullable bindings) {
            // filter out duplicates, just in case.
            // I ran into a situation where I did have duplicate pages in the sidebar,
            // likely a sideeffect of being in debug mode, but better safe than sorry

            NSString* stackUUID = evaluatedObject[@"stackUUID"] ?: @"";
            NSString* pageUUID = evaluatedObject[@"uuid"] ?: @"";
            NSString* key = [stackUUID stringByAppendingString:pageUUID];

            BOOL alreadySeen = [pagesSoFar containsObject:key];

            [pagesSoFar addObject:key];

            return !alreadySeen;
        }]];
    }
    return self;
}

- (NSArray*)pagesMeta {
    return pagesMeta;
}

#pragma mark - MMCountableSidebarContainerView

- (CGSize)sizeForButton {
    CGSize screenSize = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds].size;
    CGSize listPageSize = CGSizeScale(screenSize, kListPageZoom);
    return CGSizeScale(listPageSize, .6);
}

- (CGFloat)targetAlphaForBubbleButton:(UIView<MMBubbleButton>*)bubble {
    if (self.alpha) {
        if ([[self viewsInSidebar] count] <= kMaxButtonsInBezelSidebar) {
            return [super targetAlphaForBubbleButton:bubble];
        } else {
            NSInteger minIndex = [[self viewsInSidebar] count] - 4;
            NSInteger index = [[self viewsInSidebar] indexOfObject:(MMEditablePaperView*)bubble.view];
            return index > minIndex ? 1 : 0;
        }
    } else {
        return 0;
    }
}

- (CGAffineTransform)targetTransformForBubbleButton:(UIView<MMBubbleButton>*)bubble {
    CGAffineTransform transform = [super targetTransformForBubbleButton:bubble];

    if ([[self viewsInSidebar] count] <= kMaxButtonsInBezelSidebar) {
        return transform;
    } else {
        CGFloat rot = RandomPhotoRotation([[self viewsInSidebar] indexOfObject:(MMEditablePaperView*)bubble.view]);

        CGAffineTransform rotTransform = CGAffineTransformMakeRotation(rot);

        return CGAffineTransformConcat(transform, rotTransform);
    }
}

- (CGFloat)offsetForSidebar {
    if ([UIScreen screenWidth] > 768) {
        return 20;
    }

    return 17;
}

- (CGPoint)centerForBubbleAtIndex:(NSInteger)index {
    if ([[self viewsInSidebar] count] <= kMaxButtonsInBezelSidebar) {
        CGSize sizeOfButton = [self sizeForButton];
        CGFloat rightBezelSide = self.bounds.size.width - sizeOfButton.width - [self offsetForSidebar];
        // midpoint calculates for 6 buttons
        CGFloat midPointY = (self.bounds.size.height - [self.viewsInSidebar count] * sizeOfButton.height) / 2;
        CGPoint ret = CGPointMake(rightBezelSide + sizeOfButton.width / 2, midPointY + sizeOfButton.height / 2);
        ret.y += sizeOfButton.height * index;
        ret.x += 8;
        return ret;
    } else {
        return self.countButton.center;
    }
}

- (MMPageBubbleButton*)newBubbleForView:(MMEditablePaperView*)page {
    CGSize buttonSize = [self sizeForButton];
    MMPageBubbleButton* bubble = [[MMPageBubbleButton alloc] initWithFrame:CGRectMake(0, 0, buttonSize.width, buttonSize.height)];
    bubble.originalViewScale = page.scale;
    return bubble;
}

- (void)addViewToCountableSidebar:(MMExportablePaperView*)page animated:(BOOL)animated {
    // make sure we've saved its current state
    if (animated) {
        // only save when it's animated. non-animated is loading
        // from disk at start up
        [page saveToDisk:nil];
    }

    __weak MMExportablePaperView* weakPage = page;
    [page setDidUnloadState:^{
        id<MMPaperViewDelegate> previousStack = weakPage.delegate;
        weakPage.delegate = pageSidebarStack;
        if (previousStack != pageSidebarStack) {
            // don't move attempt to move assets to the same place. This happens
            // when loading from disk during startup, we add all the pages
            // so the sidebar as we load them from disk
            [weakPage moveAssetsFrom:previousStack];
        }
    }];

    // unload the scrap state, so that it shows the
    // image preview instead of an editable state
    [page unloadState];

    [super addViewToCountableSidebar:page animated:animated];
}

- (void)deleteAllViewsFromSidebar {
    for (MMEditablePaperView* page in [[self viewsInSidebar] copy]) {
        [[MMTrashManager sharedInstance] deletePage:page];
    }

    [super deleteAllViewsFromSidebar];

    [self savePageContainerToDisk];
}

- (void)loadCachedPreviewForView:(MMEditablePaperView*)view {
    [view loadCachedPreview];
}

- (void)unloadCachedPreviewForView:(MMEditablePaperView*)view {
    [view unloadCachedPreview];
}

- (void)show:(BOOL)animated {
    [super show:animated];

    [UIView animateWithDuration:.3 animations:^{
        for (UIView* view in [bubbleForScrap allValues]) {
            view.alpha = 0;
        }
    }];
}

#pragma mark - Rotation

- (CGFloat)sidebarButtonRotation {
    return -([[[MMRotationManager sharedInstance] idealRotationReadingForCurrentOrientation] angle] + M_PI / 2);
}

- (void)didRotateToIdealOrientation:(UIInterfaceOrientation)orientation {
    self.countButton.rotation = [self sidebarButtonRotation];
    self.countButton.transform = CGAffineTransformMakeRotation([self sidebarButtonRotation]);
    [self.contentView setRotation:[self sidebarButtonRotation]];

    [super didRotateToIdealOrientation:orientation];
}

#pragma mark - Save and Load

static NSString* bezelStatePath;

+ (NSString*)pathToPlist {
    if (!bezelStatePath) {
        NSString* documentsPath = [NSFileManager documentsPath];
        NSString* bezelStateDirectory = [documentsPath stringByAppendingPathComponent:@"Bezel"];
        [NSFileManager ensureDirectoryExistsAtPath:bezelStateDirectory];
        bezelStatePath = [[bezelStateDirectory stringByAppendingPathComponent:@"page-sidebar"] stringByAppendingPathExtension:@"plist"];
    }
    return bezelStatePath;
}

- (void)savePageContainerToDisk {
    if (!hasLoaded) {
        // nothing to save if we haven't loaded anything yet
        return;
    }
    [NSThread performBlockOnMainThread:^{
        // must use main thread to get the stack
        // of UIViews to save to disk

        NSArray* sidebarPages = [NSArray arrayWithArray:[self viewsInSidebar]];

        [opQueue addOperation:[[MMBlockOperation alloc] initWithBlock:^{
            // now that we have the views to save,
            // we can actually write to disk on the background
            //
            // the opqueue makes sure that we will always save
            // to disk in the order that [saveToDisk] was called
            // on the main thread.
            pagesMeta = [sidebarPages mapObjectsUsingBlock:^id(MMPaperView* page, NSUInteger idx) {
                return [page dictionaryDescription];
            }];

            [pagesMeta writeToFile:[MMPagesInBezelContainerView pathToPlist] atomically:YES];
        }]];
    }];
}

- (void)upgradeIfNecessary:(MMExportablePaperView*)page withMeta:(NSDictionary*)meta {
    NSString* stackUUID = meta[@"stackUUID"];

    if (stackUUID) {
        MMCollapsableStackView* previousStack = [self.bubbleDelegate stackForUUID:stackUUID];
        NSString* originalPagesPath = [MMEditablePaperView pagesPathForStackUUID:stackUUID andPageUUID:page.uuid];
        if (previousStack && [[NSFileManager defaultManager] fileExistsAtPath:originalPagesPath]) {
            // The assets still exist in the previous stack, so move them
            // into the sidebar stack
            [page moveAssetsFrom:previousStack];
        }
    }
}

- (void)loadFromDisk {
    // load from disk
    CGRect bounds = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds];

    for (NSDictionary* pageMeta in pagesMeta) {
        NSString* pageUUID = pageMeta[@"uuid"];

        MMExportablePaperView* page = [[MMExportablePaperView alloc] initWithFrame:bounds andUUID:pageUUID];
        page.isBrandNewPage = NO;
        page.delegate = pageSidebarStack;
        [page disableAllGestures];

        // we might need to move assets from the original stack
        // into our own sidebar stack
        [self upgradeIfNecessary:page withMeta:pageMeta];

        // scale the page down. we can't initialize with this bounds,
        // because the initialied bounds is also our drawable resolution.
        CGRect scaledBounds = CGRectScale(bounds, kListPageZoom);

        [page setFrame:scaledBounds];

        [self addViewToCountableSidebar:page animated:NO];
    }

    hasLoaded = YES;
}

#pragma mark - For Content

- (CGSize)sizeOfRowForView:(UIView<MMUUIDView>*)view forWidth:(CGFloat)width {
    CGRect bounds = view.bounds;

    CGSize s = bounds.size;

    s.height = width * s.height / s.width;
    s.width = width;

    return s;
}

#pragma mark - For Content

- (Class)sidebarButtonClass {
    return [MMPagesSidebarButton class];
}

@end
