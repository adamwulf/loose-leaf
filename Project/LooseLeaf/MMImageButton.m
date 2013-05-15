//
//  MMPaperButton.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/20/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMImageButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation MMImageButton

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
    //
    // Notes for this button
    //
    // the page border bezier has to be added to the oval bezier
    // paintcode keeps them separate
    //
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGRect frame = CGRectMake(kWidthOfSidebarButtonBuffer, kWidthOfSidebarButtonBuffer, smallest - 2*kWidthOfSidebarButtonBuffer, smallest - 2*kWidthOfSidebarButtonBuffer);
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    UIColor* mountainShadow = [UIColor colorWithRed: 0.57 green: 0.57 blue: 0.57 alpha: 0.35];
    
    //// Gradient Declarations
    NSArray* frontMountainGradientColors = [NSArray arrayWithObjects: 
                                            (id)halfGreyFill.CGColor, 
                                            (id)[UIColor colorWithRed: 0.71 green: 0.71 blue: 0.71 alpha: 0.32].CGColor, 
                                            (id)mountainShadow.CGColor, nil];
    CGFloat frontMountainGradientLocations[] = {0, 0.67, 1};
    CGGradientRef frontMountainGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)frontMountainGradientColors, frontMountainGradientLocations);


    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5, floor(CGRectGetWidth(frame) - 0.5), floor(CGRectGetHeight(frame) - 0.5))];
    [ovalPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.21 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.21 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.71 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29 * CGRectGetHeight(frame))];
    [ovalPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.21 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.29 * CGRectGetHeight(frame))];
    [ovalPath closePath];
    
    ovalPath.lineWidth = 1;
    [darkerGreyBorder setStroke];
    [ovalPath stroke];
    [halfGreyFill setFill];
    [ovalPath fill];
    
    //// Mountain 1 Drawing
    UIBezierPath* mountain1Path = [UIBezierPath bezierPath];
    [mountain1Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.7 * CGRectGetHeight(frame))];
    [mountain1Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57 * CGRectGetHeight(frame))];
    [mountain1Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.38 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.4 * CGRectGetHeight(frame))];
    [mountain1Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.6 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.7 * CGRectGetHeight(frame))];
    [mountain1Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.7 * CGRectGetHeight(frame))];
    [mountain1Path closePath];
    CGContextSaveGState(context);
    [mountain1Path addClip];
    CGRect mountain1Bounds = mountain1Path.bounds;
    CGContextDrawLinearGradient(context, frontMountainGradient,
                                CGPointMake(CGRectGetMidX(mountain1Bounds), CGRectGetMinY(mountain1Bounds)),
                                CGPointMake(CGRectGetMidX(mountain1Bounds), CGRectGetMaxY(mountain1Bounds)),
                                0);
    CGContextRestoreGState(context);
    
    
    
    //// Mountain 2 Drawing
    UIBezierPath* mountain2Path = [UIBezierPath bezierPath];
    [mountain2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.6 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.7 * CGRectGetHeight(frame))];
    [mountain2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55 * CGRectGetHeight(frame))];
    [mountain2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45 * CGRectGetHeight(frame))];
    [mountain2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.72 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.6 * CGRectGetHeight(frame))];
    [mountain2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.78 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.7 * CGRectGetHeight(frame))];
    [mountain2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.6 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.7 * CGRectGetHeight(frame))];
    [mountain2Path closePath];
    CGContextSaveGState(context);
    [mountain2Path addClip];
    CGRect mountain2Bounds = mountain2Path.bounds;
    CGContextDrawLinearGradient(context, frontMountainGradient,
                                CGPointMake(CGRectGetMidX(mountain2Bounds), CGRectGetMinY(mountain2Bounds)),
                                CGPointMake(CGRectGetMidX(mountain2Bounds), CGRectGetMaxY(mountain2Bounds)),
                                0);
    CGContextRestoreGState(context);
    
    
    
    //// Sun Drawing
    UIBezierPath* sunPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.64) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.36) + 0.5, floor(CGRectGetWidth(frame) * 0.07), floor(CGRectGetHeight(frame) * 0.07))];
    [halfGreyFill setFill];
    [sunPath fill];
    
    [darkerGreyBorder setStroke];
    sunPath.lineWidth = 1;
    [sunPath stroke];
    
    
    //// Mountain Stroke Drawing
    UIBezierPath* mountainStrokePath = [UIBezierPath bezierPath];
    [mountainStrokePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57 * CGRectGetHeight(frame))];
    [mountainStrokePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.38 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.4 * CGRectGetHeight(frame))];
    [mountainStrokePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55 * CGRectGetHeight(frame))];
    [mountainStrokePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.55 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.45 * CGRectGetHeight(frame))];
    [mountainStrokePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.72 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.6 * CGRectGetHeight(frame))];
    [mountainStrokePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.78 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.7 * CGRectGetHeight(frame))];
    [darkerGreyBorder setStroke];
    mountainStrokePath.lineWidth = 1;
    [mountainStrokePath stroke];
  
    
}


@end
