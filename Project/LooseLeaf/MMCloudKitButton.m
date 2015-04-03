//
//  MMCloudKitButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/20/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitButton.h"
#import "Constants.h"

@implementation MMCloudKitButton

-(void) setFrame:(CGRect)frame{
    frame = CGRectInset(frame, -10, -10);
    [super setFrame:frame];
}

+(UIBezierPath*) cloudPathForFrame:(CGRect)frame{
    UIBezierPath* cloudPath = [UIBezierPath bezierPath];
    [cloudPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.22321 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73214 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.09821 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59375 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.22321 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73214 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.09497 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70554 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.19643 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44643 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.10146 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48196 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.19643 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44643 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28125 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33929 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.19643 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44643 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.18426 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34230 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.30977 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33969 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.30550 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33853 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.29793 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.33876 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.35268 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37054 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.35715 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34344 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.35268 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37054 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.52228 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23214 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.35268 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37054 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39569 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23054 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.57143 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23214 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.55393 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23254 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.52115 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23196 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45536 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.77256 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23287 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.75000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45536 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.89286 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59375 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.75000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45536 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.89539 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46964 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75446 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73214 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.89032 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71786 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.75446 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73214 * CGRectGetHeight(frame))];
    [cloudPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.22321 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73214 * CGRectGetHeight(frame))];
    [cloudPath closePath];
    return cloudPath;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* darkBlue = [UIColor colorWithRed: 0.278 green: 0.357 blue: 0.851 alpha: 1];
    UIColor* lightBlue = [UIColor colorWithRed: 0.286 green: 0.588 blue: 0.929 alpha: 1];
    
    CGRect frame = [self drawableFrame];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)darkBlue.CGColor,
                               (id)lightBlue.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);

    
    
    UIBezierPath* cloudPath = [MMCloudKitButton cloudPathForFrame:frame];
    
    
    // shadow
    if(self.selected){
        //
        // possible drop shadow
        CGContextSaveGState(context);
        
        UIBezierPath* clipPath = [cloudPath copy];
        [clipPath appendPath:[UIBezierPath bezierPathWithRect:CGRectInfinite]];
        clipPath.usesEvenOddFillRule = YES;
        [clipPath addClip];
        
        
        CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 5.0, [[UIColor whiteColor] CGColor]);
        CGContextAddPath(context, cloudPath.CGPath);
        CGContextDrawPath(context, kCGPathFillStroke);
        CGContextAddPath(context, cloudPath.CGPath);
        CGContextDrawPath(context, kCGPathFillStroke);
        
        CGContextRestoreGState(context);
    }
    
    // draw cloud
    CGContextSaveGState(context);
    [cloudPath addClip];
    CGRect cloudBounds = CGPathGetPathBoundingBox(cloudPath.CGPath);
    CGContextDrawLinearGradient(context, gradient,
                                CGPointMake(CGRectGetMidX(cloudBounds), CGRectGetMinY(cloudBounds)),
                                CGPointMake(CGRectGetMidX(cloudBounds), CGRectGetMaxY(cloudBounds)),
                                0);
    CGContextRestoreGState(context);
    [[UIColor whiteColor] setStroke];
    cloudPath.lineWidth = 2;
    [cloudPath stroke];

    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}




@end
