//
//  Tool.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/15/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "Tool.h"
#import "Constants.h"


@implementation Tool

- (CGFloat)widthForCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)jotView {
    @throw kAbstractMethodException;
}

- (JotBrushTexture*)textureForStroke {
    @throw kAbstractMethodException;
}

- (CGFloat)stepWidthForStroke {
    @throw kAbstractMethodException;
}

- (UIColor*)colorForCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)jotView {
    @throw kAbstractMethodException;
}

- (BOOL)supportsRotation {
    @throw kAbstractMethodException;
}

- (CGFloat)smoothnessForCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)jotView {
    @throw kAbstractMethodException;
}

- (CGFloat)rotationForSegment:(AbstractBezierPathElement*)segment fromPreviousSegment:(AbstractBezierPathElement*)previousSegment {
    @throw kAbstractMethodException;
}

- (BOOL)willBeginStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)jotView {
    @throw kAbstractMethodException;
}

- (void)willMoveStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)jotView {
    @throw kAbstractMethodException;
}

- (void)willEndStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch shortStrokeEnding:(BOOL)shortStrokeEnding inJotView:(JotView*)jotView {
    @throw kAbstractMethodException;
}

- (void)didEndStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)jotView {
    @throw kAbstractMethodException;
}

- (void)willCancelStroke:(JotStroke*)stroke withCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)jotView {
    @throw kAbstractMethodException;
}

- (void)didCancelStroke:(JotStroke*)stroke withCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)jotView {
    @throw kAbstractMethodException;
}

- (NSArray*)willAddElements:(NSArray*)elements toStroke:(JotStroke*)stroke fromPreviousElement:(AbstractBezierPathElement*)previousElement inJotView:(JotView*)jotView {
    @throw kAbstractMethodException;
}

@end
