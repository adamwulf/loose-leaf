//
//  MMScrapBubbleView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapBubbleView.h"

@implementation MMScrapBubbleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}


-(UIColor*) borderColor{
    return [UIColor colorWithRed: 0.26 green: 0.26 blue: 0.26 alpha: 0.35];
}

-(UIColor*) backgroundColor{
    return [UIColor colorWithRed: 0.84 green: 0.84 blue: 0.84 alpha: 0.5];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
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


@end
