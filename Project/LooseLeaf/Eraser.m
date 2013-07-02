//
//  Eraser.m
//  jotuiexample
//
//  Created by Adam Wulf on 1/9/13.
//  Copyright (c) 2013 Adonit. All rights reserved.
//

#import "Eraser.h"
#import "Constants.h"
#import "TestFlight.h"

@implementation Eraser

-(id) init{
    return [self initWithMinSize:12.0 andMaxSize:180.0 andMinAlpha:1.0 andMaxAlpha:1.0];
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
    if(shouldUseVelocity){
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
    return nil; // nil means erase
}


-(void) didEndStrokeWithTouch:(JotTouch *)touch{
    debug_NSLog(@"PEN velocity: %f", velocity);
}

@end
