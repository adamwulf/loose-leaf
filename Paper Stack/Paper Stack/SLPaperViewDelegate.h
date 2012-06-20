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

@end
