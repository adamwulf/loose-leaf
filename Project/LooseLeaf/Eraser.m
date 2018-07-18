//
//  Eraser.m
//  jotuiexample
//
//  Created by Adam Wulf on 1/9/13.
//  Copyright (c) 2013 Adonit. All rights reserved.
//

#import "Eraser.h"
#import "Constants.h"


@implementation Eraser {
    BOOL shortStrokeEnding;
}

- (id)init {
    return [self initWithMinSize:12.0 andMaxSize:180.0 andMinAlpha:1.0 andMaxAlpha:1.0];
}

/**
 * delegate method - a notification from the JotView
 * that a new touch is about to be processed. we should
 * reset all of our counters/etc to base values
 */
- (BOOL)willBeginStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)jotView {
    [super willBeginStrokeWithCoalescedTouch:coalescedTouch fromTouch:touch inJotView:jotView];
    velocity = 0;
    return YES;
}

- (void)willEndStrokeWithCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch shortStrokeEnding:(BOOL)_shortStrokeEnding inJotView:(JotView*)jotView {
    shortStrokeEnding = _shortStrokeEnding;
}

/**
 * the user has moved to this new touch point, and we need
 * to specify the width of the stroke at this position
 *
 * we'll use pressure data to determine width if we can, otherwise
 * we'll fall back to use velocity data
 */
- (CGFloat)widthForCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)jotView {
    if (self.shouldUseVelocity) {
        //
        // velocity is reversed from the pen, this eraser
        // will get wider with faster velocity instead
        // of thinner
        CGFloat width = (velocity - 1);
        if (width > 0)
            width = 0;
        width = maxSize + ABS(width) * (minSize - maxSize);
        if (width < 1)
            width = 1;

        if (shortStrokeEnding) {
            return minSize;
        }

        return width;
    } else {
        //
        //
        // for pressure width:
        CGFloat newWidth = minSize + (maxSize - minSize) * coalescedTouch.force;
        return MAX(minSize, MIN(maxSize, newWidth));
    }
}


- (UIColor*)colorForCoalescedTouch:(UITouch*)coalescedTouch fromTouch:(UITouch*)touch inJotView:(JotView*)jotView {
    return nil; // nil means erase
}


- (void)didEndStrokeWithTouch:(JotTouch*)touch inJotView:(JotView*)jotView {
    //    DebugLog(@"ERASER velocity: %f", velocity);
}

@end
