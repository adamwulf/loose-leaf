//
//  MMCameraButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/13/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCameraButton.h"
#import "AVHexColor.h"

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
    UIColor* darkBlue = [AVHexColor colorWithHexString:@"0b70be"];
    UIColor* lightBlue = [AVHexColor colorWithHexString:@"0E94FB"];

    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)darkBlue.CGColor,
                               (id)lightBlue.CGColor, nil];
    CGFloat gradientLocations[] = {0, .7};
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
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}



@end
