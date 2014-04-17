//
//  MMBorderedCamView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/11/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMBorderedCamView.h"
#import "AVCamView.h"
#import "MMUntouchableView.h"
#import "CaptureSessionManager.h"

@implementation MMBorderedCamView{
    AVCamView* cameraController;
    CGFloat rotation;
    CaptureSessionManager* cameraSession;
}

@synthesize rotation;

- (id)initWithFrame:(CGRect)frame
{
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
        [self.layer addSublayer:camHolderLayer];
        
//        cameraController = [[AVCamView alloc] initWithFrame:CGRectInset(self.bounds, 3, 3)];
//        [self addSubview:cameraController];
        
        cameraSession = [[CaptureSessionManager alloc] init];
        [cameraSession addPreviewLayerTo:camHolderLayer];

        [self addSubview:borderView];
        
        [[cameraSession captureSession] startRunning];
    }
    return self;
}

-(void) setRotation:(CGFloat)_rotation{
    rotation = _rotation;
    self.transform = CGAffineTransformMakeRotation(rotation);
}

-(void) changeCamera{
//    [cameraController changeCamera];
}

#pragma mark - Delegate

-(NSObject<MMCamViewDelegate>*)delegate{
//    return cameraController.delegate;
    return nil;
}

-(void) setDelegate:(NSObject<MMCamViewDelegate> *)delegate{
//    cameraController.delegate = delegate;
}

-(void) dealloc{
    NSLog(@"yep");
}

@end
