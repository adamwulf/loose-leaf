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
#import "Constants.h"

@interface MMRotationManager : NSObject{
    BOOL isFirstReading;
    CGFloat accelerationX;
    CGFloat accelerationY;
    CGFloat accelerationZ;
    CGFloat currentRotationReading;

    NSObject<MMRotationManagerDelegate>* __weak delegate;
    NSOperationQueue* opQueue;
    CMMotionManager* motionManager;
}

@property (nonatomic, readonly) CGFloat currentRotationReading;
@property (nonatomic, weak) NSObject<MMRotationManagerDelegate>* delegate;


+(MMRotationManager*) sharedInstace;

-(UIDeviceOrientation) currentDeviceOrientation;

@end
