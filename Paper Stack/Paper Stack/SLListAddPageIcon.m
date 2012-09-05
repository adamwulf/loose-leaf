//
//  SLListAddPageIcon
//  Paper Stack
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLListAddPageIcon.h"

@implementation SLListAddPageIcon

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
    //// Color Declarations
    UIColor* quarterWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.25];
    UIColor* barelyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.12];
    
    //// Frames
    CGRect frame = CGRectMake(0, 0, 192, 256);
    
    //// Subframes
    CGRect plusFrame = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.27), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.32), floor(CGRectGetWidth(frame) * 0.47), floor(CGRectGetHeight(frame) * 0.35));
    
    //// Abstracted Graphic Attributes
    CGFloat dashedBorderStrokeWidth = 2;
    CGFloat plusStrokeWidth = 1;
    
    
    //// DashedBorder Drawing
    UIBezierPath* dashedBorderPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5, 191, 255) cornerRadius: 24];
    [quarterWhite setStroke];
    dashedBorderPath.lineWidth = dashedBorderStrokeWidth;
    CGFloat dashedBorderPattern[] = {35, 10};
    [dashedBorderPath setLineDash: dashedBorderPattern count:2 phase: 0];
    [dashedBorderPath stroke];
    
    
    //// Plus Drawing
    UIBezierPath* plusPath = [UIBezierPath bezierPath];
    [plusPath moveToPoint: CGPointMake(CGRectGetMinX(plusFrame) + 0.34 * CGRectGetWidth(plusFrame), CGRectGetMinY(plusFrame) + 0.01 * CGRectGetHeight(plusFrame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(plusFrame) + 0.34 * CGRectGetWidth(plusFrame), CGRectGetMinY(plusFrame) + 0.34 * CGRectGetHeight(plusFrame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(plusFrame) + 0.01 * CGRectGetWidth(plusFrame), CGRectGetMinY(plusFrame) + 0.34 * CGRectGetHeight(plusFrame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(plusFrame) + 0.01 * CGRectGetWidth(plusFrame), CGRectGetMinY(plusFrame) + 0.67 * CGRectGetHeight(plusFrame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(plusFrame) + 0.34 * CGRectGetWidth(plusFrame), CGRectGetMinY(plusFrame) + 0.67 * CGRectGetHeight(plusFrame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(plusFrame) + 0.34 * CGRectGetWidth(plusFrame), CGRectGetMinY(plusFrame) + 0.99 * CGRectGetHeight(plusFrame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(plusFrame) + 0.66 * CGRectGetWidth(plusFrame), CGRectGetMinY(plusFrame) + 0.99 * CGRectGetHeight(plusFrame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(plusFrame) + 0.66 * CGRectGetWidth(plusFrame), CGRectGetMinY(plusFrame) + 0.67 * CGRectGetHeight(plusFrame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(plusFrame) + 0.99 * CGRectGetWidth(plusFrame), CGRectGetMinY(plusFrame) + 0.67 * CGRectGetHeight(plusFrame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(plusFrame) + 0.99 * CGRectGetWidth(plusFrame), CGRectGetMinY(plusFrame) + 0.34 * CGRectGetHeight(plusFrame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(plusFrame) + 0.66 * CGRectGetWidth(plusFrame), CGRectGetMinY(plusFrame) + 0.34 * CGRectGetHeight(plusFrame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(plusFrame) + 0.66 * CGRectGetWidth(plusFrame), CGRectGetMinY(plusFrame) + 0.01 * CGRectGetHeight(plusFrame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(plusFrame) + 0.34 * CGRectGetWidth(plusFrame), CGRectGetMinY(plusFrame) + 0.01 * CGRectGetHeight(plusFrame))];
    [plusPath closePath];
    [barelyWhite setFill];
    [plusPath fill];
    
    [quarterWhite setStroke];
    plusPath.lineWidth = plusStrokeWidth;
    [plusPath stroke];
    

    
    
}


@end
