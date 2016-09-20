//
//  MMBufferedImageView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMBufferedImageView.h"


@implementation MMBufferedImageView {
    UIImage* image;
    CGFloat targetSize;
    CALayer* layer;
    CALayer* whiteBorderLayer;
    CGFloat rotation;
}

@synthesize image;
@synthesize rotation;

CGFloat buffer = 2;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.clearsContextBeforeDrawing = YES;
        targetSize = self.bounds.size.height - 2 * buffer;

        // black outer border
        layer = [[CALayer alloc] init];
        layer.backgroundColor = [UIColor whiteColor].CGColor;
        layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
        layer.frame = CGRectInset(self.bounds, 10, 10);
        layer.shouldRasterize = YES;
        layer.borderColor = [UIColor blackColor].CGColor;
        layer.borderWidth = 3;
        [self.layer addSublayer:layer];

        // white border, which will
        // draw on top of the black border
        whiteBorderLayer = [[CALayer alloc] init];
        whiteBorderLayer.borderColor = [UIColor whiteColor].CGColor;
        whiteBorderLayer.borderWidth = 2;
        whiteBorderLayer.shouldRasterize = YES;
        [self.layer addSublayer:whiteBorderLayer];
    }
    return self;
}

- (void)setRotation:(CGFloat)_rotation {
    rotation = _rotation;
    self.transform = CGAffineTransformMakeRotation(rotation);
}

- (void)setImage:(UIImage*)_image {
    image = _image;

    [CATransaction begin]; // prevent CALayer animation
    [CATransaction setDisableActions:YES];

    if (image) {
        [self setPreferredAspectRatioForEmptyImage:image.size];
    }

    [self updateLayerContentsWith:image.CGImage];

    [CATransaction commit];
}

- (void)setPreferredAspectRatioForEmptyImage:(CGSize)preferredSize {
    [CATransaction begin]; // prevent CALayer animation
    [CATransaction setDisableActions:YES];

    CGRect fr = CGRectInset(self.bounds, 8, 8);
    CGSize scaledImageSize = preferredSize;

    CGFloat maxImageDim = MAX(scaledImageSize.width, scaledImageSize.height);
    CGFloat minFrDim = MIN(fr.size.width, fr.size.height);

    scaledImageSize.width = (scaledImageSize.width / maxImageDim) * minFrDim;
    scaledImageSize.height = (scaledImageSize.height / maxImageDim) * minFrDim;

    fr.origin.x += (fr.size.width - scaledImageSize.width) / 2;
    fr.origin.y += (fr.size.height - scaledImageSize.height) / 2;
    fr.size = scaledImageSize;
    layer.frame = fr;

    CGRect whiteFrame = CGRectInset(layer.frame, 1, 1);
    whiteBorderLayer.frame = whiteFrame;
    [CATransaction commit];
}

- (void)updateLayerContentsWith:(CGImageRef)imageRef {
    if (imageRef) {
        CFRetain(imageRef);
    }
    CGImageRef oldImageRef = (__bridge CGImageRef)(layer.contents);
    // bridge, so ARC doesn't own the object, i'll manage retains myself
    // http://stackoverflow.com/questions/8577894/setting-the-contents-of-a-calayer-to-a-cgimageref-on-ios-with-arc-on
    layer.contents = (__bridge id)(imageRef);
    if (oldImageRef) {
        CFRelease(oldImageRef);
    }
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (hidden) {
        [self updateLayerContentsWith:nil];
    }
}

- (CGSize)visibleImageSize {
    return layer.bounds.size;
}

- (CGPoint)visibleImageOrigin {
    return layer.frame.origin;
}

- (void)dealloc {
    [self updateLayerContentsWith:nil];
}


@end
