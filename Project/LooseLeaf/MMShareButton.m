//
//  MMPaperButton.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/20/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMShareButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation MMShareButton

@synthesize arrowColor;
@synthesize topBgColor;
@synthesize bottomBgColor;

-(UIColor*) topBgColor{
    if(!topBgColor){
        return [self backgroundColor];
    }
    return topBgColor;
}

-(UIColor*) bottomBgColor{
    if(!bottomBgColor){
        return [self backgroundColor];
    }
    return bottomBgColor;
}

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

-(void) setGreyscale:(BOOL)greyscale{
    _greyscale = greyscale;
    [self setNeedsDisplay];
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
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* strokeColor = darkerGreyBorder;
    if(arrowColor){
        strokeColor = arrowColor;
    }
    
    //// Gradient Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace;
    if(self.greyscale){
        colorSpace = CGColorSpaceCreateDeviceGray();
    }else{
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    NSArray* faceGradientColors = [NSArray arrayWithObjects:
                                   (id)self.topBgColor.CGColor,
                                   (id)self.bottomBgColor.CGColor, nil];
    CGFloat faceGradientLocations[] = {0, 1};
    CGGradientRef faceGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)faceGradientColors, faceGradientLocations);

    CGBlendMode normalBlendMode = kCGBlendModeNormal;
    
    if(self.isGreyscale){
        CGContextSaveGState(context);
        CGContextSetBlendMode(context, kCGBlendModeLuminosity);
        normalBlendMode = kCGBlendModeLuminosity;
    }

    CGRect frame = [self drawableFrame];
    
    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    
    //// Oval Drawing
    ovalPath.lineWidth = 1;
    [darkerGreyBorder setStroke];
    [ovalPath stroke];
    
    // fill background with gradient
    CGContextSaveGState(context);
    [ovalPath addClip];
    CGRect ovalBounds = CGPathGetPathBoundingBox(ovalPath.CGPath);
    CGContextDrawLinearGradient(context, faceGradient,
                                CGPointMake(CGRectGetMidX(ovalBounds), CGRectGetMinY(ovalBounds)),
                                CGPointMake(CGRectGetMidX(ovalBounds), CGRectGetMaxY(ovalBounds)),
                                0);
    CGContextRestoreGState(context);


    UIBezierPath* boxPath = [UIBezierPath bezierPath];
    [boxPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.32500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.32500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73750 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.67500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73750 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.67500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame))];
    [boxPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.57500 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.38750 * CGRectGetHeight(frame))];
    [strokeColor setStroke];
    boxPath.lineWidth = 2;
    
    
    //// arrow head Drawing
    UIBezierPath* arrowHeadPath = [UIBezierPath bezierPath];
    [arrowHeadPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.40000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28750 * CGRectGetHeight(frame))];
    [arrowHeadPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.18750 * CGRectGetHeight(frame))];
    [arrowHeadPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.60000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.28750 * CGRectGetHeight(frame))];
    arrowHeadPath.lineWidth = 2;
    
    
    //// arrow body Drawing
    UIBezierPath* arrowBodyPath = [UIBezierPath bezierPath];
    [arrowBodyPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56250 * CGRectGetHeight(frame))];
    [arrowBodyPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.21250 * CGRectGetHeight(frame))];
    arrowBodyPath.lineWidth = 2;
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [boxPath stroke];
    [arrowHeadPath stroke];
    CGContextSetBlendMode(context, normalBlendMode);

    [strokeColor setStroke];
    [boxPath stroke];
    [arrowHeadPath stroke];

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [arrowBodyPath stroke];
    CGContextSetBlendMode(context, normalBlendMode);

    [arrowBodyPath stroke];

    
    [self drawDropshadowIfSelected];

    [super drawRect:rect];
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(faceGradient);
    
    if(self.isGreyscale){
        CGContextRestoreGState(context);
    }
}


@end
