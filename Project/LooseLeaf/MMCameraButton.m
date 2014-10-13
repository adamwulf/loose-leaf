//
//  MMCameraButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/13/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCameraButton.h"

@implementation MMCameraButton

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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    UIColor* darkBlue = [UIColor colorWithRed: 55/255.0 green:203/255.0 blue:246/255.0 alpha: 0.75];
    UIColor* lightBlue = [UIColor colorWithRed: 15/255.0 green:170/255.0 blue:215/255.0 alpha: 0.75];

    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)darkBlue.CGColor,
                               (id)lightBlue.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);

    CGRect frame = [self drawableFrame];
    
    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    [halfGreyFill setFill];
    [ovalPath fill];
    
    CGContextSaveGState(context);
    
    // oval clip
    UIBezierPath *circleClipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [circleClipPath appendPath:ovalPath];
    circleClipPath.usesEvenOddFillRule = YES;
    
    UIImage* cameraIcon = [UIImage imageNamed:@"clearcamera"];
    
    
    // draw blue background
    CGContextSaveGState(context);
    [ovalPath addClip];
    CGRect cloudBounds = CGPathGetPathBoundingBox(ovalPath.CGPath);
    CGContextDrawLinearGradient(context, gradient,
                                CGPointMake(CGRectGetMidX(cloudBounds), CGRectGetMinY(cloudBounds)),
                                CGPointMake(CGRectGetMidX(cloudBounds), CGRectGetMaxY(cloudBounds)),
                                0);
    CGContextRestoreGState(context);

    // draw the camera icon
    [cameraIcon drawInRect:frame];
    
    // clip end of sleeve
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [circleClipPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    // stroke circle
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    
    [self drawDropshadowIfSelected];
    
    [super drawRect:rect];
}



@end
