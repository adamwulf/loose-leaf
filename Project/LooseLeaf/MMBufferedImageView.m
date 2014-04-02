//
//  MMBufferedImageView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMBufferedImageView.h"

@implementation MMBufferedImageView{
    UIImage* image;
    CGFloat targetSize;
    CALayer* layer;
    CALayer* whiteBorderLayer;
}

@synthesize image;

CGFloat buffer = 2;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.clearsContextBeforeDrawing = YES;
        targetSize = self.bounds.size.height - 2*buffer;
        
        layer = [[CALayer alloc] init];
        layer.backgroundColor = [UIColor whiteColor].CGColor;
        layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
        layer.frame = CGRectInset(self.bounds, 10, 10);
        layer.shouldRasterize = YES;
        [self.layer addSublayer:layer];
        
        // black outer border
        layer.borderColor = [UIColor blackColor].CGColor;
        layer.borderWidth = 3;
        
        // white border, which will
        // draw on top of the black border
        whiteBorderLayer = [[CALayer alloc] init];
        whiteBorderLayer.borderColor = [UIColor whiteColor].CGColor;
        whiteBorderLayer.borderWidth = 2;
        whiteBorderLayer.shouldRasterize = YES;
        [self.layer addSublayer:whiteBorderLayer];
        
        // debug
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 1;
    }
    return self;
}

-(void) setImage:(UIImage *)_image{
    image = _image;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if(image){
        CGRect fr = CGRectInset(self.bounds, 8, 8);
        CGSize scaledImageSize = image.size;
        CGFloat maxDim = MAX(scaledImageSize.width, scaledImageSize.height);
        scaledImageSize.width = scaledImageSize.width / maxDim * fr.size.width;
        scaledImageSize.height = scaledImageSize.height / maxDim * fr.size.height;
        
        fr.origin.x += (fr.size.width - scaledImageSize.width) / 2;
        fr.origin.y += (fr.size.height - scaledImageSize.height) / 2;
        fr.size = scaledImageSize;
        layer.frame = fr;
        
        CGRect whiteFrame = CGRectInset(layer.frame, 1, 1);
        whiteBorderLayer.frame = whiteFrame;
    }
    
    layer.contents = (id)image.CGImage;
    
    [CATransaction commit];
}

-(void) setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    if(hidden){
        layer.contents = nil;
    }
}

-(CGSize) visibleImageSize{
    return layer.bounds.size;
}

-(CGPoint) visibleImageOrigin{
    return layer.frame.origin;
}


@end
