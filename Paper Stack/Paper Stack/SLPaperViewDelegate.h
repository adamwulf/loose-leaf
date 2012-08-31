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

-(BOOL) allowsScaleForPage:(SLPaperView*)page;

-(CGRect) isPanningAndScalingPage:(SLPaperView*)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame;

-(void) finishedPanningAndScalingPage:(SLPaperView*)page intoBezel:(SLBezelDirection)direction fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame withVelocity:(CGPoint)velocity;

-(void) isBeginningToScaleReallySmall:(SLPaperView*)page;

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

-(BOOL) isInVisibleStack:(SLPaperView*)page;

@end
