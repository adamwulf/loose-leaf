//
//  SLPaperButton.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/20/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLInsertImageButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation SLInsertImageButton

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
    CGRect frame = CGRectMake(0, 0, smallest, smallest);
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    UIColor* barelyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.2 + (self.enabled ? 0 : -0.1)];

    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Gradient Declarations
    NSArray* frontMountainGradientColors = [NSArray arrayWithObjects: 
                                            (id)halfGreyFill.CGColor, 
                                            (id)[UIColor colorWithRed: 0.92 green: 0.92 blue: 0.92 alpha: 0.2].CGColor, 
                                            (id)barelyWhite.CGColor, nil];
    CGFloat frontMountainGradientLocations[] = {0, 0.71, 1};
    CGGradientRef frontMountainGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)frontMountainGradientColors, frontMountainGradientLocations);



    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.01) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.01) + 0.5, floor(CGRectGetWidth(frame) * 0.97), floor(CGRectGetHeight(frame) * 0.97))];
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
    [mountain1Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 9, CGRectGetMinY(frame) + 28)];
    [mountain1Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 9, CGRectGetMinY(frame) + 23)];
    [mountain1Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 15, CGRectGetMinY(frame) + 16)];
    [mountain1Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24, CGRectGetMinY(frame) + 28)];
    [mountain1Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 9, CGRectGetMinY(frame) + 28)];
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
    [mountain2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 24, CGRectGetMinY(frame) + 28)];
    [mountain2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 19, CGRectGetMinY(frame) + 22)];
    [mountain2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 22, CGRectGetMinY(frame) + 18)];
    [mountain2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 29, CGRectGetMinY(frame) + 24)];
    [mountain2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 31, CGRectGetMinY(frame) + 28)];
    [mountain2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24, CGRectGetMinY(frame) + 28)];
    [mountain2Path closePath];
    CGContextSaveGState(context);
    [mountain2Path addClip];
    CGRect mountain2Bounds = mountain2Path.bounds;
    CGContextDrawLinearGradient(context, frontMountainGradient,
                                CGPointMake(CGRectGetMidX(mountain2Bounds), CGRectGetMinY(mountain2Bounds)),
                                CGPointMake(CGRectGetMidX(mountain2Bounds), CGRectGetMaxY(mountain2Bounds)),
                                0);
    CGContextRestoreGState(context);


    
    //// Mountain Stroke Drawing
    UIBezierPath* mountainStrokePath = [UIBezierPath bezierPath];
    [mountainStrokePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 9, CGRectGetMinY(frame) + 23)];
    [mountainStrokePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 15, CGRectGetMinY(frame) + 16)];
    [mountainStrokePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 19, CGRectGetMinY(frame) + 22)];
    [mountainStrokePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 22, CGRectGetMinY(frame) + 18)];
    [mountainStrokePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 29, CGRectGetMinY(frame) + 24)];
    [mountainStrokePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 31, CGRectGetMinY(frame) + 28)];
    [darkerGreyBorder setStroke];
    mountainStrokePath.lineWidth = 1;
    [mountainStrokePath stroke];
    
    
    //// Sun Drawing
    UIBezierPath* sunPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + 25.5, CGRectGetMinY(frame) + 14.5, 3, 3)];
    [halfGreyFill setFill];
    [sunPath fill];
    
    [darkerGreyBorder setStroke];
    sunPath.lineWidth = 1;
    [sunPath stroke];


    
}


@end
