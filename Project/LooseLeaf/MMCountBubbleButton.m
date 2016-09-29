//
//  MMCountBubbleButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/5/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMCountBubbleButton.h"
#import "UIFont+UIBezierCurve.h"


@implementation MMCountBubbleButton {
    NSInteger count;
}

@synthesize count;
@synthesize scale;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        count = 0;
        scale = 1;
    }
    return self;
}

- (void)setCount:(NSInteger)_count {
    count = _count;
    [self setNeedsDisplay];
}

- (void)setScale:(CGFloat)_scale {
    scale = _scale;
    self.transform = CGAffineTransformScale([self rotationTransform], scale, scale);
}

- (void)drawCircleBackground:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGRect shadowFrame = CGRectInset(self.bounds, 10, 10);
    CGFloat tokenAdjustment = (100 - self.bounds.size.width) / 15;
    CGRect tokenFrame = CGRectInset(self.bounds, 14 - tokenAdjustment, 14 - tokenAdjustment);
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:shadowFrame];
    UIBezierPath* tokenOvalPath = [UIBezierPath bezierPathWithOvalInRect:tokenFrame];


    [[self backgroundColor] setFill];
    [tokenOvalPath fill];

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    tokenOvalPath.lineWidth = 1;
    [tokenOvalPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [[self borderColor] setStroke];
    [tokenOvalPath stroke];

    //
    //
    // shadow
    //

    UIColor* greyShadowColor = [self borderColor];

    //
    // possible drop shadow
    UIColor* gradientColor = [greyShadowColor colorWithAlphaComponent:0.5];
    UIColor* clearColor = [greyShadowColor colorWithAlphaComponent:0];
    NSArray* gradientColors = [NSArray arrayWithObjects:
                                           (id)gradientColor.CGColor,
                                           (id)clearColor.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    CGContextSaveGState(context);

    UIBezierPath* clipPath = [ovalPath copy];
    [clipPath appendPath:[UIBezierPath bezierPathWithRect:CGRectInfinite]];
    clipPath.usesEvenOddFillRule = YES;
    [clipPath addClip];

    CGContextDrawRadialGradient(context, gradient,
                                CGPointMake(CGRectGetMidX(shadowFrame), CGRectGetMidY(shadowFrame)), shadowFrame.size.width / 2 - 1,
                                CGPointMake(CGRectGetMidX(shadowFrame), CGRectGetMidY(shadowFrame)), shadowFrame.size.width / 2 + 4.5 * shadowFrame.size.width / 100.0,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);

    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);

    CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    [self drawCircleBackground:rect];

    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* darkerGrey = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.33];


    CGFloat largest = MAX(self.bounds.size.width, self.bounds.size.height);

    UIBezierPath* glyphPath = glyphPath = [[UIFont boldSystemFontOfSize:(int)(largest * 2 / 3)] bezierPathForString:[NSString stringWithFormat:@"%d", (int)count]];
    CGRect glyphRect = [glyphPath bounds];
    CGFloat iconWidth = self.bounds.size.width * 4 / 8.0;
    CGFloat iconHeight = self.bounds.size.height * 3 / 8.0;

    CGFloat fullWidth = glyphPath.bounds.size.width - glyphPath.bounds.origin.x;
    if (fullWidth > iconWidth) {
        CGFloat textScale = iconWidth / fullWidth;
        [glyphPath applyTransform:CGAffineTransformMakeScale(textScale, textScale)];
        glyphRect = [glyphPath bounds];
    }
    CGFloat fullHeight = glyphPath.bounds.size.height - glyphPath.bounds.origin.y;
    if (fullHeight > iconHeight) {
        CGFloat textScale = iconHeight / fullHeight;
        [glyphPath applyTransform:CGAffineTransformMakeScale(textScale, textScale)];
        glyphRect = [glyphPath bounds];
    }

    // flip the glyph, and zero out the x, and move it 1pt highter
    [glyphPath applyTransform:CGAffineTransformConcat(CGAffineTransformMakeTranslation(-glyphRect.origin.x, -glyphRect.size.height + 1), CGAffineTransformMakeScale(1.f, -1.f))];
    [glyphPath applyTransform:CGAffineTransformMakeTranslation((self.bounds.size.width - glyphRect.size.width) / 2,
                                                               (self.bounds.size.height - glyphRect.size.height) / 2)];


    if (glyphPath) {
        // draw number
        // ============================================================
        // this drawing code will render the number
        // into the page, and below the page curl.
        //
        // to do this:
        // a) create a mask of the number path minus the path of the page curl.
        //    we'll do this by creating a UIImage with white filled in the area
        //    that we want to mask to
        // b) draw the number and save it to an image as well
        // c) render the image from (b) with the mask from (a)

        CGContextSaveGState(context);
        CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, rect.size.height);

        //
        // create number
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
        context = UIGraphicsGetCurrentContext();
        CGContextConcatCTM(context, flipVertical);
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor whiteColor] setFill];
        [glyphPath fill];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        [darkerGrey setStroke];
        [glyphPath stroke];

        UIImage* numberImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        context = UIGraphicsGetCurrentContext();
        // done creating number
        //


        // clip number
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor whiteColor] setFill];
        [glyphPath fill];
        CGContextSetBlendMode(context, kCGBlendModeNormal);

        //
        // our image that we generated is upside down,
        // so flip again
        CGContextConcatCTM(context, flipVertical);

        // draw number
        [numberImage drawAtPoint:CGPointZero];

        CGContextRestoreGState(context);


        // ============================================================
        // done draw number
    }
}

@end
