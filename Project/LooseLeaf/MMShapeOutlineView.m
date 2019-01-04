//
//  MMShapeOutlineView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/23/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMShapeOutlineView.h"


@implementation MMShapeOutlineView {
    CAShapeLayer* _layer;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.clearsContextBeforeDrawing = YES;

        // black outer border
        _layer = [[CAShapeLayer alloc] init];
        _layer.fillColor = [UIColor whiteColor].CGColor;
        _layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
        _layer.frame = CGRectInset(self.bounds, 10, 10);
        _layer.strokeColor = [UIColor blackColor].CGColor;
        _layer.lineWidth = 3;
        [self.layer addSublayer:_layer];
    }
    return self;
}

- (void)setRotation:(CGFloat)rotation {
    _rotation = rotation;
    self.transform = CGAffineTransformMakeRotation(_rotation);
}

- (void)setBackgroundColor:(UIColor*)backgroundColor {
    [CATransaction begin]; // prevent CALayer animation
    [CATransaction setDisableActions:YES];
    [_layer setFillColor:[backgroundColor CGColor]];
    [CATransaction commit];
}

- (UIColor*)backgroundColor {
    return [UIColor colorWithCGColor:[_layer fillColor]];
}

- (void)setShape:(UIBezierPath*)shape {
    _shape = shape;

    [CATransaction begin]; // prevent CALayer animation
    [CATransaction setDisableActions:YES];

    if (shape) {
        [self setPreferredAspectRatioForEmptyImage:shape.bounds.size];
    }

    UIBezierPath* path = [shape copy];
    CGFloat scale = [self pathScaleForPreferredSize:shape.bounds.size];

    [path applyTransform:CGAffineTransformMakeScale(scale, scale)];

    [_layer setPath:path.CGPath];

    [CATransaction commit];
}

- (CGFloat)pathScaleForPreferredSize:(CGSize)preferredSize {
    CGRect fr = CGRectInset(self.bounds, 10, 10);

    return MIN(fr.size.width / preferredSize.width, fr.size.height / preferredSize.height);
}

- (void)setPreferredAspectRatioForEmptyImage:(CGSize)preferredSize {
    [CATransaction begin]; // prevent CALayer animation
    [CATransaction setDisableActions:YES];

    CGRect fr = CGRectInset(self.bounds, 10, 10);
    CGSize scaledImageSize = preferredSize;

    CGFloat maxImageDim = MAX(scaledImageSize.width, scaledImageSize.height);
    CGFloat minFrDim = MIN(fr.size.width, fr.size.height);

    scaledImageSize.width = (scaledImageSize.width / maxImageDim) * minFrDim;
    scaledImageSize.height = (scaledImageSize.height / maxImageDim) * minFrDim;

    fr.origin.x += (fr.size.width - scaledImageSize.width) / 2;
    fr.origin.y += (fr.size.height - scaledImageSize.height) / 2;
    fr.size = scaledImageSize;
    _layer.frame = fr;

    [CATransaction commit];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (hidden) {
        [_layer setPath:nil];
    }
}

- (CGSize)visibleImageSize {
    return _layer.bounds.size;
}

- (CGPoint)visibleImageOrigin {
    return _layer.frame.origin;
}

- (void)dealloc {
    [_layer setPath:nil];
}

@end
