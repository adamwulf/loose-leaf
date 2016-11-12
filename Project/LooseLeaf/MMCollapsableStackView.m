//
//  MMCollapsableStackView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/8/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMCollapsableStackView.h"
#import "MMLargeTutorialSidebarButton.h"
#import "MMFeedbackButton.h"
#import "MMContinuousSwipeGestureRecognizer.h"
#import "MMDeleteButton.h"
#import "MMConfirmDeleteStackButton.h"
#import "MMConfirmDeleteStackButtonDelegate.h"
#import "AVHexColor.h"
#import "NSArray+Extras.h"
#import "UIScreen+MMSizing.h"
#import "MMTrashButton.h"

#define kMaxPageCountForRow 20
#define kCollapseAnimationDuration 0.3


@interface MMListPaperStackView (Protected) <UIGestureRecognizerDelegate, MMConfirmDeleteStackButtonDelegate>

@property (nonatomic, strong) NSString* currentViewMode;

- (CGRect)frameForListViewForPage:(MMPaperView*)page;

@end


@implementation MMCollapsableStackView {
    UIButton* expandButton;
    MMContinuousSwipeGestureRecognizer* deleteGesture;
    CGFloat squishFactor;
    CGFloat initialAdjustment;
    MMTrashButton* deleteButton;

    MMConfirmDeleteStackButton* deleteConfirmationPlaceholder;
}

@dynamic stackDelegate;

- (instancetype)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid {
    if (self = [super initWithFrame:frame andUUID:_uuid]) {
        expandButton = [[UIButton alloc] initWithFrame:self.bounds];
        expandButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [expandButton addTarget:self action:@selector(tapToExpandToListMode:) forControlEvents:UIControlEventTouchUpInside];
        expandButton.hidden = YES;
        [self addSubview:expandButton];

        deleteGesture = [[MMContinuousSwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deleteGesture:)];
        deleteGesture.delegate = self;
        deleteGesture.angleBuffer = 30;
        deleteGesture.enabled = NO;
        [self addGestureRecognizer:deleteGesture];

        CGFloat buffer = [MMListPaperStackView bufferWidth];
        CGFloat rowHeight = [MMListPaperStackView rowHeight] + 2 * buffer;
        CGFloat deleteButtonWidth = 80;
        CGRect deleteRect = CGRectMake(self.bounds.size.width - 3 * buffer - deleteButtonWidth, (rowHeight - deleteButtonWidth) / 2, deleteButtonWidth, deleteButtonWidth);
        deleteButton = [[MMTrashButton alloc] initWithFrame:deleteRect];
        [deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.alpha = 0;
        [self addSubview:deleteButton];

        CGRect confirmationRect = CGRectMake(0, 0, self.bounds.size.width, rowHeight);

        deleteConfirmationPlaceholder = [[MMConfirmDeleteStackButton alloc] initWithFrame:confirmationRect];
        deleteConfirmationPlaceholder.delegate = self;
        [self addSubview:deleteConfirmationPlaceholder];
    }
    return self;
}

- (void)setCurrentViewMode:(NSString*)currentViewMode {
    [super setCurrentViewMode:currentViewMode];
    deleteGesture.enabled = [self isShowingCollapsedView];
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

- (BOOL)isPerfectlyAlignedIntoRow {
    return squishFactor == 0;
}

- (void)cancelPendingConfirmationsAndResetToRow {
    if (![self isPerfectlyAlignedIntoRow]) {
        deleteGesture.enabled = YES;
        squishFactor = .15;
        [self finishSwipeToDelete:YES sendingDelegateNotifications:NO];
    }
}

#pragma mark - Actions

- (void)tapToExpandToListMode:(UIButton*)button {
    [[self stackDelegate] didAskToSwitchToStack:[self uuid] animated:YES viewMode:kViewModeList];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    if ([scrollView isDragging] && (scrollView.contentOffset.y < -50)) {
        [[self stackDelegate] mightAskToCollapseStack:[self uuid]];
    }
    [super scrollViewDidScroll:scrollView];
}

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
    } else {
        [[self stackDelegate] didNotAskToCollapseStack:[self uuid]];
    }

    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
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

- (CGRect)targetFrameInRowForPage:(MMPaperView*)aPage givenAllPages:(NSArray*)pagesToAlignIntoRow {
    // now we're going to animate all of the pages into a single row.
    // to do that, we find the first + list frames for pages, and equally
    // spread the pages between those two frames
    CGRect firstFrame = [self frameForIndexInList:0];
    CGRect lastFrame = [self frameForIndexInList:kNumberOfColumnsInListView - 1];
    NSInteger minimumNumberOfPagesForSpacing = MAX(12, [pagesToAlignIntoRow count]) - 1;
    NSInteger indexInList = [pagesToAlignIntoRow indexOfObject:aPage];
    CGRect targetFrame = firstFrame;
    targetFrame.origin.x += (lastFrame.origin.x - firstFrame.origin.x) * ((CGFloat)indexInList / minimumNumberOfPagesForSpacing);
    return targetFrame;
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
- (void)organizePagesIntoSingleRowAnimated:(BOOL)animated {
    if ([self isShowingPageView]) {
        [self immediatelyTransitionToListView];
    }

    NSArray* pagesToAlignIntoRow = [self pagesToAlignForRowView];
    [self setCurrentViewMode:kViewModeCollapsed];

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

    // make sure all the pages go to the correct place
    // so that it looks like where they'll be in the row view
    void (^step2)(void) = ^{
        // animate all of the pages in the row to their final location.
        // we also rotate the pages slightly so that the view isn't
        // so sterile and boring.
        for (NSInteger index = 0; index < [pagesToAlignIntoRow count]; index++) {
            MMPaperView* aPage = pagesToAlignIntoRow[index];
            // a UIView's frame takes into account its transform, but our
            // frames are set assuming an identity transform. let's enforce
            // the identity before setting the frame to make this explicit.
            aPage.transform = CGAffineTransformIdentity;
            aPage.frame = [self targetFrameInRowForPage:aPage givenAllPages:pagesToAlignIntoRow];
            aPage.transform = CGAffineTransformMakeRotation(RandomCollapsedPageRotation([[aPage uuid] hash]));
        }
        hiddenStackHolder.frame = visibleStackHolder.frame;
        listViewTutorialButton.alpha = 0;
        listViewFeedbackButton.alpha = 0;
        addPageButtonInListView.alpha = 0;
        deleteConfirmationPlaceholder.alpha = 0;
    };

    //
    // all of our pages are organized into a single row.
    //
    void (^step3)(BOOL finished) = ^(BOOL finished) {
        // ensure sane default for content size
        [self setContentSize:CGSizeMake([UIScreen screenWidth], [UIScreen screenHeight])];
        listViewTutorialButton.alpha = 0;
        listViewFeedbackButton.alpha = 0;
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
        listViewFeedbackButton.alpha = 1;
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
            aPage.layer.zPosition = 0;
            [aPage setSmoothBorder:NO];
        }
        // set our content height/offset for the pages
        [self setContentOffset:CGPointZero animated:NO];
        [self setContentSize:CGSizeMake([UIScreen screenWidth], [self contentHeightForAllPages])];
        [self finishUITransitionToListView];
        [self moveAddButtonToTop];

        // in list and page mode, the hidden stack pages should show above
        // the visible stack pages
        visibleStackHolder.layer.zPosition = 0;

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

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
    return YES;
}

#pragma mark - Delete Inbox Items

- (void)deleteGesture:(MMContinuousSwipeGestureRecognizer*)sender {
    if (![[self stackDelegate] isAllowedToInteractWithStack:[self uuid]]) {
        // cancel the gesture
        [sender setEnabled:NO];
        [sender setEnabled:YES];
        return;
    }
    if (sender.state == UIGestureRecognizerStateBegan) {
        // notify other stacks to cancel their delete gesture if any
        // also, don't let the user swipe to delete and scroll the stacks at the same time
        [[self stackDelegate] isPossiblyDeletingStack:self.uuid withPendingProbability:0];
        deleteConfirmationPlaceholder.alpha = 0;

        initialAdjustment = squishFactor;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGRect firstFrame = [self frameForIndexInList:0];
        CGRect lastFrame = [self frameForIndexInList:kNumberOfColumnsInListView - 1];
        CGFloat amount = -sender.distanceSinceBegin.x; // negative, because we're moving left
        CGFloat updatedSquish = initialAdjustment + amount / (CGRectGetMidX(lastFrame) - CGRectGetMidX(firstFrame));
        [self adjustForDelete:updatedSquish withTranslate:0];
        [[self stackDelegate] isPossiblyDeletingStack:self.uuid withPendingProbability:MAX(0, updatedSquish - .3) * 1.8];
        deleteButton.alpha = MIN(.2, MAX(0, updatedSquish)) / .2;
    } else if (sender.state == UIGestureRecognizerStateEnded ||
               sender.state == UIGestureRecognizerStateCancelled) {
        // enable scrolling stack list
        [self finishSwipeToDelete:NO sendingDelegateNotifications:YES];
    }
}


// must be called after adjustForDelete
- (BOOL)finishSwipeToDelete:(BOOL)longerDuration sendingDelegateNotifications:(BOOL)sendDelegateNotifications {
    if (squishFactor < .2) {
        // bounce back to zero and hide delete button
        [UIView animateWithDuration:longerDuration ? .4 : .2 animations:^{
            CGFloat bounce = ABS(squishFactor * .2);
            [self adjustForDelete:(squishFactor < 0) ? bounce : -bounce withTranslate:0];
            if (sendDelegateNotifications) {
                [self.stackDelegate isNotGoingToDeleteStack:self.uuid];
            }
            deleteButton.alpha = 0;
            deleteConfirmationPlaceholder.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:longerDuration ? .2 : .1 animations:^{
                [self adjustForDelete:0 withTranslate:0];
            }];
        }];
        return NO;
    } else if (squishFactor > .6) {
        // bypass tapping the delete button and just
        // delete immediately
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self adjustForDelete:1 withTranslate:-250];
            deleteButton.alpha = 0;
            deleteConfirmationPlaceholder.alpha = 1;
        } completion:nil];
        [UIView animateWithDuration:.2 delay:.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (sendDelegateNotifications) {
                [self.stackDelegate isNotGoingToDeleteStack:self.uuid];
            }
        } completion:nil];
        deleteGesture.enabled = NO;
        return YES;
    } else {
        // bounce to show delete button
        CGFloat targetToShowButtons = .2;
        [UIView animateWithDuration:.2 animations:^{
            CGFloat bounce = MIN(ABS(targetToShowButtons - squishFactor) * .2, 20);
            [self adjustForDelete:(squishFactor < targetToShowButtons) ? (targetToShowButtons + bounce) : (targetToShowButtons - bounce) withTranslate:0];
            if (sendDelegateNotifications) {
                [self.stackDelegate isNotGoingToDeleteStack:self.uuid];
            }
            deleteButton.alpha = 1.0;
            deleteConfirmationPlaceholder.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.1 animations:^{
                [self adjustForDelete:targetToShowButtons withTranslate:0];
            }];
        }];
        return NO;
    }
}

- (void)adjustForDelete:(CGFloat)adjustment withTranslate:(CGFloat)xTranslate {
    if ([self.layer.animationKeys count]) {
        [self.layer removeAllAnimations];
    }

    squishFactor = MAX(-0.2, adjustment);
    CGFloat easedOut = adjustment;
    if (easedOut < 0) {
        easedOut = MAX(easedOut, -0.8);
        easedOut = MAX(easedOut + .8, 0) / .8;
        easedOut = 1 - easedOut * easedOut * easedOut;
        easedOut = easedOut * -.2;
    }

    [self setClipsToBounds:squishFactor == 0];
    [expandButton setEnabled:squishFactor == 0];
    [deleteButton setEnabled:squishFactor > 0];

    CGFloat alphaForDelete = adjustment - .5;
    alphaForDelete = MAX(alphaForDelete, 0);
    alphaForDelete /= .4;
    alphaForDelete = MIN(alphaForDelete, 1.0);
    //    deleteButton.alpha = alphaForDelete;

    CGRect frameAtStart = [self frameForIndexInList:0];

    NSArray* pagesToAlign = [self pagesToAlignForRowView];
    for (int i = 0; i < [pagesToAlign count]; i++) {
        MMPaperView* aPage = pagesToAlign[i];
        CGFloat ix = CGRectGetMidX([self targetFrameInRowForPage:aPage givenAllPages:pagesToAlign]);
        CGFloat fx = CGRectGetMidX(frameAtStart) - 120 + i * 4;
        CGFloat diff = fx - ix;
        CGFloat x = ix + diff * easedOut;

        aPage.center = CGPointMake(x + xTranslate, CGRectGetMidY(frameAtStart) + (RandomMod(i, 80) - 40) * easedOut);

        aPage.transform = CGAffineTransformMakeRotation(RandomCollapsedPageRotation([[aPage uuid] hash]) + easedOut * 5 * RandomPhotoRotation([[aPage uuid] hash]));
    }
}

- (IBAction)deleteButtonTapped:(id)sender {
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self adjustForDelete:.9 withTranslate:0];
    } completion:nil];
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [[self stackDelegate] isPossiblyDeletingStack:self.uuid withPendingProbability:1.0];
        deleteButton.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.stackDelegate isNotGoingToDeleteStack:self.uuid];
            [self adjustForDelete:1.0 withTranslate:-250];
        } completion:nil];
    }];
    [UIView animateWithDuration:.3 delay:.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        deleteConfirmationPlaceholder.alpha = 1;
    } completion:nil];
    deleteGesture.enabled = NO;
}

#pragma mark - MMConfirmDeleteStackButtonDelegate

- (void)didConfirmToDeleteStack {
    deleteGesture.enabled = YES;
    squishFactor = 0;
    [self.stackDelegate isAskingToDeleteStack:self.uuid];
}

- (void)didCancelDeletingStack {
    deleteGesture.enabled = YES;
    squishFactor = .15;
    [self finishSwipeToDelete:YES sendingDelegateNotifications:YES];
}

#pragma mark - Row Animation Helpers

- (void)squashPagesWhenInRowView:(CGFloat)squash withTranslate:(CGFloat)translate {
    if (![[self currentViewMode] isEqualToString:kViewModeCollapsed]) {
        @throw [NSException exceptionWithName:@"CollapsedException" reason:@"Cannot squash pages outside of row view" userInfo:nil];
    }
    [self adjustForDelete:squash withTranslate:translate];
}

- (CGPoint)effectiveRowCenter {
    NSArray* pagesToAlign = [self pagesToAlignForRowView];

    if ([pagesToAlign count]) {
        MMPaperView* firstPage = pagesToAlign[0];
        MMPaperView* lastPage = pagesToAlign[[pagesToAlign count] - 1];
        CGFloat diffx = lastPage.center.x - firstPage.center.x;
        CGFloat diffy = lastPage.center.y - firstPage.center.y;
        return CGPointMake(firstPage.center.x + diffx / 2, firstPage.center.y + diffy / 2);
    } else {
        return CGRectGetMidPoint([self bounds]);
    }
}

@end
