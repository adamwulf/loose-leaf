//
//  MMBezelInLeftGestureRecognizer.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/2/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "Constants.h"

@interface MMBezelInLeftGestureRecognizer : UIGestureRecognizer{
    // direction the user is panning
    MMBezelDirection panDirection;
    CGFloat liftedRightFingerOffset;
    // use to calculate direction
    CGPoint lastKnownLocation;
    // use to calculate translation
    CGPoint firstKnownLocation;

    NSMutableSet* validTouches;

    NSDate* dateOfLastBezelEnding;
    NSInteger numberOfRepeatingBezels;
}

@property (readonly) NSArray* touches;
@property (nonatomic, readonly) MMBezelDirection panDirection;
@property (nonatomic, readonly) NSInteger numberOfRepeatingBezels;

-(CGPoint) translationInView:(UIView*)view;

-(void) resetPageCount;

-(void) cancel;

@end
