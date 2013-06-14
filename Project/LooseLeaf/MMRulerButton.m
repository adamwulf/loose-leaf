//
//  MMRulerButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 6/1/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMRulerButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation MMRulerButton


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
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Make sure the remove the anti-alias effect from circle
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    UIColor* barelyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.25];
    
    CGRect frame = [self drawableFrame];
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [self ovalPath];
    [halfGreyFill setFill];
    [ovalPath fill];
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    
    
    //
    // draw the compass
    {
        //// Compass Handle Drawing
        UIBezierPath* compassHandlePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + 23.5, CGRectGetMinY(frame) + 7.5, 8, 8)];
        // the stroke is on either side of the path, so a stroke width of 2 should expand the circle by 1 on every side. then the clip will
        // include the stroke, so it won't double draw on the stroke
        UIBezierPath* compassHandleClipPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + 22.5, CGRectGetMinY(frame) + 6.5, 10, 10)];
        
        // cut compass handle out
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor whiteColor] setFill];
        [compassHandleClipPath fill];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        // ok, fill and stroke the head
        [halfGreyFill setFill];
        [compassHandlePath fill];
        [darkerGreyBorder setStroke];
        compassHandlePath.lineWidth = 2;
        [compassHandlePath stroke];
        
        
        //// Compass Head and Hands Path
        UIBezierPath* compassHeadPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + 29.5, CGRectGetMinY(frame) + 6.5, 3, 3)];
        UIBezierPath* compassHandsPath = [UIBezierPath bezierPath];
        [compassHandsPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 14.5, CGRectGetMinY(frame) + 36.5)];
        [compassHandsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 20, CGRectGetMinY(frame) + 32) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 14.5, CGRectGetMinY(frame) + 36.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 18.25, CGRectGetMinY(frame) + 34.9)];
        [compassHandsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 15.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 22.25, CGRectGetMinY(frame) + 29.1) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 15.5)];
        [compassHandsPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 14.5)];
        [compassHandsPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 23.5, CGRectGetMinY(frame) + 12.5)];
        [compassHandsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 20) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 23.5, CGRectGetMinY(frame) + 12.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 8.8, CGRectGetMinY(frame) + 18.07)];
        [compassHandsPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 3.5, CGRectGetMinY(frame) + 24.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 4.2, CGRectGetMinY(frame) + 21.93) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 3.5, CGRectGetMinY(frame) + 24.5)];
        [compassHandsPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 23.5, CGRectGetMinY(frame) + 15.5)];
        [compassHandsPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 23.5, CGRectGetMinY(frame) + 15.5)];
        [compassHandsPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 16.5)];
        [compassHandsPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 14.5, CGRectGetMinY(frame) + 36.5)];
        [compassHandsPath closePath];
        
        
        // cut compass head and hands out
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor whiteColor] setFill];
        [compassHeadPath fill];
        [compassHandsPath fill];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        //// Compass Head Drawing
        [darkerGreyBorder setFill];
        [compassHeadPath fill];
        
        //// Compass Hands Drawing
        [darkerGreyBorder setFill];
        [compassHandsPath fill];
    }
    
    
    //
    // now draw the ruler
    {
        //// Ruler Board Drawing
        UIBezierPath* rulerBoardPath = [UIBezierPath bezierPath];
        [rulerBoardPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 8.5, CGRectGetMinY(frame) + 9.5)];
        [rulerBoardPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 30, CGRectGetMinY(frame) + 31)];
        [rulerBoardPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 26, CGRectGetMinY(frame) + 35)];
        [rulerBoardPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 4.5, CGRectGetMinY(frame) + 13.5)];
        [rulerBoardPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 8.5, CGRectGetMinY(frame) + 9.5)];
        [rulerBoardPath closePath];
        
        
        // clip the rulerBoardPath
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor whiteColor] setFill];
        [rulerBoardPath fill];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        
        [barelyWhite setFill];
        [rulerBoardPath fill];
        [darkerGreyBorder setStroke];
        rulerBoardPath.lineWidth = 0.5;
        [rulerBoardPath stroke];
        
        
        //// Large Tick 1 Drawing
        UIBezierPath* largeTick1Path = [UIBezierPath bezierPath];
        [largeTick1Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 10.5, CGRectGetMinY(frame) + 15)];
        [largeTick1Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 8.5, CGRectGetMinY(frame) + 17)];
        [halfGreyFill setStroke];
        largeTick1Path.lineWidth = 1;
        [largeTick1Path stroke];
        
        
        //// Large Tick 2 Drawing
        UIBezierPath* largeTick2Path = [UIBezierPath bezierPath];
        [largeTick2Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 14, CGRectGetMinY(frame) + 18.5)];
        [largeTick2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 12, CGRectGetMinY(frame) + 20.5)];
        [halfGreyFill setStroke];
        largeTick2Path.lineWidth = 1;
        [largeTick2Path stroke];
        
        
        //// Large Tick 3 Drawing
        UIBezierPath* largeTick3Path = [UIBezierPath bezierPath];
        [largeTick3Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 17.5, CGRectGetMinY(frame) + 22)];
        [largeTick3Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 15.5, CGRectGetMinY(frame) + 24)];
        [halfGreyFill setStroke];
        largeTick3Path.lineWidth = 1;
        [largeTick3Path stroke];
        
        
        //// Large Tick 4 Drawing
        UIBezierPath* largeTick4Path = [UIBezierPath bezierPath];
        [largeTick4Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 21, CGRectGetMinY(frame) + 25.5)];
        [largeTick4Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 19, CGRectGetMinY(frame) + 27.5)];
        [halfGreyFill setStroke];
        largeTick4Path.lineWidth = 1;
        [largeTick4Path stroke];
        
        
        //// Large Tick 5 Drawing
        UIBezierPath* largeTick5Path = [UIBezierPath bezierPath];
        [largeTick5Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 29)];
        [largeTick5Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 22.5, CGRectGetMinY(frame) + 31)];
        [halfGreyFill setStroke];
        largeTick5Path.lineWidth = 1;
        [largeTick5Path stroke];
        
        
        //// Large Tick Drawing
        UIBezierPath* largeTickPath = [UIBezierPath bezierPath];
        [largeTickPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 7.5, CGRectGetMinY(frame) + 14)];
        [largeTickPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 15)];
        [halfGreyFill setStroke];
        largeTickPath.lineWidth = 1;
        [largeTickPath stroke];
        
        
        //// Large Tick 6 Drawing
        UIBezierPath* largeTick6Path = [UIBezierPath bezierPath];
        [largeTick6Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 8.5, CGRectGetMinY(frame) + 15)];
        [largeTick6Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 7.5, CGRectGetMinY(frame) + 16)];
        [halfGreyFill setStroke];
        largeTick6Path.lineWidth = 1;
        [largeTick6Path stroke];
        
        
        //// Large Tick 7 Drawing
        UIBezierPath* largeTick7Path = [UIBezierPath bezierPath];
        [largeTick7Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 13)];
        [largeTick7Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 5.5, CGRectGetMinY(frame) + 14)];
        [halfGreyFill setStroke];
        largeTick7Path.lineWidth = 1;
        [largeTick7Path stroke];
        
        
        //// Large Tick 8 Drawing
        UIBezierPath* largeTick8Path = [UIBezierPath bezierPath];
        [largeTick8Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 11.5, CGRectGetMinY(frame) + 18)];
        [largeTick8Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 10.5, CGRectGetMinY(frame) + 19)];
        [halfGreyFill setStroke];
        largeTick8Path.lineWidth = 1;
        [largeTick8Path stroke];
        
        
        //// Large Tick 9 Drawing
        UIBezierPath* largeTick9Path = [UIBezierPath bezierPath];
        [largeTick9Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 12.5, CGRectGetMinY(frame) + 19)];
        [largeTick9Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 11.5, CGRectGetMinY(frame) + 20)];
        [halfGreyFill setStroke];
        largeTick9Path.lineWidth = 1;
        [largeTick9Path stroke];
        
        
        //// Large Tick 10 Drawing
        UIBezierPath* largeTick10Path = [UIBezierPath bezierPath];
        [largeTick10Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 10.5, CGRectGetMinY(frame) + 17)];
        [largeTick10Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 9.5, CGRectGetMinY(frame) + 18)];
        [halfGreyFill setStroke];
        largeTick10Path.lineWidth = 1;
        [largeTick10Path stroke];
        
        
        //// Large Tick 11 Drawing
        UIBezierPath* largeTick11Path = [UIBezierPath bezierPath];
        [largeTick11Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 15, CGRectGetMinY(frame) + 21.5)];
        [largeTick11Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 14, CGRectGetMinY(frame) + 22.5)];
        [halfGreyFill setStroke];
        largeTick11Path.lineWidth = 1;
        [largeTick11Path stroke];
        
        
        //// Large Tick 12 Drawing
        UIBezierPath* largeTick12Path = [UIBezierPath bezierPath];
        [largeTick12Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 16, CGRectGetMinY(frame) + 22.5)];
        [largeTick12Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 15, CGRectGetMinY(frame) + 23.5)];
        [halfGreyFill setStroke];
        largeTick12Path.lineWidth = 1;
        [largeTick12Path stroke];
        
        
        //// Large Tick 13 Drawing
        UIBezierPath* largeTick13Path = [UIBezierPath bezierPath];
        [largeTick13Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 14, CGRectGetMinY(frame) + 20.5)];
        [largeTick13Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 13, CGRectGetMinY(frame) + 21.5)];
        [halfGreyFill setStroke];
        largeTick13Path.lineWidth = 1;
        [largeTick13Path stroke];
        
        
        //// Large Tick 14 Drawing
        UIBezierPath* largeTick14Path = [UIBezierPath bezierPath];
        [largeTick14Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMinY(frame) + 25)];
        [largeTick14Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 17.5, CGRectGetMinY(frame) + 26)];
        [halfGreyFill setStroke];
        largeTick14Path.lineWidth = 1;
        [largeTick14Path stroke];
        
        
        //// Large Tick 15 Drawing
        UIBezierPath* largeTick15Path = [UIBezierPath bezierPath];
        [largeTick15Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 19.5, CGRectGetMinY(frame) + 26)];
        [largeTick15Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 18.5, CGRectGetMinY(frame) + 27)];
        [halfGreyFill setStroke];
        largeTick15Path.lineWidth = 1;
        [largeTick15Path stroke];
        
        
        //// Large Tick 16 Drawing
        UIBezierPath* largeTick16Path = [UIBezierPath bezierPath];
        [largeTick16Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 17.5, CGRectGetMinY(frame) + 24)];
        [largeTick16Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 16.5, CGRectGetMinY(frame) + 25)];
        [halfGreyFill setStroke];
        largeTick16Path.lineWidth = 1;
        [largeTick16Path stroke];
        
        
        //// Large Tick 17 Drawing
        UIBezierPath* largeTick17Path = [UIBezierPath bezierPath];
        [largeTick17Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 25.5, CGRectGetMinY(frame) + 32)];
        [largeTick17Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 33)];
        [halfGreyFill setStroke];
        largeTick17Path.lineWidth = 1;
        [largeTick17Path stroke];
        
        
        //// Large Tick 18 Drawing
        UIBezierPath* largeTick18Path = [UIBezierPath bezierPath];
        [largeTick18Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 26.5, CGRectGetMinY(frame) + 33)];
        [largeTick18Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 25.5, CGRectGetMinY(frame) + 34)];
        [halfGreyFill setStroke];
        largeTick18Path.lineWidth = 1;
        [largeTick18Path stroke];
        
        
        //// Large Tick 19 Drawing
        UIBezierPath* largeTick19Path = [UIBezierPath bezierPath];
        [largeTick19Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 31)];
        [largeTick19Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 23.5, CGRectGetMinY(frame) + 32)];
        [halfGreyFill setStroke];
        largeTick19Path.lineWidth = 1;
        [largeTick19Path stroke];
        
        
        //// Large Tick 20 Drawing
        UIBezierPath* largeTick20Path = [UIBezierPath bezierPath];
        [largeTick20Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 22, CGRectGetMinY(frame) + 28.5)];
        [largeTick20Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 21, CGRectGetMinY(frame) + 29.5)];
        [halfGreyFill setStroke];
        largeTick20Path.lineWidth = 1;
        [largeTick20Path stroke];
        
        
        //// Large Tick 21 Drawing
        UIBezierPath* largeTick21Path = [UIBezierPath bezierPath];
        [largeTick21Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 23, CGRectGetMinY(frame) + 29.5)];
        [largeTick21Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 22, CGRectGetMinY(frame) + 30.5)];
        [halfGreyFill setStroke];
        largeTick21Path.lineWidth = 1;
        [largeTick21Path stroke];
        
        
        //// Large Tick 22 Drawing
        UIBezierPath* largeTick22Path = [UIBezierPath bezierPath];
        [largeTick22Path moveToPoint: CGPointMake(CGRectGetMinX(frame) + 21, CGRectGetMinY(frame) + 27.5)];
        [largeTick22Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 20, CGRectGetMinY(frame) + 28.5)];
        [halfGreyFill setStroke];
        largeTick22Path.lineWidth = 1;
        [largeTick22Path stroke];
    }
    
    
    [self drawDropshadowIfSelected];

    [super drawRect:rect];
}

@end
