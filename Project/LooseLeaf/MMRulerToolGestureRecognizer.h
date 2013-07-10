//
//  MMRulerToolGestureRecognizer.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/10/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "Constants.h"

@interface MMRulerToolGestureRecognizer : UIGestureRecognizer{
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

    // track the direction of the scale
    MMBezelScaleDirection scaleDirection;
}

@property (nonatomic, readonly) NSInteger numberOfRepeatingBezels;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) MMBezelScaleDirection scaleDirection;

-(void) cancel;
-(BOOL) containsTouch:(UITouch*)touch;

@end
