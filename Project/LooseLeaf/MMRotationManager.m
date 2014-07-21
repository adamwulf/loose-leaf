//
//  MMRotationManager.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/23/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMRotationManager.h"

@implementation MMRotationManager{
    CGFloat goalTrust;
    CGFloat currentTrust;
    UIDeviceOrientation lastBestOrientation;
    UIDeviceOrientation currentOrientation;
}

@synthesize delegate;
@synthesize currentRotationReading;
@synthesize currentRawRotationReading;

static MMRotationManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        _instance = self;
        currentTrust = 0.0;
        goalTrust = 0.0;
        lastBestOrientation = UIDeviceOrientationPortrait;
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
//            CGFloat absZ = accelerationZ < 0 ? -accelerationZ : accelerationZ;
//            debug_NSLog(@"x: %f   y: %f   z: %f   diff: %f", accelerationX, accelerationY, absZ);
            CGFloat newRawReading = atan2(accelerationY, accelerationX);
            currentTrust += (goalTrust - currentTrust) / 10.0;
            newRawReading = currentTrust * newRawReading + (1-currentTrust)*[self idealRotationReadingForCurrentRawReading:newRawReading];
            if((ABS(newRawReading - currentRotationReading) > .05 || isFirstReading)){
                currentRotationReading = newRawReading;
                isFirstReading = NO;
                [self.delegate didUpdateAccelerometerWithReading:currentRotationReading];
            }
            currentRawRotationReading = newRawReading;
            [self.delegate didUpdateAccelerometerWithRawReading:currentRawRotationReading andX:accelerationX andY:accelerationY andZ:accelerationZ];
            
            if(currentTrust > .75){
                if(currentOrientation == UIDeviceOrientationPortrait ||
                   currentOrientation == UIDeviceOrientationPortraitUpsideDown ||
                   currentOrientation == UIDeviceOrientationLandscapeLeft ||
                   currentOrientation == UIDeviceOrientationLandscapeRight){
                    if(currentOrientation != UIDeviceOrientationFaceUp &&
                       currentOrientation != UIDeviceOrientationFaceDown &&
                       currentOrientation != UIDeviceOrientationUnknown){
                        lastBestOrientation = currentOrientation;
                    }
                }
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
    if(orientation == UIDeviceOrientationPortrait ||
       orientation == UIDeviceOrientationPortraitUpsideDown ||
       orientation == UIDeviceOrientationLandscapeLeft ||
       orientation == UIDeviceOrientationLandscapeRight){
        goalTrust = 1.0;
    }else{
        goalTrust = 0.0;
    }
    currentOrientation = orientation;
    
    if(orientation == UIDeviceOrientationUnknown ||
       orientation == UIDeviceOrientationFaceDown ||
       orientation == UIDeviceOrientationFaceUp){
        orientation = UIDeviceOrientationPortrait;
    }

    // cast to save a warning
    UIInterfaceOrientation devOrient = (UIInterfaceOrientation) orientation;
    UIInterfaceOrientation currOrient = [self currentStatusbarOrientation];
    [delegate willRotateInterfaceFrom:currOrient to:devOrient];
//    [[UIApplication sharedApplication] setStatusBarOrientation:devOrient animated:NO];
    [delegate didRotateInterfaceFrom:currOrient to:devOrient];
}

-(CGFloat) idealRotationReadingForCurrentRawReading:(CGFloat)rawReading{
    if(lastBestOrientation == UIDeviceOrientationPortrait){
        return -M_PI / 2;
    }else if(lastBestOrientation == UIDeviceOrientationLandscapeLeft){
        if(rawReading < 0){
            return -M_PI;
        }else{
            return M_PI;
        }
    }else if(lastBestOrientation == UIDeviceOrientationLandscapeRight){
        return 0;
    }else{
        return M_PI / 2;
    }
}

-(void) setDelegate:(NSObject<MMRotationManagerDelegate> *)_delegate{
    delegate = _delegate;
    [delegate didUpdateAccelerometerWithReading:[self currentRotationReading]];
}


-(MMVector*) upVector{
    MMVector* up = [[[MMVector vectorWithAngle:-([[MMRotationManager sharedInstace] currentRotationReading])] flip] normal];
    NSLog(@"up vector is: %@", up);
    return up;
}

@end
