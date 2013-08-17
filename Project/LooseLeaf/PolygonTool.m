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
    [delegate beginShapeWithTouch:touch.touch];
    // return that we _do not_ want the JotView to draw
    [polygonTouches addObject:touch.touch];
    return NO;
}

/**
 * a notification that the input is moving to the
 * next touch
 */
- (void) willMoveStrokeWithTouch:(JotTouch*)touch{
    if([polygonTouches containsObject:touch.touch]){
        [delegate continueShapeWithTouch:touch.touch];
    }
}

/**
 * a notification that the input will end the
 * stroke
 */
- (void) willEndStrokeWithTouch:(JotTouch*)touch{
    if([polygonTouches containsObject:touch.touch]){
        [delegate finishShapeWithTouch:touch.touch];
        [polygonTouches removeObject:touch.touch];
    }
}

/**
 * the stroke for the input touch will been cancelled.
 */
- (void) willCancelStrokeWithTouch:(JotTouch*)touch{
    if([polygonTouches containsObject:touch.touch]){
        [delegate cancelShapeWithTouch:touch.touch];
        [polygonTouches removeObject:touch.touch];
    }
}


-(void) cancelPolygonForTouch:(UITouch*)touch{
    if([polygonTouches containsObject:touch]){
        [delegate cancelShapeWithTouch:touch];
        [polygonTouches removeObject:touch];
    }
}

@end
