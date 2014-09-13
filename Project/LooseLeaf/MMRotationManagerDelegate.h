//
//  MMRotationManagerDelegate.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/23/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MMVector.h"

@protocol MMRotationManagerDelegate <NSObject>

-(void) willRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient;

-(void) didRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient;

-(void) didRotateToIdealOrientation:(UIInterfaceOrientation)toOrient;

-(void) didUpdateAccelerometerWithReading:(MMVector*)currentRawReading;

-(void) didUpdateAccelerometerWithRawReading:(MMVector*)currentRawReading andX:(CGFloat)xAccel andY:(CGFloat)yAccel andZ:(CGFloat)zAccel;

@end
