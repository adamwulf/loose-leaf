//
//  CaptureSessionManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/11/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "MMCamViewDelegate.h"

@interface CaptureSessionManager : NSObject{
    __weak NSObject<MMCamViewDelegate>* delegate;
}

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;
@property (weak) NSObject<MMCamViewDelegate>* delegate;

- (id)initWithPosition:(AVCaptureDevicePosition)preferredPosition;

-(void) changeCamera;
-(void) snapPicture;
-(void) addPreviewLayerTo:(CALayer*)layer;

+(BOOL) hasCamera;

@end
