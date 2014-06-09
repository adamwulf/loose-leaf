//
//  MMSidebarButton.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMSidebarButton.h"
#import "Constants.h"
#import "UIColor+Shadow.h"
#import <DrawKit-iOS/DrawKit-iOS.h>
#import <QuartzCore/QuartzCore.h>

@implementation MMSidebarButton

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
//        self.adjustsImageWhenDisabled = NO;
//        self.adjustsImageWhenHighlighted = NO;
    }
    return self;
}

-(void) setSelected:(BOOL)selected{
    if(selected != self.selected){
        [super setSelected:selected];
        [self setNeedsDisplay];
    }
}

-(void) setEnabled:(BOOL)enabled{
    if(enabled != self.enabled){
        [super setEnabled:enabled];
        [self setNeedsDisplay];
    }
}

-(UIColor*) borderColor{
    return [UIColor colorWithRed: 0.26 green: 0.26 blue: 0.26 alpha: 0.35];
}

-(UIColor*) backgroundColor{
    return [UIColor colorWithRed: 0.84 + (self.enabled ? 0 : -0.3) green: 0.84 + (self.enabled ? 0 : -0.3) blue: 0.84 + (self.enabled ? 0 : -0.3) alpha: 0.5 + (self.enabled ? 0 : -0.2)];
}

-(CGRect) drawableFrame{
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    return CGRectMake(kWidthOfSidebarButtonBuffer, kWidthOfSidebarButtonBuffer, smallest - 2*kWidthOfSidebarButtonBuffer, smallest - 2*kWidthOfSidebarButtonBuffer);
}

-(UIBezierPath*) ovalPath{
    CGRect frame = [self drawableFrame];
    return [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5, floor(CGRectGetWidth(frame) - 1.0), floor(CGRectGetHeight(frame) - 1.0))];
}

-(void) drawDropshadowIfSelected{
    if(self.selected){
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

        UIColor* selectedBlueFill = [UIColor blueShadowColor];
        
        CGRect frame = [self drawableFrame];
        UIBezierPath* ovalPath = [self ovalPath];
        
        //
        // possible drop shadow
        UIColor* gradientColor = [selectedBlueFill colorWithAlphaComponent:1];
        UIColor* clearColor = [selectedBlueFill colorWithAlphaComponent:0];
        NSArray* gradientColors = [NSArray arrayWithObjects:
                                   (id)gradientColor.CGColor,
                                   (id)clearColor.CGColor, nil];
        CGFloat gradientLocations[] = {0, 1};
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
        CGContextSaveGState(context);
        
        UIBezierPath* clipPath = [ovalPath copy];
        [clipPath appendPath:[UIBezierPath bezierPathWithRect:CGRectInfinite]];
        clipPath.usesEvenOddFillRule = YES;
        [clipPath addClip];
        
        CGContextDrawRadialGradient(context, gradient,
                                    CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame)), 19,
                                    CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame)), 24.5,
                                    kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
        
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
        
        CGContextRestoreGState(context);
    }
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
}

-(CGFloat) rotation{
    return [self.delegate sidebarButtonRotation];
}

/**
 * creates a rectangular bezier path along the line
 * between the input points with the input width
 */
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



- (void)drawRect:(CGRect)rect{
    if(!self.enabled){
        CGContextRef context = UIGraphicsGetCurrentContext();

        //
        // clear the arrow and box, then fill with
        // border color
        CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
        [[[UIColor whiteColor] colorWithAlphaComponent:.3] setFill];
        [[UIBezierPath bezierPathWithRect:self.bounds] fill];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
    }
}

@end
