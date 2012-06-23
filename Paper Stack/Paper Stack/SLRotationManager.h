//
//  SLRotationManager.h
//  scratchpaper
//
//  Created by Adam Wulf on 6/23/12.
//
//

#import <Foundation/Foundation.h>
#import "SLRotationManagerDelegate.h"

@interface SLRotationManager : NSObject{
    NSObject<SLRotationManagerDelegate>* delegate;
}

@property (nonatomic, assign) NSObject<SLRotationManagerDelegate>* delegate;


+(SLRotationManager*) sharedInstace;

-(UIDeviceOrientation) currentDeviceOrientation;

@end
