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

-(JotBrushTexture*) textureForStroke{
    @throw kAbstractMethodException;
}

-(CGFloat) stepWidthForStroke{
    @throw kAbstractMethodException;
}

- (UIColor*) colorForTouch:(JotTouch *)touch{
    @throw kAbstractMethodException;
}

-(BOOL) supportsRotation{
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

- (void) willCancelStroke:(JotStroke*)stroke withTouch:(JotTouch*)touch{
    @throw kAbstractMethodException;
}

- (void) didCancelStroke:(JotStroke*)stroke withTouch:(JotTouch *)touch{
    @throw kAbstractMethodException;
}

- (NSArray*) willAddElements:(NSArray *)elements toStroke:(JotStroke *)stroke fromPreviousElement:(AbstractBezierPathElement *)previousElement{
    @throw kAbstractMethodException;
}

@end
