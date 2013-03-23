//
//  SLPaperViewDelegate.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SLPaperView;

@protocol SLPaperViewDelegate <NSObject>

/**
 * return YES if we allow the input page to
 * be scaled with a pinch gesture (top page),
 * otherwise return NO (non-top page)
 */
-(BOOL) allowsScaleForPage:(SLPaperView*)page;

/**
 * a notification that the input page is actively
 * being scaled and moved from the fromFrame to the
 * toFrame
 */
-(CGRect) isPanningAndScalingPage:(SLPaperView*)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame;

/**
 * this notification is triggered when the user finishes
 * scaling and moving the page. if the page has been
 * panned into a bezel gesture, then that bezel direction is also
 * included. the velocity of the page is also sent in, so that any
 * animation of "throwing" the page can be calculated
 */
-(void) finishedPanningAndScalingPage:(SLPaperView*)page intoBezel:(SLBezelDirection)direction fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame withVelocity:(CGPoint)velocity;

/**
 * this is triggered when the page has been scaled small
 * enough to begin transition into list view. the user will
 * still have control of the page's zoom, but other pages will
 * begin to follow its scale into list view
 */
-(void) isBeginningToScaleReallySmall:(SLPaperView*)page;

/**
 * the user has continued to scale the page down so far
 * that we can now take over and auto-scale it into list view
 */
-(void) finishedScalingReallySmall:(SLPaperView*)page;

/**
 * the user has already begun to scale small (notification above),
 * but now they've scaled large enough to cancel any auto
 * scale that we're doing for other nearby pages
 */
-(void) cancelledScalingReallySmall:(SLPaperView*)page;

/**
 * this is the parallel to finishedScalingReallySmall, except
 * that the user is scaling the page back up from list
 * view into page view. once it hits this method we will
 * auto-scale it into full page view.
 */
-(void) finishedScalingBackToPageView:(SLPaperView*)page;

/**
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
-(NSInteger) indexOfPageInCompleteStack:(SLPaperView*)page;

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
-(BOOL) isInVisibleStack:(SLPaperView*)page;

@end
