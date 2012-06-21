//
//  SLPaperButton.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/20/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLPaperButton.h"
#import "SLPaperStackView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+MCDrawSubImage.h"

@implementation SLPaperButton

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
    
    SLPaperStackView* view = (SLPaperStackView*)self.superview;
    
   /*
    UIGraphicsBeginImageContext(CGSizeMake(80, view.stackHolder.frame.size.height));
    [view.stackHolder.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    //// Color Declarations
    UIColor* halfGrey = [UIColor colorWithRed: 0.84 green: 0.84 blue: 0.84 alpha: 0.3];
    
    //// Frames
    CGRect frame = CGRectMake(10, 6, 46, 46);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeDifference);
    
    [image1 drawInRect:rect fromRect:CGRectMake(0, 220, 80, 80) blendMode:kCGBlendModeDifference alpha:1.0];
*/

    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
//    CGContextTranslateCTM(context, 50.0, rect.size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClearRect(context, rect);
    CGContextSetBlendMode(context, kCGBlendModeDifference);
    CGContextClipToRect(context, rect);
    
    [view.stackHolder.layer renderInContext:context];
    
    /*
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 23)];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 0.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 11.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 11.5, CGRectGetMinY(frame) + 0.5)];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 0.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 23.34, CGRectGetMinY(frame) + 0.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 0.5)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 10)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 13, CGRectGetMinY(frame) + 10)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 13, CGRectGetMinY(frame) + 37)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 34, CGRectGetMinY(frame) + 37)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 34, CGRectGetMinY(frame) + 16)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 28.5, CGRectGetMinY(frame) + 10)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 10)];
    [bezier2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 0.5)];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 0.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 0.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 20.12, CGRectGetMinY(frame) + 0.5)];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 45.5, CGRectGetMinY(frame) + 23) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 34.5, CGRectGetMinY(frame) + 0.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 45.5, CGRectGetMinY(frame) + 11.5)];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 45.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 45.5, CGRectGetMinY(frame) + 39.02) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 34.5, CGRectGetMinY(frame) + 45.5)];
    [bezier2Path addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 23) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 11.5, CGRectGetMinY(frame) + 45.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 34.5)];
    [bezier2Path closePath];
//    [[UIColor whiteColor] setFill];
//    [bezier2Path fillWithBlendMode:kCGBlendModeExclusion alpha:1];
    

    CGContextAddPath(context, bezier2Path.CGPath);

    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 11.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 32.5, CGRectGetMinY(frame) + 16.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 16.5)];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 11.5)];
    [bezierPath closePath];
//    [[UIColor whiteColor] setFill];
//    [bezierPath fillWithBlendMode:kCGBlendModeScreen alpha:1];
    
    
    CGContextAddPath(context, bezierPath.CGPath);
    
    
    CGContextClip(context);
    
//    CGContextClipToMask(context, self.bounds, image.CGImage); // respect alpha mask
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetBlendMode(context, kCGBlendModeDifference);
    CGContextFillRect(context, rect); 
    */
    CGContextRestoreGState(context);
}

@end
