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

@interface SLPanAndPinchGestureRecognizer : UIPanGestureRecognizer{
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
    NSMutableOrderedSet* validTouchesOnly;

    // track which bezels our delegate cares about
    SLBezelDirection bezelDirectionMask;
    // the direction that the user actually did exit, if any
    SLBezelDirection didExitToBezel;
}

@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, assign) SLBezelDirection bezelDirectionMask;
@property (nonatomic, readonly) SLBezelDirection didExitToBezel;

-(void) cancel;

@end
