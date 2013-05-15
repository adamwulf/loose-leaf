//
//  MMPanAndPinchGestureRecognizer.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "Constants.h"

@interface MMPanAndPinchGestureRecognizer : UIGestureRecognizer{
    //
    // the initial distance between
    // the touches. to be used to calculate
    // scale
    CGFloat initialDistance;
    //
    // the current scale of the gesture
    CGFloat scale;
    //
    // the collection of valid touches for this gesture
    NSMutableSet* ignoredTouches;
    NSMutableOrderedSet* validTouches;

    // track which bezels our delegate cares about
    MMBezelDirection bezelDirectionMask;
    // the direction that the user actually did exit, if any
    MMBezelDirection didExitToBezel;
    // track the direction of the scale
    MMBezelScaleDirection scaleDirection;
    
    //
    // store panning velocity so we can continue
    // the animation after the gesture ends
    NSMutableArray* velocities;
    CGPoint _averageVelocity;

    //
    // have they bezeled off the page more than once
    // during the same gesture? this will track it
    NSInteger numberOfRepeatingBezels;
    //
    // don't allow both the 2nd to last touch
    // and the last touch to trigger a repeat
    // of the bezel
    BOOL secondToLastTouchDidBezel;
}

@property (nonatomic, readonly) NSInteger numberOfRepeatingBezels;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGPoint velocity;
@property (nonatomic, assign) MMBezelDirection bezelDirectionMask;
@property (nonatomic, readonly) MMBezelDirection didExitToBezel;
@property (nonatomic, readonly) MMBezelScaleDirection scaleDirection;

-(void) cancel;

@end
