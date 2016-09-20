//
//  PolygonTool.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/15/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "PolygonTool.h"
#import "Constants.h"


@implementation PolygonTool {
    NSMutableSet* polygonTouches;
}

@synthesize delegate;

- (id)init {
    if (self = [super init]) {
        polygonTouches = [NSMutableSet set];
    }
    return self;
}

- (BOOL)willBeginStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch {
    if (![polygonTouches count]) {
        [delegate beginShapeWithTouch:touch withTool:self];
        // return that we _do not_ want the JotView to draw
        [polygonTouches addObject:coalescedTouch];
    }
    return NO;
}

/**
 * a notification that the input is moving to the
 * next touch
 */
- (void)willMoveStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch {
    if ([polygonTouches containsObject:touch]) {
        [delegate continueShapeWithTouch:coalescedTouch withTool:self];
    }
}

/**
 * a notification that the input will end the
 * stroke
 */
- (void)willEndStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch shortStrokeEnding:(BOOL)shortStrokeEnding {
    if ([polygonTouches containsObject:touch]) {
        [delegate finishShapeWithTouch:coalescedTouch withTool:self];
        [polygonTouches removeObject:touch];
    }
}

/**
 * the stroke for the input touch will been cancelled.
 */
- (void)willCancelStroke:(JotStroke*)stroke withCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch {
    if ([polygonTouches containsObject:touch]) {
        [delegate cancelShapeWithTouch:touch withTool:self];
        [polygonTouches removeObject:touch];
    }
}


- (void)cancelPolygonForTouch:(UITouch*)touch {
    if ([polygonTouches containsObject:touch]) {
        [delegate cancelShapeWithTouch:touch withTool:self];
        [polygonTouches removeObject:touch];
    }
}

- (void)cancelAllTouches {
    for (UITouch* touch in [polygonTouches copy]) {
        [self cancelPolygonForTouch:touch];
    }
}

@end
