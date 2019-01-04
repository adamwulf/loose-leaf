//
//  MMEmojiButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMEmojiButton.h"
#import "MMEmojiAssetGroup.h"
#import "UIColor+RHInterpolationAdditions.h"


@implementation MMEmojiButton

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //
    // Notes for this button
    //
    // the page border bezier has to be added to the oval bezier
    // paintcode keeps them separate
    //

    //// Color Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    UIColor* darkerGreyBorder = [self borderColor];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect frame = [self drawableFrame];

    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];

    MMEmojiAssetGroup* emojis = [MMEmojiAssetGroup sharedInstance];
    [emojis loadPhotosAtIndexes:[NSIndexSet indexSetWithIndex:0] usingBlock:^(MMDisplayAsset* result, NSUInteger index, BOOL* stop) {
        // glyph path is inverted, so flip vertically
        CGAffineTransform flipY = CGAffineTransformMakeScale(1, -1);
        // glyph path may be offset on the x coord, and by the height (because it's flipped)
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(rect));

        CGContextConcatCTM(context, flipY);
        CGContextConcatCTM(context, translate);

        UIImage* image = [result aspectThumbnailWithMaxPixelSize:CGRectGetWidth(frame)];
        CGContextDrawImage(context, CGRectInset(frame, -1, -1), image.CGImage);
    }];


    UIBezierPath* circleClipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [circleClipPath appendPath:ovalPath];
    circleClipPath.usesEvenOddFillRule = YES;

    // clip end of sleeve
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [circleClipPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    //// Oval Drawing
    CGContextSetBlendMode(context, kCGBlendModeClear);
    UIBezierPath* everything = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [everything appendPath:[ovalPath bezierPathByReversingPath]];
    [[UIColor whiteColor] setFill];
    [everything fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    ovalPath.lineWidth = 1;
    [darkerGreyBorder setStroke];
    [ovalPath stroke];

    [self drawDropshadowIfSelected];

    [super drawRect:rect];
    CGColorSpaceRelease(colorSpace);
}

@end
