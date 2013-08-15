//
//  PolygonTool.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/15/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "PolygonTool.h"
#import "Constants.h"

@implementation PolygonTool

- (BOOL) willBeginStrokeWithTouch:(JotTouch*)touch{
    debug_NSLog(@"will begin poly");
    // return that we _do not_ want the JotView to draw
    return NO;
}

/**
 * a notification that the input is moving to the
 * next touch
 */
- (void) willMoveStrokeWithTouch:(JotTouch*)touch{
    debug_NSLog(@"will move poly");
}

/**
 * a notification that the input will end the
 * stroke
 */
- (void) willEndStrokeWithTouch:(JotTouch*)touch{
    debug_NSLog(@"will end poly");
}

/**
 * the stroke for the input touch will been cancelled.
 */
- (void) willCancelStrokeWithTouch:(JotTouch*)touch{
    debug_NSLog(@"will cancel poly");
}

@end
