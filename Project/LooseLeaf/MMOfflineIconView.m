//
//  MMOfflineIconView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/6/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMOfflineIconView.h"

@implementation MMOfflineIconView

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
    // Drawing code- (void)drawCanvas2WithNumber: (CGFloat)number;
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        UIColor* color = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
        
        //// Variable Declarations
        CGFloat wifiLineScaleFactor = 10;
        CGFloat heightRatio = 156.0 / 170.0;
        CGSize framesize = CGSizeMake(self.bounds.size.width, self.bounds.size.width*heightRatio);
        CGFloat lineWidth = framesize.height / wifiLineScaleFactor;
        
        //// Frames
        CGRect frame = CGRectMake(0, 0, framesize.width, framesize.height);
        
        //// Subframes
        CGRect leftSide = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * -0.06765) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.15705) + 0.5, floor(CGRectGetWidth(frame) * 1.09706) - floor(CGRectGetWidth(frame) * -0.06765), floor(CGRectGetHeight(frame) * 1.42628) - floor(CGRectGetHeight(frame) * 0.15705));
        
        
        //// Left Side
        {
            //// Wifi Line 5 Drawing
            CGRect wifiLine5Rect = CGRectMake(CGRectGetMinX(leftSide) + floor(CGRectGetWidth(leftSide) * 0.33838 + 0.5), CGRectGetMinY(leftSide) + floor(CGRectGetHeight(leftSide) * 0.33333 + 0.5), floor(CGRectGetWidth(leftSide) * 0.67172 + 0.5) - floor(CGRectGetWidth(leftSide) * 0.33838 + 0.5), floor(CGRectGetHeight(leftSide) * 0.66667 + 0.5) - floor(CGRectGetHeight(leftSide) * 0.33333 + 0.5));
            UIBezierPath* wifiLine5Path = UIBezierPath.bezierPath;
            [wifiLine5Path addArcWithCenter: CGPointMake(CGRectGetMidX(wifiLine5Rect), CGRectGetMidY(wifiLine5Rect)) radius: CGRectGetWidth(wifiLine5Rect) / 2 startAngle: 225 * M_PI/180 endAngle: 315 * M_PI/180 clockwise: YES];
            
            [UIColor.blackColor setStroke];
            wifiLine5Path.lineWidth = lineWidth;
            [wifiLine5Path stroke];
            
            
            //// Wifi Line 6 Drawing
            CGRect wifiLine6Rect = CGRectMake(CGRectGetMinX(leftSide) + floor(CGRectGetWidth(leftSide) * 0.17172 + 0.5), CGRectGetMinY(leftSide) + floor(CGRectGetHeight(leftSide) * 0.16667 + 0.5), floor(CGRectGetWidth(leftSide) * 0.83838 + 0.5) - floor(CGRectGetWidth(leftSide) * 0.17172 + 0.5), floor(CGRectGetHeight(leftSide) * 0.83333 + 0.5) - floor(CGRectGetHeight(leftSide) * 0.16667 + 0.5));
            UIBezierPath* wifiLine6Path = UIBezierPath.bezierPath;
            [wifiLine6Path addArcWithCenter: CGPointMake(CGRectGetMidX(wifiLine6Rect), CGRectGetMidY(wifiLine6Rect)) radius: CGRectGetWidth(wifiLine6Rect) / 2 startAngle: 225 * M_PI/180 endAngle: 315 * M_PI/180 clockwise: YES];
            
            [UIColor.blackColor setStroke];
            wifiLine6Path.lineWidth = lineWidth;
            [wifiLine6Path stroke];
            
            
            //// Wifi Line 7 Drawing
            CGRect wifiLine7Rect = CGRectMake(CGRectGetMinX(leftSide) + floor(CGRectGetWidth(leftSide) * 0.00000 + 0.5), CGRectGetMinY(leftSide) + floor(CGRectGetHeight(leftSide) * 0.00000 + 0.5), floor(CGRectGetWidth(leftSide) * 1.00000 + 0.5) - floor(CGRectGetWidth(leftSide) * 0.00000 + 0.5), floor(CGRectGetHeight(leftSide) * 1.00000 + 0.5) - floor(CGRectGetHeight(leftSide) * 0.00000 + 0.5));
            UIBezierPath* wifiLine7Path = UIBezierPath.bezierPath;
            [wifiLine7Path addArcWithCenter: CGPointMake(CGRectGetMidX(wifiLine7Rect), CGRectGetMidY(wifiLine7Rect)) radius: CGRectGetWidth(wifiLine7Rect) / 2 startAngle: 225 * M_PI/180 endAngle: 315 * M_PI/180 clockwise: YES];
            
            [UIColor.blackColor setStroke];
            wifiLine7Path.lineWidth = lineWidth;
            [wifiLine7Path stroke];
        }
        
        
        //// Bezier Drawing
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.44118 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14103 * CGRectGetHeight(frame))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.59412 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14103 * CGRectGetHeight(frame))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54706 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65385 * CGRectGetHeight(frame))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.48824 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65385 * CGRectGetHeight(frame))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.44118 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14103 * CGRectGetHeight(frame))];
        [bezierPath closePath];
        bezierPath.lineJoinStyle = kCGLineJoinRound;
        
        [UIColor.blackColor setFill];
        [bezierPath fill];
        
        
        //// Wifi Line Drawing
        UIBezierPath* wifiLinePath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * 0.46765) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.69551) + 0.5, floor(CGRectGetWidth(frame) * 0.57353) - floor(CGRectGetWidth(frame) * 0.46765), floor(CGRectGetHeight(frame) * 0.81090) - floor(CGRectGetHeight(frame) * 0.69551))];
        [color setFill];
        [wifiLinePath fill];
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [UIColor.whiteColor setStroke];
        wifiLinePath.lineWidth = 14 * self.bounds.size.width / 170;
        [wifiLinePath stroke];
        CGContextSetBlendMode(context, kCGBlendModeNormal);

        
        //// Wifi Line 2 Drawing
        [color setFill];
        [wifiLinePath fill];
        
        
        //// Top of Exclaim Drawing
        CGRect topOfExclaimRect = CGRectMake(CGRectGetMinX(frame) + floor(CGRectGetWidth(frame) * -0.09118) + 0.5, CGRectGetMinY(frame) + floor(CGRectGetHeight(frame) * 0.13141) + 0.5, floor(CGRectGetWidth(frame) * 1.12059) - floor(CGRectGetWidth(frame) * -0.09118), floor(CGRectGetHeight(frame) * 1.45192) - floor(CGRectGetHeight(frame) * 0.13141));
        UIBezierPath* topOfExclaimPath = UIBezierPath.bezierPath;
        [topOfExclaimPath addArcWithCenter: CGPointMake(CGRectGetMidX(topOfExclaimRect), CGRectGetMidY(topOfExclaimRect)) radius: CGRectGetWidth(topOfExclaimRect) / 2 startAngle: 264 * M_PI/180 endAngle: 276 * M_PI/180 clockwise: YES];
        
        [UIColor.blackColor setStroke];
        topOfExclaimPath.lineWidth = lineWidth;
        [topOfExclaimPath stroke];
        
        
        //// Border Bezier Drawing
        UIBezierPath* borderBezierPath = UIBezierPath.bezierPath;
        [borderBezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.44118 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05769 * CGRectGetHeight(frame))];
        [borderBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.59412 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05769 * CGRectGetHeight(frame))];
        [borderBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.54706 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66987 * CGRectGetHeight(frame))];
        [borderBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.48824 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66987 * CGRectGetHeight(frame))];
        [borderBezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.44118 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05769 * CGRectGetHeight(frame))];
        [borderBezierPath closePath];
        borderBezierPath.lineJoinStyle = kCGLineJoinRound;

        CGContextSetBlendMode(context, kCGBlendModeClear);
        [UIColor.whiteColor setStroke];
        borderBezierPath.lineWidth = 4;
        [borderBezierPath stroke];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
    }
}


@end
