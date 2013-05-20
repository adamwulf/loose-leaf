//
//  MMRotationManager.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/23/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMRotationManager.h"

@implementation MMRotationManager

@synthesize delegate;
@synthesize currentRotationReading;

static MMRotationManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((_instance = [super init])){
        [[NSNotificationCenter defaultCenter] addObserver:_instance selector:@selector(didRotate:)   name:UIDeviceOrientationDidChangeNotification object:nil];
        isFirstReading = YES;
        currentRotationReading = 0;
        // add opqueue to sample the accelerometer
        opQueue = [[NSOperationQueue alloc] init];
        [opQueue setMaxConcurrentOperationCount:1];
        motionManager = [[CMMotionManager alloc] init];
        [motionManager setAccelerometerUpdateInterval:0.03];
        [motionManager startAccelerometerUpdatesToQueue:opQueue withHandler:^(CMAccelerometerData* data, NSError* error){
            //
            // if z == -1, x == 0, y == 0
            //   then it's flat up on a table
            // if z == 1, x == 0, y == 0
            //   then it's flat down on a table
            // if z == 0, x == 0, y == -1
            //   then it's up in portrait
            // if z == 0, x == 0, y == 1
            //   then it's upside down in portrait
            // if z == 0, x == 1, y == 0
            //   then it's landscape button left
            // if z == 0, x == -1, y == 0
            //   then it's landscape button right
            accelerationX = data.acceleration.x * kFilteringFactor + accelerationX * (1.0 - kFilteringFactor);
            accelerationY = data.acceleration.y * kFilteringFactor + accelerationY * (1.0 - kFilteringFactor);
            accelerationZ = data.acceleration.z * kFilteringFactor + accelerationZ * (1.0 - kFilteringFactor);
            CGFloat absZ = accelerationZ < 0 ? -accelerationZ : accelerationZ;
//            NSLog(@"x: %f   y: %f   z: %f   diff: %f", accelerationX, accelerationY, absZ);
            CGFloat newRawReading = atan2(accelerationY, accelerationX);
            if((ABS(newRawReading - currentRotationReading) > .05 || isFirstReading) && absZ < 0.95){
                currentRotationReading = newRawReading;
                isFirstReading = NO;
                [self.delegate didUpdateAccelerometerWithReading:currentRotationReading];
            }
        }];
    }
    return _instance;
}

+(MMRotationManager*) sharedInstace{
    if(!_instance){
        _instance = [[MMRotationManager alloc]init];
    }
    return _instance;
}

-(UIDeviceOrientation) currentDeviceOrientation{
    return [[UIDevice currentDevice] orientation];
}

-(UIInterfaceOrientation) currentStatusbarOrientation{
    return [[UIApplication sharedApplication] statusBarOrientation];
}

- (void)didRotate:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if(orientation == UIDeviceOrientationUnknown ||
       orientation == UIDeviceOrientationFaceDown ||
       orientation == UIDeviceOrientationFaceUp){
        orientation = UIDeviceOrientationPortrait;
    }

    // cast to save a warning
    UIInterfaceOrientation devOrient = (UIInterfaceOrientation) orientation;
    UIInterfaceOrientation currOrient = [self currentStatusbarOrientation];
    [delegate willRotateInterfaceFrom:currOrient to:devOrient];
    [[UIApplication sharedApplication] setStatusBarOrientation:devOrient animated:NO];
    [delegate didRotateInterfaceFrom:currOrient to:devOrient];
}

-(void) setDelegate:(NSObject<MMRotationManagerDelegate> *)_delegate{
    delegate = _delegate;
    [delegate didUpdateAccelerometerWithReading:[self currentRotationReading]];
}


@end
