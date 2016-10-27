//
//  MMRulerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/10/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JotUI/JotUI.h>
#import "MMRulerAdjustment.h"


@interface MMRulerView : UIView

@property (nonatomic) JotView* jotView;

- (void)updateLineAt:(CGPoint)p1 to:(CGPoint)p2 startingDistance:(CGFloat)distance;

- (void)liftRuler;

- (MMRulerAdjustment*)adjustElementsToStroke:(NSArray*)elements fromPreviousElement:(AbstractBezierPathElement*)previousElement;

- (void)willBeginStrokeAt:(CGPoint)point;

- (void)willMoveStrokeAt:(CGPoint)point;

- (CGPoint)adjustPoint:(CGPoint)inputPoint andDidAdjust:(BOOL*)didAdjust;

- (UIBezierPath*)findPathSegmentsWithNearestStart:(CGPoint)nearestStart andNearestEnd:(CGPoint)nearestEnd;

- (BOOL)rulerIsVisible;

@end
