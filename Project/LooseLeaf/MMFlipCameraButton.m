//
//  MMFlipCameraButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMFlipCameraButton.h"

@implementation MMFlipCameraButton

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
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    UIColor* barelyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.25];
    UIColor* mostlyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.65];
    UIColor* darkerGrey = [UIColor colorWithRed: 0.2 green: 0.2 blue: 0.2 alpha: 0.25];
    UIColor* treeHighlight = [UIColor colorWithRed: 0.471 green: 0.471 blue: 0.471 alpha: 0.294];
    
    CGRect frame = [self drawableFrame];
    
    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    [halfGreyFill setFill];
    [ovalPath fill];
    
    CGContextSaveGState(context);
    
    // oval clip
    UIBezierPath *circleClipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [circleClipPath appendPath:ovalPath];
    circleClipPath.usesEvenOddFillRule = YES;
    
    
    //// camera Drawing
    UIBezierPath* cameraFramePath = [UIBezierPath bezierPath];
    [cameraFramePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 7.5, CGRectGetMinY(frame) + 12.5)];
    [cameraFramePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 13.5)];
    [cameraFramePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 6.5, CGRectGetMinY(frame) + 27.5)];
    [cameraFramePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 7.5, CGRectGetMinY(frame) + 28.5)];
    [cameraFramePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 32.5, CGRectGetMinY(frame) + 28.5)];
    [cameraFramePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 33.5, CGRectGetMinY(frame) + 27.5)];
    [cameraFramePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 33.5, CGRectGetMinY(frame) + 13.5)];
    [cameraFramePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 32.5, CGRectGetMinY(frame) + 12.5)];
    [cameraFramePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 12.5)];
    [cameraFramePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 24.5, CGRectGetMinY(frame) + 8.5)];
    [cameraFramePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 15.5, CGRectGetMinY(frame) + 8.5)];
    [cameraFramePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 12.5, CGRectGetMinY(frame) + 12.5)];
    [cameraFramePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 7.5, CGRectGetMinY(frame) + 12.5)];
    [cameraFramePath closePath];
    
    UIBezierPath* bottomArrowBodyPath = [UIBezierPath bezierPath];
    [bottomArrowBodyPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 23.64, CGRectGetMinY(frame) + 22.92)];
    [bottomArrowBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 19.14, CGRectGetMinY(frame) + 23.92) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 23.14, CGRectGetMinY(frame) + 23.42) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 22.07, CGRectGetMinY(frame) + 24.42)];
    [bottomArrowBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 14.64, CGRectGetMinY(frame) + 18.92) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 15.91, CGRectGetMinY(frame) + 23.45) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 15.14, CGRectGetMinY(frame) + 20.42)];
    bottomArrowBodyPath.lineWidth = 2;

    UIBezierPath* bottomArrowHeadPath = [UIBezierPath bezierPath];
    [bottomArrowHeadPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 12.5, CGRectGetMinY(frame) + 18.5)];
    [bottomArrowHeadPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 14.5, CGRectGetMinY(frame) + 16.5)];
    [bottomArrowHeadPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 16.5, CGRectGetMinY(frame) + 18.5)];
    [bottomArrowHeadPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 12.5, CGRectGetMinY(frame) + 18.5)];
    [bottomArrowHeadPath closePath];

    UIBezierPath* topArrowBodyPath = [UIBezierPath bezierPath];
    [topArrowBodyPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 16.5, CGRectGetMinY(frame) + 15.5)];
    [topArrowBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 22, CGRectGetMinY(frame) + 14) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 17.5, CGRectGetMinY(frame) + 14.5) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 18.23, CGRectGetMinY(frame) + 13.65)];
    [topArrowBodyPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 25.5, CGRectGetMinY(frame) + 19.5) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 25.27, CGRectGetMinY(frame) + 14.35) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 26, CGRectGetMinY(frame) + 18)];
    topArrowBodyPath.lineWidth = 2;
    
    UIBezierPath* topArrowHeadPath = [UIBezierPath bezierPath];
    [topArrowHeadPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 23.5, CGRectGetMinY(frame) + 19.5)];
    [topArrowHeadPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 27.5, CGRectGetMinY(frame) + 19.5)];
    [topArrowHeadPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 25.5, CGRectGetMinY(frame) + 21.5)];
    [topArrowHeadPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 23.5, CGRectGetMinY(frame) + 19.5)];
    [topArrowHeadPath closePath];

    
    
    // cut the camera out so it's crisp
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [cameraFramePath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    // fill camera bg
    [barelyWhite setFill];
    [cameraFramePath fill];

    // camera border
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [cameraFramePath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    // draw border
    [darkerGreyBorder setStroke];
    [cameraFramePath stroke];

    
    // clip arrow bodies border
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [topArrowBodyPath stroke];
    [bottomArrowBodyPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    // draw arrow bodies
    [darkerGreyBorder setStroke];
    [topArrowBodyPath stroke];
    [bottomArrowBodyPath stroke];
    
    
    // clip arrow bodies border
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [topArrowHeadPath fill];
    [bottomArrowHeadPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    // set fill
    [darkerGreyBorder setFill];
    [topArrowHeadPath fill];
    [bottomArrowHeadPath fill];
    

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [topArrowHeadPath stroke];
    [bottomArrowHeadPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [darkerGreyBorder setStroke];
    [topArrowHeadPath stroke];
    [bottomArrowHeadPath stroke];

    
    // clip end of sleeve
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [circleClipPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    // stroke circle
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    
    [self drawDropshadowIfSelected];
    
    [super drawRect:rect];
}



#pragma mark - Flip Bounce


-(void) bounceWithTransform:(CGAffineTransform)transform{
    // run animation for a fraction of a second
    CGFloat duration = .60;
    
    ////////////////////////////////////////////////////////
    // Animate the button!
    
    // Create a keyframe animation to follow a path back to the center
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    bounceAnimation.removedOnCompletion = YES;
    
    CATransform3D transform3d = CATransform3DMakeAffineTransform(transform);
    
    CATransform3D stepOneTransform = CATransform3DConcat(transform3d, CATransform3DMakeRotation(0, 0, 1, 0));
    stepOneTransform.m34 = 1.0/400.0;
    
    CATransform3D stepTwoTransform = CATransform3DConcat(transform3d, CATransform3DMakeRotation(1*M_PI, 0, 1, 0));
    stepTwoTransform = CATransform3DConcat(stepTwoTransform, CATransform3DMakeScale(1.2, 1.2, 1.0));
    stepTwoTransform.m34 = 1.0/400.0;
    
    CATransform3D stepThreeTransform = CATransform3DConcat(transform3d, CATransform3DMakeRotation(2*M_PI, 0, 1, 0));
    stepThreeTransform.m34 = 1.0/400.0;
    
//    CATransform3D stepFourTransform = CATransform3DConcat(transform3d, CATransform3DMakeRotation(3*M_PI, 0, 1, 0));
//    stepFourTransform.m34 = 1.0/400.0;
    
    
    NSMutableArray* keyTimes = [NSMutableArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.0],
                                [NSNumber numberWithFloat:0.4],
//                                [NSNumber numberWithFloat:0.7],
                                [NSNumber numberWithFloat:1.0], nil];
    bounceAnimation.keyTimes = keyTimes;
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSValue valueWithCATransform3D:stepOneTransform],
                              [NSValue valueWithCATransform3D:stepTwoTransform],
                              [NSValue valueWithCATransform3D:stepThreeTransform],
//                              [NSValue valueWithCATransform3D:stepFourTransform],
                              nil];
    bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
//                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], nil];
    
    bounceAnimation.duration = duration;
    
    ///////////////////////////////////////////////
    // Add the animations to the layers
    [self.layer addAnimation:bounceAnimation forKey:@"animateSize"];
}

@end
