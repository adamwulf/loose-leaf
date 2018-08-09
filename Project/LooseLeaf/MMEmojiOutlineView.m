//
//  MMEmojiOutlineView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/7/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMEmojiOutlineView.h"


@implementation MMEmojiOutlineView {
    CAShapeLayer* _mask;
    UIImageView* _imageView;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.clearsContextBeforeDrawing = YES;

        CGRect imageViewBounds = CGRectInset(self.bounds, 10, 10);
        imageViewBounds.size.height = imageViewBounds.size.width; // make sure it's square
        _imageView = [[UIImageView alloc] initWithFrame:imageViewBounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];

        // black outer border
        _mask = [[CAShapeLayer alloc] init];
        _mask.fillColor = [UIColor whiteColor].CGColor;
        _mask.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
        _mask.frame = CGRectInset(self.bounds, 10, 10);
        _mask.lineWidth = 0;

        [[self layer] setMask:_mask];
    }
    return self;
}

- (void)setRotation:(CGFloat)rotation {
    _rotation = rotation;
    self.transform = CGAffineTransformMakeRotation(_rotation);
}

- (UIColor*)backgroundColor {
    return [UIColor colorWithCGColor:[_mask fillColor]];
}

- (void)setShape:(MMEmojiAsset*)shape {
    _shape = shape;

    [CATransaction begin]; // prevent CALayer animation
    [CATransaction setDisableActions:YES];

    if (shape) {
        [self setPreferredAspectRatioForEmptyImage:shape.fullResolutionSize];
    }

    UIBezierPath* path = [[shape fullResolutionPath] copy];
    CGFloat scale = [self pathScaleForPreferredSize:shape.fullResolutionSize];

    [path applyTransform:CGAffineTransformMakeScale(scale, scale)];

    [_mask setPath:path.CGPath];

    [CATransaction commit];
}

- (void)setImage:(UIImage*)image {
    [_imageView setImage:image];
}

- (UIImage*)image {
    return [_imageView image];
}

- (CGFloat)pathScaleForPreferredSize:(CGSize)preferredSize {
    CGRect fr = CGRectInset(self.bounds, 10, 10);
    fr.size.height = fr.size.width;

    return MIN(fr.size.width / preferredSize.width, fr.size.height / preferredSize.height);
}

- (void)setPreferredAspectRatioForEmptyImage:(CGSize)preferredSize {
    [CATransaction begin]; // prevent CALayer animation
    [CATransaction setDisableActions:YES];

    CGRect fr = CGRectInset(self.bounds, 10, 10);
    fr.size.height = fr.size.width;
    CGSize scaledImageSize = preferredSize;

    CGFloat maxImageDim = MAX(scaledImageSize.width, scaledImageSize.height);
    CGFloat minFrDim = MIN(fr.size.width, fr.size.height);

    scaledImageSize.width = (scaledImageSize.width / maxImageDim) * minFrDim;
    scaledImageSize.height = (scaledImageSize.height / maxImageDim) * minFrDim;

    fr.origin.x += (fr.size.width - scaledImageSize.width) / 2;
    fr.origin.y += (fr.size.height - scaledImageSize.height) / 2;
    fr.size = scaledImageSize;
    _mask.frame = fr;

    [CATransaction commit];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (hidden) {
        [_mask setPath:nil];
    }
}

- (CGSize)visibleImageSize {
    return _mask.bounds.size;
}

- (CGPoint)visibleImageOrigin {
    return _mask.frame.origin;
}

- (void)dealloc {
    [_mask setPath:nil];
}

@end
