//
//  MMBorderedCamView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/11/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMBorderedCamView.h"
#import "MMUntouchableView.h"
#import "CaptureSessionManager.h"

@implementation MMBorderedCamView{
    CGFloat rotation;
    CaptureSessionManager* cameraSession;
}

@synthesize delegate;
@synthesize rotation;

- (id)initWithFrame:(CGRect)frame andCameraPosition:(AVCaptureDevicePosition)preferredPosition{
    self = [super initWithFrame:frame];
    if (self) {
        
        MMUntouchableView* borderView = [[MMUntouchableView alloc] initWithFrame:self.bounds];
        
        // black outer border
        CALayer* blackBorderLayer = [[CALayer alloc] init];
        blackBorderLayer.backgroundColor = [UIColor clearColor].CGColor;
        blackBorderLayer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
        blackBorderLayer.frame = CGRectInset(self.bounds, 0, 0);
        blackBorderLayer.shouldRasterize = YES;
        blackBorderLayer.borderColor = [UIColor blackColor].CGColor;
        blackBorderLayer.borderWidth = 3;
        [borderView.layer addSublayer:blackBorderLayer];
        
        // white border, which will
        // draw on top of the black border
        CALayer* whiteBorderLayer = [[CALayer alloc] init];
        whiteBorderLayer.backgroundColor = [UIColor clearColor].CGColor;
        whiteBorderLayer.frame = CGRectInset(self.bounds, 2, 2);
        whiteBorderLayer.borderColor = [UIColor whiteColor].CGColor;
        whiteBorderLayer.borderWidth = 3;
        whiteBorderLayer.shouldRasterize = YES;
        [borderView.layer addSublayer:whiteBorderLayer];
        
        // define bounds that'll hold the camera
        CALayer* camHolderLayer = [[CALayer alloc] init];
        camHolderLayer.frame = CGRectInset(self.bounds, 3, 3);
        camHolderLayer.backgroundColor = [UIColor blackColor].CGColor;
        [self.layer addSublayer:camHolderLayer];
        
//        cameraController = [[AVCamView alloc] initWithFrame:CGRectInset(self.bounds, 3, 3)];
//        [self addSubview:cameraController];
        
        cameraSession = [[CaptureSessionManager alloc] initWithPosition:preferredPosition];
        cameraSession.delegate = self;
        [cameraSession addPreviewLayerTo:camHolderLayer];

        [self addSubview:borderView];
        
        UIButton* tempButton = [[UIButton alloc] initWithFrame:self.bounds];
        tempButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [tempButton addTarget:self action:@selector(snapStillImage:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tempButton];
    }
    return self;
}

-(void) setRotation:(CGFloat)_rotation{
    rotation = _rotation;
    self.transform = CGAffineTransformMakeRotation(rotation);
}

-(void) changeCamera{
    [cameraSession changeCamera];
}

-(void) snapStillImage:(UIButton*)button{
    [cameraSession snapPicture];
}

#pragma mark - MMCamViewDelegate

-(void) didTakePicture:(UIImage*)img{
    [delegate didTakePicture:img];
}

-(void) didChangeCameraTo:(AVCaptureDevicePosition)preferredPosition{
    [delegate didChangeCameraTo:preferredPosition];
}

-(void) sessionStarted{
    [delegate sessionStarted];
}

@end
