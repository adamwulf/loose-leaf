//
//  MMRotationManager.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/23/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMRotationManagerDelegate.h"
#import <CoreMotion/CoreMotion.h>
#import "MMVector.h"
#import "Constants.h"

@interface MMRotationManager : NSObject{
    BOOL isFirstReading;
    CGFloat accelerationX;
    CGFloat accelerationY;
    CGFloat accelerationZ;
    MMVector* currentRotationReading;
    MMVector* currentRawRotationReading;

    NSObject<MMRotationManagerDelegate>* __weak delegate;
    NSOperationQueue* opQueue;
    CMMotionManager* motionManager;
}

@property (nonatomic, readonly) MMVector* currentRotationReading;
@property (nonatomic, readonly) MMVector* currentRawRotationReading;
@property (nonatomic, weak) NSObject<MMRotationManagerDelegate>* delegate;
@property (nonatomic, readonly) UIDeviceOrientation lastBestOrientation;

+(MMRotationManager*) sharedInstace;

-(UIDeviceOrientation) currentDeviceOrientation;

-(MMVector*) upVector;


-(void) willResignActive;

-(void) didEnterForeground;

-(void) didBecomeActive;

-(void) applicationDidBackground;

@end
