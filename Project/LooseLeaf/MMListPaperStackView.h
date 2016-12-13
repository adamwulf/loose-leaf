//
//  MMListPaperStackView.h
//  Loose Leaf
//
//  Created by Adam Wulf on 7/3/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperStackView.h"
#import <QuartzCore/QuartzCore.h>
#import "MMStretchPageGestureRecognizer.h"
#import "MMLongPressFromListViewGestureRecognizer.h"
#import "MMListAddPageButton.h"
#import "MMListAddPageButtonDelegate.h"
#import "MMButtonAwareTapGestureRecognizer.h"
#import "MMPageCacheManagerDelegate.h"
#import "MMDeletePageSidebarController.h"
#import "MMInboxManagerDelegate.h"
#import "MMButtonToolbarView.h"


@interface MMListPaperStackView : MMPaperStackView <MMStretchPageGestureRecognizerDelegate, MMListAddPageButtonDelegate, MMPageCacheManagerDelegate, UIScrollViewDelegate> {
    //
    // when beginning a zoom, we need to save the
    // frames of all the pages we'll be animating
    //
    // then we'll use that saved frame value to
    // animate between it's final state
    NSMutableDictionary* setOfInitialFramesForPagesBeingZoomed;

    MMStretchPageGestureRecognizer* pinchGesture;
    MMLongPressFromListViewGestureRecognizer* longPressGesture;

    CGPoint initialScrollOffsetFromTransitionToListView;
    NSArray* pagesThatWillBeVisibleAfterTransitionToListView;

    // the point in the view's coordinates (not scroll offset)
    // of the drag gesture in list view
    CGPoint lastDragPoint;
    MMPaperView* pageBeingDragged;
    CADisplayLink* displayLink;
    BOOL realizedThatPageIsBeingDragged;

    MMListAddPageButton* addPageButtonInListView;
}

+ (CGFloat)columnWidth;
+ (CGFloat)rowHeight;
+ (CGFloat)bufferWidth;

@property (nonatomic, strong) MMDeletePageSidebarController* deleteSidebar;
@property (nonatomic, readonly) MMButtonToolbarView* toolbar;
@property (nonatomic, readonly) BOOL isAnimatingTowardPageView;
@property (nonatomic, readonly) NSString* currentViewMode;

- (CGPoint)offsetNeededToShowPage:(MMPaperView*)page;
- (NSArray*)findPagesInVisibleRowsOfListViewGivenOffset:(CGPoint)eventualOffsetOfListView;

// returns yes if the imported page was handled
- (BOOL)importAndShowPage:(MMExportablePaperView*)page;

- (CGPoint)addPageBackToListViewAndAnimateOtherPages:(MMPaperView*)page;

// protected

- (void)immediatelyTransitionToListView NS_REQUIRES_SUPER;

- (void)immediatelyTransitionToPageViewAnimated:(BOOL)animated NS_REQUIRES_SUPER;

- (void)beginUITransitionFromPageView NS_REQUIRES_SUPER;

- (void)beginUITransitionFromListView NS_REQUIRES_SUPER;

- (void)finishUITransitionToListView NS_REQUIRES_SUPER;

- (void)finishUITransitionToPageView NS_REQUIRES_SUPER;

- (void)deletePage:(MMPaperView*)page NS_REQUIRES_SUPER;

- (void)transitionFromListToNewBlankPageIfInPageView NS_REQUIRES_SUPER;

- (CGFloat)contentHeightForAllPages NS_REQUIRES_SUPER;

- (void)moveAddButtonToBottom NS_REQUIRES_SUPER;

- (void)moveAddButtonToTop NS_REQUIRES_SUPER;

- (void)subclassBeforeTransitionToListView NS_REQUIRES_SUPER;

- (void)subclassDuringTransitionToListView NS_REQUIRES_SUPER;

- (void)tutorialShouldOpen:(NSNotification*)note NS_REQUIRES_SUPER;

- (void)tutorialShouldClose:(NSNotification*)note NS_REQUIRES_SUPER;

- (CGRect)frameForIndexInList:(NSInteger)indexOfPage NS_REQUIRES_SUPER;

- (CGRect)frameForListViewForPage:(MMPaperView*)page NS_REQUIRES_SUPER;

- (void)didPickUpAPageInListView:(MMLongPressFromListViewGestureRecognizer*)gesture NS_REQUIRES_SUPER;

@end
