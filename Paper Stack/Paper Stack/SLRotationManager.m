//
//  SLRotationManager.m
//  scratchpaper
//
//  Created by Adam Wulf on 6/23/12.
//
//

#import "SLRotationManager.h"

@implementation SLRotationManager

@synthesize delegate;

static SLRotationManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((_instance = [super init])){
        [[NSNotificationCenter defaultCenter] addObserver:_instance selector:@selector(didRotate:)   name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return _instance;
}

+(SLRotationManager*) sharedInstace{
    if(!_instance){
        _instance = [[SLRotationManager alloc]init];
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

    UIInterfaceOrientation currOrient = [self currentStatusbarOrientation];
    [delegate willRotateInterfaceFrom:currOrient to:orientation];
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
    [delegate didRotateInterfaceFrom:currOrient to:orientation];
}



@end
