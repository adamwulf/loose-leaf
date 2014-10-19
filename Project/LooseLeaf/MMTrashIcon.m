//
//  MMTrashIcon.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMTrashIcon.h"

@implementation MMTrashIcon

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGFloat trueWidth = 80;
    CGFloat lineWidth = trueWidth / 100.0 * 2.0;
    
    rect = CGRectInset(rect, 2, 2);

    //// Color Declarations
    UIColor* alphaWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.502];
    
    //// fill Drawing
    UIBezierPath* fillPath = UIBezierPath.bezierPath;
    [fillPath moveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.63078 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.20001 * CGRectGetHeight(rect))];
    [fillPath addCurveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.64615 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.22000 * CGRectGetHeight(rect)) controlPoint1: CGPointMake(CGRectGetMinX(rect) + 0.63077 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.20000 * CGRectGetHeight(rect)) controlPoint2: CGPointMake(CGRectGetMinX(rect) + 0.64615 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.22000 * CGRectGetHeight(rect))];
    [fillPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.82308 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.22000 * CGRectGetHeight(rect))];
    [fillPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.83077 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.25000 * CGRectGetHeight(rect))];
    [fillPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.79846 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.25000 * CGRectGetHeight(rect))];
    [fillPath addCurveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.79615 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.28000 * CGRectGetHeight(rect)) controlPoint1: CGPointMake(CGRectGetMinX(rect) + 0.79739 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.26392 * CGRectGetHeight(rect)) controlPoint2: CGPointMake(CGRectGetMinX(rect) + 0.79615 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.28000 * CGRectGetHeight(rect))];
    [fillPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.74231 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.79000 * CGRectGetHeight(rect))];
    [fillPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.48846 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.79000 * CGRectGetHeight(rect))];
    [fillPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.43462 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.28000 * CGRectGetHeight(rect))];
    [fillPath addCurveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.43231 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.25000 * CGRectGetHeight(rect)) controlPoint1: CGPointMake(CGRectGetMinX(rect) + 0.43462 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.28000 * CGRectGetHeight(rect)) controlPoint2: CGPointMake(CGRectGetMinX(rect) + 0.43338 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.26392 * CGRectGetHeight(rect))];
    [fillPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.40000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.25000 * CGRectGetHeight(rect))];
    [fillPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.40769 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.22000 * CGRectGetHeight(rect))];
    [fillPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.56920 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.22000 * CGRectGetHeight(rect))];
    [fillPath addCurveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.58462 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.20000 * CGRectGetHeight(rect)) controlPoint1: CGPointMake(CGRectGetMinX(rect) + 0.56923 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.22000 * CGRectGetHeight(rect)) controlPoint2: CGPointMake(CGRectGetMinX(rect) + 0.58462 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.20000 * CGRectGetHeight(rect))];
    [fillPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.63077 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.20000 * CGRectGetHeight(rect))];
    [fillPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.63078 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.20001 * CGRectGetHeight(rect))];
    [fillPath closePath];
    [alphaWhite setFill];
    [fillPath fill];
    
    
    //// can Drawing
    UIBezierPath* canPath = UIBezierPath.bezierPath;
    [canPath moveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.43846 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.34000 * CGRectGetHeight(rect))];
    [canPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.43077 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.34000 * CGRectGetHeight(rect))];
    [canPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.42308 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.28000 * CGRectGetHeight(rect))];
    [canPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.43462 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.28000 * CGRectGetHeight(rect))];
    [canPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.48846 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.79000 * CGRectGetHeight(rect))];
    [canPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.74231 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.79000 * CGRectGetHeight(rect))];
    [canPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.79615 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.28000 * CGRectGetHeight(rect))];
    [canPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.80769 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.28000 * CGRectGetHeight(rect))];
    [canPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.80000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.34000 * CGRectGetHeight(rect))];
    [canPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.79231 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.34000 * CGRectGetHeight(rect))];
    [UIColor.darkGrayColor setStroke];
    canPath.lineWidth = lineWidth;
    [canPath stroke];
    
    
    //// detail3 Drawing
    UIBezierPath* detail3Path = UIBezierPath.bezierPath;
    [detail3Path moveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.71538 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.28000 * CGRectGetHeight(rect))];
    [detail3Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.68846 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.74500 * CGRectGetHeight(rect))];
    [UIColor.darkGrayColor setStroke];
    detail3Path.lineWidth = lineWidth;
    [detail3Path stroke];
    
    
    //// detail2 Drawing
    UIBezierPath* detail2Path = UIBezierPath.bezierPath;
    [detail2Path moveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.61538 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.28000 * CGRectGetHeight(rect))];
    [detail2Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.61538 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.74500 * CGRectGetHeight(rect))];
    [UIColor.darkGrayColor setStroke];
    detail2Path.lineWidth = lineWidth;
    [detail2Path stroke];
    
    
    //// detail1 Drawing
    UIBezierPath* detail1Path = UIBezierPath.bezierPath;
    [detail1Path moveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.51538 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.28000 * CGRectGetHeight(rect))];
    [detail1Path addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.54231 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.74500 * CGRectGetHeight(rect))];
    [UIColor.darkGrayColor setStroke];
    detail1Path.lineWidth = lineWidth;
    [detail1Path stroke];
    
    
    //// lid Drawing
    UIBezierPath* lidPath = UIBezierPath.bezierPath;
    [lidPath moveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.40769 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.22000 * CGRectGetHeight(rect))];
    [lidPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.56923 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.22000 * CGRectGetHeight(rect))];
    [lidPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.58462 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.20000 * CGRectGetHeight(rect))];
    [lidPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.63077 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.20000 * CGRectGetHeight(rect))];
    [lidPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.64615 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.22000 * CGRectGetHeight(rect))];
    [lidPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.82308 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.22000 * CGRectGetHeight(rect))];
    [lidPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.83077 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.25000 * CGRectGetHeight(rect))];
    [lidPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.40000 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.25000 * CGRectGetHeight(rect))];
    [lidPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.40769 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.22000 * CGRectGetHeight(rect))];
    [lidPath closePath];
    [UIColor.darkGrayColor setStroke];
    lidPath.lineWidth = lineWidth;
    [lidPath stroke];
    
    
    //// arrow Drawing
    UIBezierPath* arrowPath = UIBezierPath.bezierPath;
    [arrowPath moveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.17830 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.32001 * CGRectGetHeight(rect))];
    [arrowPath addCurveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.17833 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.42086 * CGRectGetHeight(rect)) controlPoint1: CGPointMake(CGRectGetMinX(rect) + 0.17832 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.34687 * CGRectGetHeight(rect)) controlPoint2: CGPointMake(CGRectGetMinX(rect) + 0.17833 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.38191 * CGRectGetHeight(rect))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.36154 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.42086 * CGRectGetHeight(rect))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.36154 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.60914 * CGRectGetHeight(rect))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.17834 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.60914 * CGRectGetHeight(rect))];
    [arrowPath addCurveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.17834 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.71000 * CGRectGetHeight(rect)) controlPoint1: CGPointMake(CGRectGetMinX(rect) + 0.17834 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.64574 * CGRectGetHeight(rect)) controlPoint2: CGPointMake(CGRectGetMinX(rect) + 0.17834 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.68037 * CGRectGetHeight(rect))];
    [arrowPath addCurveToPoint: CGPointMake(CGRectGetMinX(rect) + 0.03077 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.51503 * CGRectGetHeight(rect)) controlPoint1: CGPointMake(CGRectGetMinX(rect) + 0.17830 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.71006 * CGRectGetHeight(rect)) controlPoint2: CGPointMake(CGRectGetMinX(rect) + 0.03077 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.51503 * CGRectGetHeight(rect))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.17830 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.32000 * CGRectGetHeight(rect))];
    [arrowPath addLineToPoint: CGPointMake(CGRectGetMinX(rect) + 0.17830 * CGRectGetWidth(rect), CGRectGetMinY(rect) + 0.32001 * CGRectGetHeight(rect))];
    [arrowPath closePath];
    [alphaWhite setFill];
    [arrowPath fill];
    [UIColor.darkGrayColor setStroke];
    arrowPath.lineWidth = lineWidth;
    [arrowPath stroke];
}


@end
