//
//  SLPolylineButton.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLPolygonButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation SLPolygonButton

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
    
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGRect frame = CGRectMake(kWidthOfSidebarButtonBuffer, kWidthOfSidebarButtonBuffer, smallest - 2*kWidthOfSidebarButtonBuffer, smallest - 2*kWidthOfSidebarButtonBuffer);
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    
    // define dots for graph
    //// Dot 1 Drawing
    UIBezierPath* dot1Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.21) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.64) + 0.5, floor(CGRectGetWidth(frame) * 0.15), floor(CGRectGetHeight(frame) * 0.15))];
    [darkerGreyBorder setStroke];
    //// Dot 2 Drawing
    UIBezierPath* dot2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.61) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.64) + 0.5, floor(CGRectGetWidth(frame) * 0.15), floor(CGRectGetHeight(frame) * 0.15))];
    [darkerGreyBorder setStroke];
    //// Dot 3 Drawing
    UIBezierPath* dot3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.69) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.31) + 0.5, floor(CGRectGetWidth(frame) * 0.15), floor(CGRectGetHeight(frame) * 0.15))];
    [darkerGreyBorder setStroke];
    //// Dot 4 Drawing
    UIBezierPath* dot4Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.24) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.2), floor(CGRectGetWidth(frame) * 0.15), floor(CGRectGetHeight(frame) * 0.15))];
    [darkerGreyBorder setStroke];
    
    
    //
    // calculate connections between dots
    
    CGPoint midPoint1 = [self midPointOfPath:dot1Path];
    CGPoint midPoint2 = [self midPointOfPath:dot2Path];
    CGPoint midPoint3 = [self midPointOfPath:dot3Path];
    CGPoint midPoint4 = [self midPointOfPath:dot4Path];
    
    CGPoint per1 = [self perpendicularUnitVectorForPoint:midPoint1 andPoint:midPoint2];
    CGPoint per2 = [self perpendicularUnitVectorForPoint:midPoint2 andPoint:midPoint3];
    CGPoint per3 = [self perpendicularUnitVectorForPoint:midPoint3 andPoint:midPoint4];
    CGPoint per4 = [self perpendicularUnitVectorForPoint:midPoint4 andPoint:midPoint1];
    
    UIBezierPath* rect1 = [self pathForLineGivePoint:midPoint1 andPoint:midPoint2 andVector:per1 andWidth:1.5];
    UIBezierPath* rect2 = [self pathForLineGivePoint:midPoint2 andPoint:midPoint3 andVector:per2 andWidth:1.5];
    UIBezierPath* rect3 = [self pathForLineGivePoint:midPoint3 andPoint:midPoint4 andVector:per3 andWidth:1.5];
    UIBezierPath* rect4 = [self pathForLineGivePoint:midPoint4 andPoint:midPoint1 andVector:per4 andWidth:1.5];

    UIBezierPath* thinRect1 = [self pathForLineGivePoint:midPoint1 andPoint:midPoint2 andVector:per1 andWidth:0.5];
    UIBezierPath* thinRect2 = [self pathForLineGivePoint:midPoint2 andPoint:midPoint3 andVector:per2 andWidth:0.5];
    UIBezierPath* thinRect3 = [self pathForLineGivePoint:midPoint3 andPoint:midPoint4 andVector:per3 andWidth:0.5];
    UIBezierPath* thinRect4 = [self pathForLineGivePoint:midPoint4 andPoint:midPoint1 andVector:per4 andWidth:0.5];
    
    // Fill Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.01) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.01) + 0.5, floor(CGRectGetWidth(frame) * 0.97), floor(CGRectGetHeight(frame) * 0.97))];
    [ovalPath closePath];
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
    
    // stroke the lines
    [darkerGreyBorder setStroke];
    [rect1 stroke];
    [rect2 stroke];
    [rect3 stroke];
    [rect4 stroke];
    
    // erase the line border that is inside the circle
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [dot1Path fill];
    [dot2Path fill];
    [dot3Path fill];
    [dot4Path fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    // stroke the circle
    [dot1Path stroke];
    [dot2Path stroke];
    [dot3Path stroke];
    [dot4Path stroke];

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
    
}


-(UIBezierPath*) pathForLineGivePoint:(CGPoint)p1 andPoint:(CGPoint) p2 andVector:(CGPoint)pv andWidth:(CGFloat)width{
    UIBezierPath* linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint: CGPointMake(p1.x + (width/2)*pv.y, p1.y - (width/2)*pv.x)];
    [linePath addLineToPoint: CGPointMake(p1.x - (width/2)*pv.y, p1.y + (width/2)*pv.x)];
    [linePath addLineToPoint: CGPointMake(p2.x - (width/2)*pv.y, p2.y + (width/2)*pv.x)];
    [linePath addLineToPoint: CGPointMake(p2.x + (width/2)*pv.y, p2.y - (width/2)*pv.x)];
    [linePath addLineToPoint: CGPointMake(p1.x + (width/2)*pv.y, p1.y - (width/2)*pv.x)];
    [linePath closePath];
    linePath.lineJoinStyle = kCGLineJoinRound;
    return linePath;
}


/**
 * returns the midpoint of a bezier curve
 */
-(CGPoint) midPointOfPath:(UIBezierPath*)path{
    CGRect bounds = path.bounds;
    return CGPointMake(bounds.origin.x + bounds.size.width / 2, bounds.origin.y + bounds.size.height / 2);
}

/**
 * returns a unit vector that's perpendicular to the line
 * between the input points
 */
-(CGPoint) perpendicularUnitVectorForPoint:(CGPoint)p1 andPoint:(CGPoint) p2{
    CGFloat dx = p1.x-p2.x;
    CGFloat dy = p1.y-p2.y;
    CGFloat dist = sqrt(dx*dx + dy*dy);
    dx /= dist;
    dy /= dist;
    return CGPointMake(dx, dy);
    /*
    CGFloat x3 = x1 + (N/2)*dy;
    CGFloat y3 = y1 - (N/2)*dx;
    CGFloat x4 = x1 - (N/2)*dy;
    CGFloat y4 = y1 + (N/2)*dx;
     */
}


@end
