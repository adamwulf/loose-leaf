//
//  PolygonTool.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/15/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "PolygonTool.h"
#import "Constants.h"

@implementation PolygonTool{
    NSMutableSet* polygonTouches;
}

@synthesize delegate;

-(id) init{
    if(self = [super init]){
        polygonTouches = [NSMutableSet set];
    }
    return self;
}

- (BOOL) willBeginStrokeWithTouch:(JotTouch*)touch{
    if(![polygonTouches count]){
        [delegate beginShapeWithTouch:touch.touch withTool:self];
        // return that we _do not_ want the JotView to draw
        [polygonTouches addObject:touch.touch];
    }
    return NO;
}

/**
 * a notification that the input is moving to the
 * next touch
 */
- (void) willMoveStrokeWithTouch:(JotTouch*)touch{
    if([polygonTouches containsObject:touch.touch]){
        [delegate continueShapeWithTouch:touch.touch withTool:self];
    }
}

/**
 * a notification that the input will end the
 * stroke
 */
- (void) willEndStrokeWithTouch:(JotTouch*)touch{
    if([polygonTouches containsObject:touch.touch]){
        [delegate finishShapeWithTouch:touch.touch withTool:self];
        [polygonTouches removeObject:touch.touch];
    }
}

/**
 * the stroke for the input touch will been cancelled.
 */
- (void) willCancelStroke:(JotStroke*)stroke withTouch:(JotTouch*)touch{
    if([polygonTouches containsObject:touch.touch]){
        [delegate cancelShapeWithTouch:touch.touch withTool:self];
        [polygonTouches removeObject:touch.touch];
    }
}


-(void) cancelPolygonForTouch:(UITouch*)touch{
    if([polygonTouches containsObject:touch]){
        [delegate cancelShapeWithTouch:touch withTool:self];
        [polygonTouches removeObject:touch];
    }
}

-(void) cancelAllTouches{
    for(UITouch* touch in [polygonTouches copy]){
        [self cancelPolygonForTouch:touch];
    }
}

@end
