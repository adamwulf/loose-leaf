//
//  Highlighter.m
//  LooseLeaf
//
//  Created by Adam Wulf on 2/28/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "Highlighter.h"
#import <JotUI/JotUI.h>


@implementation Highlighter


- (id)init {
    return [self initWithMinSize:40.0 andMaxSize:40.0 andMinAlpha:0.5 andMaxAlpha:0.8];
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
        return width;
    } else {
        //
        //
        // for pressure width:
        CGFloat newWidth = minSize + (maxSize - minSize) * coalescedTouch.force;
        return MAX(minSize, MIN(maxSize, newWidth));
    }
}

- (JotBrushTexture*)textureForStroke {
    return [JotHighlighterBrushTexture sharedInstance];
}

- (CGFloat)stepWidthForStroke {
    return 2;
}

- (BOOL)supportsRotation {
    return YES;
}

- (void)didEndStrokeWithTouch:(JotTouch*)touch inJotView:(JotView*)jotView {
    //    DebugLog(@"ERASER velocity: %f", velocity);
}

@end
