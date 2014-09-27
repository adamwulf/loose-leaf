//
//  MMImageIconView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMImageIconView.h"

@implementation MMImageIconView

-(UIColor*) borderColor{
    return [UIColor colorWithRed: 0.26 green: 0.26 blue: 0.26 alpha: 0.35];
}

-(UIColor*) halfGreyFill{
    return [UIColor colorWithRed: 0.84 green: 0.84 blue: 0.84 alpha: 0.5];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //
    // Notes for this button
    //
    // the page border bezier has to be added to the oval bezier
    // paintcode keeps them separate
    //
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* strokeColor = [UIColor colorWithRed:.70 green:.70 blue:.70 alpha:.5];
    UIColor* halfGreyFill = [self halfGreyFill];
    UIColor* mountainShadow = [UIColor colorWithRed: 0.501 green: 0.501 blue: 0.501 alpha: 0.35];
    
    //// Gradient Declarations
    CGFloat frontMountainGradientLocations[] = {0, 0.67, 1};
    CGGradientRef frontMountainGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)@[(id)halfGreyFill.CGColor, (id)[UIColor colorWithRed: 0.65 green: 0.65 blue: 0.65 alpha: 0.325].CGColor, (id)mountainShadow.CGColor], frontMountainGradientLocations);
    
    
    //// Page Border Drawing
    UIBezierPath* pageBorderPath = UIBezierPath.bezierPath;
    [pageBorderPath moveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.21667 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.29000 * CGRectGetHeight(rect))];
    [pageBorderPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.21667 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.71000 * CGRectGetHeight(rect))];
    [pageBorderPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.78333 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.71000 * CGRectGetHeight(rect))];
    [pageBorderPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.78333 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.29000 * CGRectGetHeight(rect))];
    [pageBorderPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.21667 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.29000 * CGRectGetHeight(rect))];
    [pageBorderPath closePath];
    [halfGreyFill setFill];
    [pageBorderPath fill];
    
    //// Mountain 1 Drawing
    UIBezierPath* mountain1Path = UIBezierPath.bezierPath;
    [mountain1Path moveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.22500 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.70000 * CGRectGetHeight(rect))];
    [mountain1Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.22500 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.57500 * CGRectGetHeight(rect))];
    [mountain1Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.37500 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.40000 * CGRectGetHeight(rect))];
    [mountain1Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.60000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.70000 * CGRectGetHeight(rect))];
    [mountain1Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.22500 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.70000 * CGRectGetHeight(rect))];
    [mountain1Path closePath];
    CGContextSaveGState(context);
    [mountain1Path addClip];
    CGRect mountain1Bounds = CGPathGetPathBoundingBox(mountain1Path.CGPath);
    CGContextDrawLinearGradient(context, frontMountainGradient,
                                CGPointMake(CGRectGetMidX(mountain1Bounds), CGRectGetMinY(mountain1Bounds)),
                                CGPointMake(CGRectGetMidX(mountain1Bounds), CGRectGetMaxY(mountain1Bounds)),
                                0);
    CGContextRestoreGState(context);
    
    
    //// Mountain 2 Drawing
    UIBezierPath* mountain2Path = UIBezierPath.bezierPath;
    [mountain2Path moveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.60000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.70000 * CGRectGetHeight(rect))];
    [mountain2Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.47500 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.55000 * CGRectGetHeight(rect))];
    [mountain2Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.55667 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.45667 * CGRectGetHeight(rect))];
    [mountain2Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.72500 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.60000 * CGRectGetHeight(rect))];
    [mountain2Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.77500 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.66667 * CGRectGetHeight(rect))];
    [mountain2Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.77500 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.70000 * CGRectGetHeight(rect))];
    [mountain2Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.60000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.70000 * CGRectGetHeight(rect))];
    [mountain2Path closePath];
    CGContextSaveGState(context);
    [mountain2Path addClip];
    CGRect mountain2Bounds = CGPathGetPathBoundingBox(mountain2Path.CGPath);
    CGContextDrawLinearGradient(context, frontMountainGradient,
                                CGPointMake(CGRectGetMidX(mountain2Bounds), CGRectGetMinY(mountain2Bounds)),
                                CGPointMake(CGRectGetMidX(mountain2Bounds), CGRectGetMaxY(mountain2Bounds)),
                                0);
    CGContextRestoreGState(context);
    
    
    //// Sun Drawing
    UIBezierPath* sunPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(rect) + floor(CGRectGetWidth(rect) * 0.63667) + 0.5, CGRectGetMinY(rect) + floor(CGRectGetHeight(rect) * 0.36333) + 0.5, floor(CGRectGetWidth(rect) * 0.71000) - floor(CGRectGetWidth(rect) * 0.63667), floor(CGRectGetHeight(rect) * 0.43667) - floor(CGRectGetHeight(rect) * 0.36333))];
    [halfGreyFill setFill];
    [sunPath fill];
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    sunPath.lineWidth = 2;
    [sunPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [strokeColor setStroke];
    sunPath.lineWidth = 2;
    [sunPath stroke];
    
    
    //// Mountain Stroke Drawing
    UIBezierPath* mountainStrokePath = UIBezierPath.bezierPath;
    [mountainStrokePath moveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.21500 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.58833 * CGRectGetHeight(rect))];
    [mountainStrokePath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.37500 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.40000 * CGRectGetHeight(rect))];
    [mountainStrokePath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.48167 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.54333 * CGRectGetHeight(rect))];
    [mountainStrokePath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.55667 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.45667 * CGRectGetHeight(rect))];
    [mountainStrokePath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.72500 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.60000 * CGRectGetHeight(rect))];
    [mountainStrokePath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.78167 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.67333 * CGRectGetHeight(rect))];
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    mountainStrokePath.lineWidth = 3;
    [mountainStrokePath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [strokeColor setStroke];
    mountainStrokePath.lineWidth = 3;
    [mountainStrokePath stroke];
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    pageBorderPath.lineWidth = 2;
    [pageBorderPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [strokeColor setStroke];
    pageBorderPath.lineWidth = 2;
    [pageBorderPath stroke];
    

    //// Cleanup
    CGGradientRelease(frontMountainGradient);
    CGColorSpaceRelease(colorSpace);
}


@end
