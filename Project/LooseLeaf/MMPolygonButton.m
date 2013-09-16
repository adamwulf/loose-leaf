//
//  MMPolylineButton.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPolygonButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "DrawKit-iOS.h"

@implementation MMPolygonButton

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
    // Create the context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Make sure the remove the anti-alias effect from circle
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    

    CGRect frame = [self drawableFrame];
    
    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    
    
    // define dots for graph
    //// Dot 1 Drawing
    UIBezierPath* dot1Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.21) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.64) + 0.5, floor(CGRectGetWidth(frame) * 0.15), floor(CGRectGetHeight(frame) * 0.15))];
    //// Dot 2 Drawing
    UIBezierPath* dot2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.61) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.64) + 0.5, floor(CGRectGetWidth(frame) * 0.15), floor(CGRectGetHeight(frame) * 0.15))];
    //// Dot 3 Drawing
    UIBezierPath* dot3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.69) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.31) + 0.5, floor(CGRectGetWidth(frame) * 0.15), floor(CGRectGetHeight(frame) * 0.15))];
    //// Dot 4 Drawing
    UIBezierPath* dot4Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.24) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.2), floor(CGRectGetWidth(frame) * 0.15), floor(CGRectGetHeight(frame) * 0.15))];
    
    
    //
    // calculate connections between dots
    
    CGPoint midPoint1 = dot1Path.center;
    CGPoint midPoint2 = dot2Path.center;
    CGPoint midPoint3 = dot3Path.center;
    CGPoint midPoint4 = dot4Path.center;
    
    CGPoint per1 = [self perpendicularUnitVectorForPoint:midPoint1 andPoint:midPoint2];
    CGPoint per2 = [self perpendicularUnitVectorForPoint:midPoint2 andPoint:midPoint3];
    CGPoint per3 = [self perpendicularUnitVectorForPoint:midPoint3 andPoint:midPoint4];
    CGPoint per4 = [self perpendicularUnitVectorForPoint:midPoint4 andPoint:midPoint1];
    
    UIBezierPath* rect1 = [self pathForLineGivePoint:midPoint1 andPoint:midPoint2 andVector:per1 andWidth:1.5];
    UIBezierPath* rect2 = [self pathForLineGivePoint:midPoint2 andPoint:midPoint3 andVector:per2 andWidth:1.5];
    UIBezierPath* rect3 = [self pathForLineGivePoint:midPoint3 andPoint:midPoint4 andVector:per3 andWidth:1.5];
    UIBezierPath* rect4 = [self pathForLineGivePoint:midPoint4 andPoint:midPoint1 andVector:per4 andWidth:1.5];

    /*
    UIBezierPath* thinRect1 = [self pathForLineGivePoint:midPoint1 andPoint:midPoint2 andVector:per1 andWidth:0.5];
    UIBezierPath* thinRect2 = [self pathForLineGivePoint:midPoint2 andPoint:midPoint3 andVector:per2 andWidth:0.5];
    UIBezierPath* thinRect3 = [self pathForLineGivePoint:midPoint3 andPoint:midPoint4 andVector:per3 andWidth:0.5];
    UIBezierPath* thinRect4 = [self pathForLineGivePoint:midPoint4 andPoint:midPoint1 andVector:per4 andWidth:0.5];
    */
    
    // Fill Oval Drawing
    [halfGreyFill setFill];
    [ovalPath fill];
    
    // and stroke button circle
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    
    // erase the lines
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [rect1 fill];
    [rect2 fill];
    [rect3 fill];
    [rect4 fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    [darkerGreyBorder setFill];
    // stroke the lines
    [darkerGreyBorder setStroke];
    [rect1 fill];
    [rect2 fill];
    [rect3 fill];
    [rect4 fill];
    
    // erase the line border that is inside the circle
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [dot1Path fill];
    [dot2Path fill];
    [dot3Path fill];
    [dot4Path fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    // fill the circle
    [darkerGreyBorder setFill];
    [dot1Path fill];
    [dot2Path fill];
    [dot3Path fill];
    [dot4Path fill];

    /*
    //
    // erase the .5pt lines, and do it twice
    // since it's a half pixel
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [thinRect1 fill];[thinRect1 fill];
    [thinRect2 fill];[thinRect2 fill];
    [thinRect3 fill];[thinRect3 fill];
    [thinRect4 fill];[thinRect4 fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
     */
    
    [self drawDropshadowIfSelected];

    [super drawRect:rect];
}


@end
