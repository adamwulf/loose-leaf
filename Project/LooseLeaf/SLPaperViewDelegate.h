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
 * enough to trigger a transition into list view
 */
-(void) isBeginningToScaleReallySmall:(SLPaperView*)page;

/**
 *
 */
-(void) finishedScalingReallySmall:(SLPaperView*)page;

-(void) cancelledScalingReallySmall:(SLPaperView*)page;

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
-(NSInteger) rowInListViewGivenIndex:(NSInteger) indexOfPage;
-(NSInteger) columnInListViewGivenIndex:(NSInteger) indexOfPage;
-(BOOL) isInVisibleStack:(SLPaperView*)page;

-(CGSize) sizeOfPaper;

@end
