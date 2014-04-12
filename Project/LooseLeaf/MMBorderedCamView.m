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

@implementation MMBorderedCamView{
    AVCamView* cameraController;
}

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
        
        cameraController = [[AVCamView alloc] initWithFrame:CGRectInset(self.bounds, 3, 3)];
        [self addSubview:cameraController];
        [self addSubview:borderView];

    }
    return self;
}

-(void) changeCamera{
    [cameraController changeCamera];
}

@end
