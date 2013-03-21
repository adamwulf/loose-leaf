//
//  SLRotationManager.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/23/12.
//
//

#import <Foundation/Foundation.h>
#import "MSRotationManagerDelegate.h"
#import <CoreMotion/CoreMotion.h>
#import "Constants.h"

@interface MSRotationManager : NSObject{
    BOOL isFirstReading;
    CGFloat accelerationX;
    CGFloat accelerationY;
    CGFloat accelerationZ;
    CGFloat currentRotationReading;

    NSObject<MSRotationManagerDelegate>* delegate;
}

@property (nonatomic, readonly) CGFloat currentRotationReading;
@property (nonatomic, assign) NSObject<MSRotationManagerDelegate>* delegate;


+(MSRotationManager*) sharedInstace;

-(UIDeviceOrientation) currentDeviceOrientation;

@end
