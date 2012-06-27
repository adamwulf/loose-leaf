//
//  SLPanGestureRecognizer.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "Constants.h"

@interface SLPanAndPinchGestureRecognizer : UIGestureRecognizer{
    //
    // the initial distance between
    // the touches. to be used to calculate
    // scale
    CGFloat initialDistance;
    //
    // the current scale of the gesture
    CGFloat scale;
    // use to calculate translation
    CGPoint firstKnownLocation;
    //
    // the collection of valid touches for this gesture
    NSMutableSet* ignoredTouches;
    NSMutableOrderedSet* validTouches;

    // track which bezels our delegate cares about
    SLBezelDirection bezelDirectionMask;
    // the direction that the user actually did exit, if any
    SLBezelDirection didExitToBezel;
    
    NSInteger minimumNumberOfTouches;
    
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

@property (nonatomic, assign) NSInteger minimumNumberOfTouches;
@property (nonatomic, readonly) NSInteger numberOfRepeatingBezels;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGPoint velocity;
@property (nonatomic, assign) SLBezelDirection bezelDirectionMask;
@property (nonatomic, readonly) SLBezelDirection didExitToBezel;

-(void) cancel;

@end
