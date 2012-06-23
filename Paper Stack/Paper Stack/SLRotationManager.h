//
//  SLRotationManager.h
//  scratchpaper
//
//  Created by Adam Wulf on 6/23/12.
//
//

#import <Foundation/Foundation.h>
#import "SLRotationManagerDelegate.h"
#import <CoreMotion/CoreMotion.h>
#import "Constants.h"

@interface SLRotationManager : NSObject{
    BOOL isFirstReading;
    CGFloat accelerationX;
    CGFloat accelerationY;
    CGFloat currentRotationReading;

    NSObject<SLRotationManagerDelegate>* delegate;
}

@property (nonatomic, readonly) CGFloat currentRotationReading;
@property (nonatomic, assign) NSObject<SLRotationManagerDelegate>* delegate;


+(SLRotationManager*) sharedInstace;

-(UIDeviceOrientation) currentDeviceOrientation;

@end
