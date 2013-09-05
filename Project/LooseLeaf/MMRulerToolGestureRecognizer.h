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
}

@property (readonly) NSArray* touches;
@property (nonatomic, readonly) CGFloat initialDistance;
@property (nonatomic, readonly) CGFloat scale;

-(void) cancel;
-(BOOL) containsTouch:(UITouch*)touch;

-(CGPoint) point1InView:(UIView*)view;
-(CGPoint) point2InView:(UIView*)view;

@end
