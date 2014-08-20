//
//  MMCloudKitButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/20/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitButton.h"

@implementation MMCloudKitButton

-(void) setFrame:(CGRect)frame{
    frame = CGRectInset(frame, -10, -10);
    [super setFrame:frame];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGRect frame = [self drawableFrame];
//    frame = CGRectInset(frame, -10, -10);
//    
//    CGContextSaveGState(context);
//    if(self.isGreyscale){
//        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//        CGContextFillRect(context, frame);
//        [image drawInRect:frame blendMode:kCGBlendModeLuminosity alpha:1.0f];
//    }else{
//        [image drawInRect:frame];
//    }
//    CGContextRestoreGState(context);
//    
//    [self drawDropshadowIfSelected];
    
//    [super drawRect:rect];
    
    
    
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* darkBlue = [UIColor colorWithRed: 0.278 green: 0.357 blue: 0.851 alpha: 1];
    UIColor* lightBlue = [UIColor colorWithRed: 0.286 green: 0.588 blue: 0.929 alpha: 1];
    
    //// Gradient Declarations
    NSArray* gradientColors = [NSArray arrayWithObjects:
                               (id)darkBlue.CGColor,
                               (id)lightBlue.CGColor, nil];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);
    
    //// Frames
    CGRect frame = [self drawableFrame];
    
    
    //// Cloud Drawing
    UIBezierPath* cloudPath = [UIBezierPath bezierPath];
    [cloudPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.22321 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73214 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.09821 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59375 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.22321 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73214 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.09497 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70554 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.19643 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44643 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.10146 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.48196 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.19643 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44643 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28125 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34821 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.19643 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.44643 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.18426 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35123 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.30977 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34862 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.30550 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34746 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.29793 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.34769 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.35268 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37054 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.35715 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35237 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.35268 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37054 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.53121 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24107 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.35268 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37054 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.40462 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23947 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54911 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24107 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.56286 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24147 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.49883 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24089 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45536 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.75024 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24180 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.75000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45536 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.89286 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.59375 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.75000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45536 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.89539 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.46964 * CGRectGetHeight(frame))];
    [cloudPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.75446 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73214 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.89032 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71786 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.75446 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73214 * CGRectGetHeight(frame))];
    [cloudPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.22321 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73214 * CGRectGetHeight(frame))];
    [cloudPath closePath];
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
    
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    

}
@end
