//
//  MMPaperViewDelegate.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JotUI/JotUI.h>

@class MMPaperView,MMRulerToolGestureRecognizer,MMScrapView;

@protocol MMPaperViewDelegate <JotViewDelegate>

#pragma mark Scale

/**
 * return YES if we allow the input page to
 * be scaled with a pinch gesture (top page),
 * otherwise return NO (non-top page)
 */
-(BOOL) allowsScaleForPage:(MMPaperView*)page;

/**
 * a notification that the input page is actively
 * being scaled and moved from the fromFrame to the
 * toFrame
 */
-(CGRect) isBeginning:(BOOL)isBeginningGesture toPanAndScalePage:(MMPaperView*)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame withTouches:(NSArray*)touches;

/**
 * this notification is triggered when the user finishes
 * scaling and moving the page. if the page has been
 * panned into a bezel gesture, then that bezel direction is also
 * included. the velocity of the page is also sent in, so that any
 * animation of "throwing" the page can be calculated
 */
-(void) finishedPanningAndScalingPage:(MMPaperView*)page intoBezel:(MMBezelDirection)direction fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame withVelocity:(CGPoint)velocity;

/**
 * a notification that the page is beginning to move a scrap
 * of paper on the page
 */
-(void) isBeginning:(BOOL)isBeginningGesture toPanAndScaleScrap:(MMScrapView*)scrap withTouches:(NSArray*)touches;

/**
 * this is triggered when the page has been scaled small
 * enough to begin transition into list view. the user will
 * still have control of the page's zoom, but other pages will
 * begin to follow its scale into list view
 */
-(void) isBeginningToScaleReallySmall:(MMPaperView*)page;

/**
 * the user has continued to scale the page down so far
 * that we can now take over and auto-scale it into list view
 */
-(void) finishedScalingReallySmall:(MMPaperView*)page;

/**
 * the user has already begun to scale small (notification above),
 * but now they've scaled large enough to cancel any auto
 * scale that we're doing for other nearby pages
 */
-(void) cancelledScalingReallySmall:(MMPaperView*)page;

/**
 * this is the parallel to finishedScalingReallySmall, except
 * that the user is scaling the page back up from list
 * view into page view. once it hits this method we will
 * auto-scale it into full page view.
 */
-(void) finishedScalingBackToPageView:(MMPaperView*)page;

#pragma mark List View

/**
 * Performance optimization:
 * the index, row, and column are all computed separately,
 * and within the list class instead of the page class.
 * this is because finding the index is expensive, and
 * i would have to do re-calculate that if i kept this in the
 * page.
 *
 * returns the index of the page within the total
 * stack of visible and hidden stacks.
 *
 * the index for a visible page is its index in
 * visibleStackHolder subviews
 *
 * the index for a hidden page is the count of
 * all visible pages + the index in the hidden
 * stack
 */
-(NSInteger) indexOfPageInCompleteStack:(MMPaperView*)page;

/**
 * this will return the row number of this page, if we were to
 * find it in list view
 */
-(NSInteger) rowInListViewGivenIndex:(NSInteger) indexOfPage;

/**
 * this will return the column number of the page, if we were to
 * find it in list view
 */
-(NSInteger) columnInListViewGivenIndex:(NSInteger) indexOfPage;

/**
 * returns true if the page is in the logical "lefthand" stack
 * of the two stacks.
 */
-(BOOL) isInVisibleStack:(MMPaperView*)page;

#pragma mark Saving and Drawing

/**
 * called after a page gets saved
 * to disk
 */
-(void) didSavePage:(MMPaperView*)page;


-(BOOL) isPageEditable:(MMPaperView*)page;

#pragma mark Ruler

/**
 * return YES if the page should allow pan
 */
-(BOOL) shouldAllowPan:(MMPaperView*)page;

/**
 * called when the ruler begins and when it moves
 */
-(void) didMoveRuler:(MMRulerToolGestureRecognizer*)gesture;

/**
 * called when the user stops the ruler gesture
 */
-(void) didStopRuler:(MMRulerToolGestureRecognizer*)gesture;


@end
