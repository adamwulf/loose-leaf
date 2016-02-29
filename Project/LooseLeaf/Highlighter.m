//
//  Highlighter.m
//  LooseLeaf
//
//  Created by Adam Wulf on 2/28/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "Highlighter.h"

@implementation Highlighter


-(id) init{
    return [self initWithMinSize:20.0 andMaxSize:20.0 andMinAlpha:1.0 andMaxAlpha:1.0];
}

/**
 * delegate method - a notification from the JotView
 * that a new touch is about to be processed. we should
 * reset all of our counters/etc to base values
 */
-(BOOL) willBeginStrokeWithTouch:(JotTouch*)touch{
    [super willBeginStrokeWithTouch:touch];
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
-(CGFloat) widthForTouch:(JotTouch*)touch{
    if(self.shouldUseVelocity){
        //
        // velocity is reversed from the pen, this eraser
        // will get wider with faster velocity instead
        // of thinner
        CGFloat width = (velocity - 1);
        if(width > 0) width = 0;
        width = maxSize + ABS(width) * (minSize - maxSize);
        if(width < 1) width = 1;
        return width;
    }else{
        //
        //
        // for pressure width:
        CGFloat newWidth = minSize + (maxSize-minSize) * touch.pressure / JOT_MAX_PRESSURE;
        return newWidth;
    }
}


-(UIColor*) colorForTouch:(JotTouch*)touch{
    return [UIColor colorWithRed:.8 green:.5 blue:.2 alpha:1.0];
}


-(void) didEndStrokeWithTouch:(JotTouch *)touch{
    //    DebugLog(@"ERASER velocity: %f", velocity);
}

@end
