//
//  SYTableBase.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 20/09/12.
//
//

#import "SYTableBase.h"

@implementation SYTableBase

- (void) drawRect:(CGRect)rect
{
    // General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Color Declarations
    UIColor* greyColor = [UIColor colorWithRed: 0.94 green: 0.94 blue: 0.94 alpha: 1];
    
    // Shadow Declarations
    UIColor* shadow = [UIColor blackColor];
    CGSize shadowOffset = CGSizeMake(0, -0);
    CGFloat shadowBlurRadius = 3;
    
    
    // Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(85.5, 59.5)];
    [bezier2Path addLineToPoint: CGPointMake(475.5, 59.5)];
    [bezier2Path addCurveToPoint: CGPointMake(485.5, 69.5) controlPoint1: CGPointMake(481.02, 59.5) controlPoint2: CGPointMake(485.5, 63.98)];
    [bezier2Path addLineToPoint: CGPointMake(485.5, 574.5)];
    [bezier2Path addCurveToPoint: CGPointMake(475.5, 584.5) controlPoint1: CGPointMake(485.5, 580.02) controlPoint2: CGPointMake(481.02, 584.5)];
    [bezier2Path addLineToPoint: CGPointMake(44.5, 584.5)];
    [bezier2Path addCurveToPoint: CGPointMake(34.5, 574.5) controlPoint1: CGPointMake(38.98, 584.5) controlPoint2: CGPointMake(34.5, 580.02)];
    [bezier2Path addLineToPoint: CGPointMake(34.5, 69.5)];
    [bezier2Path addCurveToPoint: CGPointMake(44.5, 59.5) controlPoint1: CGPointMake(34.5, 63.98) controlPoint2: CGPointMake(38.98, 59.5)];
    [bezier2Path addLineToPoint: CGPointMake(51.5, 59.5)];
    [bezier2Path addLineToPoint: CGPointMake(68.5, 42.5)];
    [bezier2Path addLineToPoint: CGPointMake(85.5, 59.5)];
    [bezier2Path closePath];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    [greyColor setFill];
    [bezier2Path fill];
    CGContextRestoreGState(context);
    
    [[UIColor blackColor] setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];
    
}// drawRect

@end
