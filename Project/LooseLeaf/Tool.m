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

- (CGFloat) widthForTouch:(JotTouch *)touch{
    @throw kAbstractMethodException;
}

- (UIColor*) colorForTouch:(JotTouch *)touch{
    @throw kAbstractMethodException;
}

- (CGFloat) smoothnessForTouch:(JotTouch *)touch{
    @throw kAbstractMethodException;
}

- (CGFloat) rotationForSegment:(AbstractBezierPathElement *)segment fromPreviousSegment:(AbstractBezierPathElement *)previousSegment{
    @throw kAbstractMethodException;
}

- (BOOL) willBeginStrokeWithTouch:(JotTouch*)touch{
    @throw kAbstractMethodException;
}

- (void) willMoveStrokeWithTouch:(JotTouch*)touch{
    @throw kAbstractMethodException;
}

- (void) willEndStrokeWithTouch:(JotTouch*)touch{
    @throw kAbstractMethodException;
}

- (void) didEndStrokeWithTouch:(JotTouch *)touch{
    @throw kAbstractMethodException;
}

- (void) willCancelStrokeWithTouch:(JotTouch*)touch{
    @throw kAbstractMethodException;
}

- (void) didCancelStrokeWithTouch:(JotTouch *)touch{
    @throw kAbstractMethodException;
}

- (NSArray*) willAddElementsToStroke:(NSArray *)elements fromPreviousElement:(AbstractBezierPathElement *)previousElement{
    @throw kAbstractMethodException;
}

@end
