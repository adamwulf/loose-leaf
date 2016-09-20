//
//  MMOfflineIconView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/6/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMOfflineIconView.h"


@implementation MMOfflineIconView

@synthesize shouldDrawOpaque;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code- (void)drawCanvas2WithNumber: (CGFloat)number;
    {
        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextSaveGState(context);

        UIColor* exclaimColor = [[UIColor whiteColor] colorWithAlphaComponent:.7];
        UIColor* wifiBarColor = [[UIColor whiteColor] colorWithAlphaComponent:.3];

        if (self.shouldDrawOpaque) {
            exclaimColor = [UIColor blackColor];
            wifiBarColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
        }


        //// Variable Declarations
        CGFloat wifiLineScaleFactor = 10;
        CGFloat heightRatio = 156.0 / 170.0;
        CGSize framesize = CGSizeMake(self.bounds.size.width, self.bounds.size.width * heightRatio);
        CGFloat lineWidth = framesize.height / wifiLineScaleFactor;

        //// Frames
        CGRect frame = CGRectMake(-framesize.width / 2, 0, framesize.width, framesize.height);

        CGContextTranslateCTM(context, framesize.width / 2, 0);

        //// Subframes
        CGRect leftSide = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * -0.08235 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.15705) + 0.5, floor(CGRectGetWidth(frame) * 1.08235 + 0.5) - floor(CGRectGetWidth(frame) * -0.08235 + 0.5), floor(CGRectGetHeight(frame) * 1.42628) - floor(CGRectGetHeight(frame) * 0.15705));


        //// Wifi Bars Side
        {
            //// Wifi Line 1 Drawing
            CGRect wifiLine1Rect = CGRectMake(CGRectGetMinX(leftSide) + floor(CGRectGetWidth(leftSide) * 0.33333 + 0.5), CGRectGetMinY(leftSide) + floor(CGRectGetHeight(leftSide) * 0.33333 + 0.5), floor(CGRectGetWidth(leftSide) * 0.66667 + 0.5) - floor(CGRectGetWidth(leftSide) * 0.33333 + 0.5), floor(CGRectGetHeight(leftSide) * 0.66667 + 0.5) - floor(CGRectGetHeight(leftSide) * 0.33333 + 0.5));
            UIBezierPath* wifiLine1Path = UIBezierPath.bezierPath;
            [wifiLine1Path addArcWithCenter:CGPointMake(CGRectGetMidX(wifiLine1Rect), CGRectGetMidY(wifiLine1Rect)) radius:CGRectGetWidth(wifiLine1Rect) / 2 startAngle:225 * M_PI / 180 endAngle:315 * M_PI / 180 clockwise:YES];

            [wifiBarColor setStroke];
            wifiLine1Path.lineWidth = lineWidth;
            [wifiLine1Path stroke];


            //// Wifi Line 2 Drawing
            CGRect wifiLine2Rect = CGRectMake(CGRectGetMinX(leftSide) + floor(CGRectGetWidth(leftSide) * 0.16667 + 0.5), CGRectGetMinY(leftSide) + floor(CGRectGetHeight(leftSide) * 0.16667 + 0.5), floor(CGRectGetWidth(leftSide) * 0.83333 + 0.5) - floor(CGRectGetWidth(leftSide) * 0.16667 + 0.5), floor(CGRectGetHeight(leftSide) * 0.83333 + 0.5) - floor(CGRectGetHeight(leftSide) * 0.16667 + 0.5));
            UIBezierPath* wifiLine2Path = UIBezierPath.bezierPath;
            [wifiLine2Path addArcWithCenter:CGPointMake(CGRectGetMidX(wifiLine2Rect), CGRectGetMidY(wifiLine2Rect)) radius:CGRectGetWidth(wifiLine2Rect) / 2 startAngle:225 * M_PI / 180 endAngle:315 * M_PI / 180 clockwise:YES];

            [wifiBarColor setStroke];
            wifiLine2Path.lineWidth = lineWidth;
            [wifiLine2Path stroke];


            //// Wifi Line 3 Drawing
            CGRect wifiLine3Rect = CGRectMake(CGRectGetMinX(leftSide) + floor(CGRectGetWidth(leftSide) * 0.00000 + 0.5), CGRectGetMinY(leftSide) + floor(CGRectGetHeight(leftSide) * 0.00000 + 0.5), floor(CGRectGetWidth(leftSide) * 1.00000 + 0.5) - floor(CGRectGetWidth(leftSide) * 0.00000 + 0.5), floor(CGRectGetHeight(leftSide) * 1.00000 + 0.5) - floor(CGRectGetHeight(leftSide) * 0.00000 + 0.5));
            UIBezierPath* wifiLine3Path = UIBezierPath.bezierPath;
            [wifiLine3Path addArcWithCenter:CGPointMake(CGRectGetMidX(wifiLine3Rect), CGRectGetMidY(wifiLine3Rect)) radius:CGRectGetWidth(wifiLine3Rect) / 2 startAngle:225 * M_PI / 180 endAngle:315 * M_PI / 180 clockwise:YES];

            [wifiBarColor setStroke];
            wifiLine3Path.lineWidth = lineWidth;
            [wifiLine3Path stroke];
        }


        //// Bezier Drawing
        UIBezierPath* exclaimFillPath = UIBezierPath.bezierPath;
        [exclaimFillPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.42353 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04808 * CGRectGetHeight(frame))];
        [exclaimFillPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.57647 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04808 * CGRectGetHeight(frame))];
        [exclaimFillPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.52941 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65385 * CGRectGetHeight(frame))];
        [exclaimFillPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.47059 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65385 * CGRectGetHeight(frame))];
        [exclaimFillPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.42353 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04808 * CGRectGetHeight(frame))];
        [exclaimFillPath closePath];
        exclaimFillPath.lineJoinStyle = kCGLineJoinRound;

        CGContextSetBlendMode(context, kCGBlendModeClear);
        [UIColor.whiteColor setFill];
        [exclaimFillPath fill];
        CGContextSetBlendMode(context, kCGBlendModeNormal);

        [exclaimColor setFill];
        [exclaimFillPath fill];

        //// Top of Exclaim Drawing
        CGRect topOfExclaimRect = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * -0.19412 + 0.5), CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.03526) + 0.5, floor(CGRectGetWidth(frame) * 1.19412 + 0.5) - floor(CGRectGetWidth(frame) * -0.19412 + 0.5), floor(CGRectGetHeight(frame) * 1.54808) - floor(CGRectGetHeight(frame) * 0.03526));
        UIBezierPath* topOfExclaimPath = UIBezierPath.bezierPath;
        [topOfExclaimPath addArcWithCenter:CGPointMake(CGRectGetMidX(topOfExclaimRect), CGRectGetMidY(topOfExclaimRect)) radius:CGRectGetWidth(topOfExclaimRect) / 2 startAngle:264 * M_PI / 180 endAngle:277 * M_PI / 180 clockwise:YES];
        topOfExclaimPath.lineWidth = lineWidth;

        CGContextSetBlendMode(context, kCGBlendModeClear);
        [UIColor.whiteColor setStroke];
        [topOfExclaimPath stroke];
        CGContextSetBlendMode(context, kCGBlendModeNormal);


        //// Wifi Dot Drawing
        UIBezierPath* wifiDotPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.44706 + 0.5),
                                                                                      CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.69551) + 0.5,
                                                                                      floor(CGRectGetWidth(frame) * 0.55294 + 0.5) - floor(CGRectGetWidth(frame) * 0.44706 + 0.5),
                                                                                      floor(CGRectGetHeight(frame) * 0.81090) - floor(CGRectGetHeight(frame) * 0.69551))];

        CGContextSetBlendMode(context, kCGBlendModeClear);
        [UIColor.whiteColor setStroke];
        wifiDotPath.lineWidth = 14 * self.bounds.size.width / 170;
        [wifiDotPath stroke];
        CGContextSetBlendMode(context, kCGBlendModeNormal);

        //// Wifi Dot 2 Drawing
        [exclaimColor setFill];
        [wifiDotPath fill];


        //// Border Bezier Drawing
        UIBezierPath* borderExclaimPath = UIBezierPath.bezierPath;
        [borderExclaimPath moveToPoint:CGPointMake(CGRectGetMinX(frame) + 0.42353 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05769 * CGRectGetHeight(frame))];
        [borderExclaimPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.57647 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05769 * CGRectGetHeight(frame))];
        [borderExclaimPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.52941 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66987 * CGRectGetHeight(frame))];
        [borderExclaimPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.47059 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66987 * CGRectGetHeight(frame))];
        [borderExclaimPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + 0.42353 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05769 * CGRectGetHeight(frame))];
        [borderExclaimPath closePath];
        borderExclaimPath.lineJoinStyle = kCGLineJoinRound;

        CGContextSetBlendMode(context, kCGBlendModeClear);
        [UIColor.whiteColor setStroke];
        borderExclaimPath.lineWidth = 4 * self.bounds.size.width / 170;
        [borderExclaimPath stroke];
        CGContextSetBlendMode(context, kCGBlendModeNormal);

        CGContextRestoreGState(context);
    }
}


@end
