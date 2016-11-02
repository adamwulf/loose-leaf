//
//  MMCollapsableStackView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/8/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMCollapsableStackView.h"
#import "MMLargeTutorialSidebarButton.h"
#import "AVHexColor.h"
#import "NSArray+Extras.h"

#define kMaxPageCountForRow 20
#define kCollapseAnimationDuration 0.3


@interface MMListPaperStackView (Protected)

- (CGRect)frameForListViewForPage:(MMPaperView*)page;

@end


@implementation MMCollapsableStackView {
    UIButton* expandButton;
}

@dynamic stackDelegate;

- (instancetype)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid {
    if (self = [super initWithFrame:frame andUUID:_uuid]) {
        expandButton = [[UIButton alloc] initWithFrame:self.bounds];
        expandButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [expandButton addTarget:self action:@selector(tapToExpandToListMode:) forControlEvents:UIControlEventTouchUpInside];
        expandButton.hidden = YES;
        [self addSubview:expandButton];
    }
    return self;
}

- (NSArray*)findPagesInVisibleRowsOfListView {
    if ([self.stackDelegate isShowingCollapsedView]) {
        // if we're collapsed, then we want to show the same pages
        // that would appear in our row view
        return [self pagesToAlignForRowView];
    } else {
        return [super findPagesInVisibleRowsOfListView];
    }
}

#pragma mark - Actions

- (void)tapToExpandToListMode:(UIButton*)button {
    [[self stackDelegate] didAskToSwitchToStack:[self uuid] animated:YES viewMode:kViewModeList];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y < -100) {
        // Need to turn off bouncing so that the bounce animation from releasing the over-scroll
        // doesn't occur. otherwise it interferes with the row animation.
        self.bounces = NO;
        // immediately set the content offset to zero, and adjust the position of the scroll view
        // so that the pages stay visibly in the same place. The animation into the row will
        // resize and reposition the scrollview as part of the animation, so we only need to make
        // sure that our initial position + size look correct at the start of the animation.
        CGRect fr = self.frame;
        fr.origin.y = -scrollView.contentOffset.y;
        self.frame = fr;
        self.contentOffset = CGPointZero;

        // when transitioning from list view, we need to save our current offset so that re-entering
        // the list will begin at the top.
        initialScrollOffsetFromTransitionToListView = CGPointZero;
        pagesThatWillBeVisibleAfterTransitionToListView = [self findPagesInVisibleRowsOfListViewGivenOffset:CGPointZero];
        [[self stackDelegate] didAskToCollapseStack:[self uuid] animated:YES];
    }
}

#pragma mark - Helper

- (NSArray*)pagesToAlignForRowView {
    NSMutableArray* pagesToAlignIntoRow = [NSMutableArray array];
    if ([[visibleStackHolder subviews] count] < kMaxPageCountForRow) {
        [pagesToAlignIntoRow addObjectsFromArray:[visibleStackHolder subviews]];
    } else if ([[visibleStackHolder subviews] count]) {
        [pagesToAlignIntoRow addObjectsFromArray:[[visibleStackHolder subviews] subarrayWithRange:NSMakeRange(0, kMaxPageCountForRow)]];
    }
    if ([[hiddenStackHolder subviews] count] < kMaxPageCountForRow - [pagesToAlignIntoRow count]) {
        [pagesToAlignIntoRow addObjectsFromArray:[[hiddenStackHolder subviews] reversedArray]];
    } else if ([[visibleStackHolder subviews] count]) {
        [pagesToAlignIntoRow addObjectsFromArray:[[[hiddenStackHolder subviews] reversedArray] subarrayWithRange:NSMakeRange(0, kMaxPageCountForRow - [pagesToAlignIntoRow count])]];
    }
    return pagesToAlignIntoRow;
}

#pragma mark - Animate into row form

/**
 * the user has scaled small enough with the top page
 * that we can take over and just animate the rest.
 *
 * so we need to cancel it's gestures, then calculate
 * the final resting place for every page in the visible
 * stack, then animate them.
 *
 * we're going to scale pages in the first two rows, and
 * we'll just slide any pages below that above the screen.
 *
 * when the animation completes, we'll adjust all the frames
 * and content offsets to that the user can scroll them
 */
- (void)organizePagesIntoSingleRowAnimated:(BOOL)animated {
    if ([self isShowingPageView]) {
        [self immediatelyTransitionToListView];
    }

    NSArray* pagesToAlignIntoRow = [self pagesToAlignForRowView];

    //
    // first, hide all pages that won't be visible during the row animation.
    void (^step1)(void) = ^{
        // Move the visible stack above the hidden stack. During list/page views, we want
        // the pages from the hidden stack to be visible above the pages in the visible stack,
        // but for the collapsed row we want the hidden pages to be lined up behind the top most page.
        visibleStackHolder.layer.zPosition = 1;

        [pagesToAlignIntoRow enumerateObjectsUsingBlock:^(MMPaperView* _Nonnull aPage, NSUInteger idx, BOOL* _Nonnull stop) {
            // The smooth border forces us to rasterize the page layer, so we want
            // to only set this to YES during page row mode, but never during list/page mode
            [aPage setSmoothBorder:YES];
            aPage.layer.zPosition = [pagesToAlignIntoRow count] - idx;
        }];
        //
        // immediately hide all of the pages that we won't be animating
        for (MMEditablePaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]) {
            if ([pagesToAlignIntoRow containsObject:aPage]) {
                // we'll animate these in step 2
                [[MMPageCacheManager sharedInstance] loadPageThumbnailToCache:aPage];
            } else {
                // we already have the last visible page, we're going to
                // hide all other pages during the animation, then re-show
                // them in their correct positions afterwards
                aPage.hidden = YES;
            }
        }

        // when we're in row mode, we don't let the user scroll at all, we become
        // a static button that can be tapped to expand. Scrolling the collapsed lists
        // is handled in a different scroll view in MMLooseLeafViewController.
        [self setScrollEnabled:NO];
        [expandButton setHidden:NO];
    };

    // now we're going to animate all of the pages into a single row.
    // to do that, we find the first + list frames for pages, and equally
    // spread the pages between those two frames
    CGRect firstFrame = [self frameForIndexInList:0];
    CGRect lastFrame = [self frameForIndexInList:kNumberOfColumnsInListView - 1];
    CGRect (^targetFrameInRowForPage)(MMPaperView* page) = ^(MMPaperView* aPage) {
        NSInteger minimumNumberOfPagesForSpacing = MAX(12, [pagesToAlignIntoRow count]);
        NSInteger indexInList = [pagesToAlignIntoRow indexOfObject:aPage];
        CGRect targetFrame = firstFrame;
        targetFrame.origin.x += (lastFrame.origin.x - firstFrame.origin.x) * ((CGFloat)indexInList / minimumNumberOfPagesForSpacing);
        return targetFrame;
    };

    // make sure all the pages go to the correct place
    // so that it looks like where they'll be in the row view
    void (^step2)(void) = ^{
        // animate all of the pages in the row to their final location.
        // we also rotate the pages slightly so that the view isn't
        // so sterile and boring.
        for (MMPaperView* aPage in pagesToAlignIntoRow) {
            // a UIView's frame takes into account its transform, but our
            // frames are set assuming an identity transform. let's enforce
            // the identity before setting the frame to make this explicit.
            aPage.transform = CGAffineTransformIdentity;
            aPage.frame = targetFrameInRowForPage(aPage);
            aPage.transform = CGAffineTransformMakeRotation(rand() % 100 / 100.0 * .05 - .025);
        }
        hiddenStackHolder.frame = visibleStackHolder.frame;
        listViewTutorialButton.alpha = 0;
        addPageButtonInListView.alpha = 0;
    };

    //
    // all of our pages are organized into a single row.
    //
    void (^step3)(BOOL finished) = ^(BOOL finished) {
        // ensure sane default for content size
        [self setContentSize:CGSizeMake(screenWidth, screenHeight)];
        listViewTutorialButton.alpha = 0;
        addPageButtonInListView.alpha = 0;

        [[NSUserDefaults standardUserDefaults] setObject:kViewModeCollapsed forKey:kCurrentViewMode];
    };

    step1();

    if (animated) {
        // ok, animate all the views in the visible stack!
        [UIView animateWithDuration:kCollapseAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:step2
                         completion:step3];
    } else {
        step2();
        step3(YES);
    }
    //
    // now that the user has finished the gesture,
    // we can forget about the original frame locations
}

/**
 * the user has scaled small enough with the top page
 * that we can take over and just animate the rest.
 *
 * so we need to cancel it's gestures, then calculate
 * the final resting place for every page in the visible
 * stack, then animate them.
 *
 * we're going to scale pages in the first two rows, and
 * we'll just slide any pages below that above the screen.
 *
 * when the animation completes, we'll adjust all the frames
 * and content offsets to that the user can scroll them
 */
- (void)organizePagesIntoListAnimated:(BOOL)animated {
    NSArray* pagesToAnimateIntoRow = [self pagesToAlignForRowView];

    //
    // first, find all pages behind the first full scale
    // page, and just move them immediately
    //
    // this helps pretty dramatically with the animation
    // performance.
    //
    // also, turn off gestures
    void (^step1)(void) = ^{
        expandButton.hidden = YES;
        //
        // immediately hide all of the pages that we won't be animating
        for (MMPaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]) {
            // unhide all pages that were hidden from being collapsed into a single row
            aPage.hidden = NO;
            if (![pagesToAnimateIntoRow containsObject:aPage]) {
                aPage.transform = CGAffineTransformIdentity;
                aPage.frame = [self frameForListViewForPage:aPage];
            }
        }
        // update the location of the add button in case any pages
        // were deleted/added since we last showed the stack in list mode
        [self moveAddButtonToTop];
    };

    //
    // make sure all the pages go to the correct place
    // so that it looks like where they'll be in the list view
    void (^step2)(void) = ^{
        //
        // animate all visible stack pages that will be in the
        // visible frame to the correct place
        for (MMPaperView* aPage in pagesToAnimateIntoRow) {
            // these views we're animating into place
            aPage.transform = CGAffineTransformIdentity;
            aPage.frame = [self frameForListViewForPage:aPage];
        }
        hiddenStackHolder.frame = visibleStackHolder.frame;
        // fade in the add/tutorial buttons
        listViewTutorialButton.alpha = 1;
        addPageButtonInListView.alpha = 1;
        [self setButtonsVisible:NO animated:NO];
    };

    //
    // all of the pages "look" like they're in the right place,
    // but we need to turn on the scroll view.
    void (^step3)(BOOL finished) = ^(BOOL finished) {
        //
        // this means we need to keep the pages visually in the same place,
        // but adjust their frames and the content size/offset so
        // that the scrollview works.
        for (MMPaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]) {
            // gestures aren't allowed in row view
            [aPage disableAllGestures];
        }
        // set our content height/offset for the pages
        [self setContentOffset:CGPointZero animated:NO];
        [self setContentSize:CGSizeMake(screenWidth, [self contentHeightForAllPages])];
        [self finishUITransitionToListView];
        [self moveAddButtonToTop];

        // in list and page mode, the hidden stack pages should show above
        // the visible stack pages
        visibleStackHolder.layer.zPosition = 0;

        [pagesToAnimateIntoRow enumerateObjectsUsingBlock:^(MMPaperView* _Nonnull aPage, NSUInteger idx, BOOL* _Nonnull stop) {
            [aPage setSmoothBorder:NO];
            aPage.layer.zPosition = 0;
        }];

        // now that we're back into list mode, we need to re-enable scrolling + bounce
        [self setBounces:YES];
        [self setScrollEnabled:YES];

        // update our view mode
        [[NSUserDefaults standardUserDefaults] setObject:kViewModeList forKey:kCurrentViewMode];
    };

    step1();

    if (animated) {
        // ok, animate all the views in the visible stack!
        [UIView animateWithDuration:kCollapseAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:step2
                         completion:step3];
    } else {
        step2();
        step3(YES);
    }
    //
    // now that the user has finished the gesture,
    // we can forget about the original frame locations
}

@end
