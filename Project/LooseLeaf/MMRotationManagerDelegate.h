//
//  MMRotationManagerDelegate.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/23/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MMRotationManagerDelegate <NSObject>


-(void) willRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient;

-(void) didRotateInterfaceFrom:(UIInterfaceOrientation)fromOrient to:(UIInterfaceOrientation)toOrient;

-(void) didUpdateAccelerometerWithReading:(CGFloat)currentRawReading;

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading;

@end
