//
//  MMInviteUserButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMInviteUserButton.h"

@implementation MMInviteUserButton

#define kAddButtonMinAnimationScale 0.97
#define kAddButtonMidAnimationScale 0.98
#define kAddButtonMaxAnimationScale 1.03

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]];
    }
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    // animate down
    [UIView animateWithDuration:.15 animations:^{
        self.transform = CGAffineTransformMakeScale(kAddButtonMinAnimationScale, kAddButtonMinAnimationScale);
    }];
}
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    // noop
}
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesEnded:touches withEvent:event];
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    // animate bounce
    
    // run animation for a fraction of a second
    CGFloat duration = .30;
    
    ////////////////////////////////////////////////////////
    // Animate the button!
    
    // Create a keyframe animation to follow a path back to the center
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    bounceAnimation.removedOnCompletion = YES;
    
    NSMutableArray* keyTimes = [NSMutableArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.0],
                                [NSNumber numberWithFloat:0.4],
                                [NSNumber numberWithFloat:0.7],
                                [NSNumber numberWithFloat:1.0], nil];
    bounceAnimation.keyTimes = keyTimes;
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(kAddButtonMinAnimationScale, kAddButtonMinAnimationScale, 1.0)],
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(kAddButtonMaxAnimationScale, kAddButtonMaxAnimationScale, 1.0)],
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(kAddButtonMidAnimationScale, kAddButtonMidAnimationScale, 1.0)],
                              [NSValue valueWithCATransform3D:CATransform3DIdentity],
                              nil];
    bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], nil];
    
    bounceAnimation.duration = duration;
    
    ///////////////////////////////////////////////
    // Add the animations to the layers
    [self.layer addAnimation:bounceAnimation forKey:@"animateSize"];
    self.transform = CGAffineTransformIdentity;
}

-(void) tapped:(UITapGestureRecognizer*)tapGesture{
    if(tapGesture.state == UIGestureRecognizerStateRecognized){
        //
        // event triggered!
//        [self.delegate didTapAddButtonInListView];
        NSLog(@"invite tapped");
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    CGRect frame = CGRectMake(0, 0, rect.size.width, rect.size.width * 3.0 / 4.0);
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* darkerGrey = [UIColor colorWithRed: 0.2 green: 0.2 blue: 0.2 alpha: 0.25];
    UIColor* barelyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.251];
    UIColor* mostlyWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.647];
    
    //// Gradient Declarations
    CGFloat faceGradientLocations[] = {0, 0.71, 1};
    CGGradientRef faceGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)@[(id)mostlyWhite.CGColor, (id)[UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.449].CGColor, (id)barelyWhite.CGColor], faceGradientLocations);
    
    //// Face Drawing
    UIBezierPath* facePath = UIBezierPath.bezierPath;
    [facePath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.26573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83864 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.07437 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78770 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.26573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83864 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.07387 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84046 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23167 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.65393 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.07488 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73495 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.20376 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.68073 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.28829 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.56197 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.25957 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62714 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.29789 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.58152 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.24425 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.27870 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.54242 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.25737 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51589 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.24425 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.23590 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.23113 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.42411 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.24216 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.27743 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.30088 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15230 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.24634 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19437 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.26155 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.17320 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.34930 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14727 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.31997 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14215 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.33461 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14676 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.40154 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15230 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.36487 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14781 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.38050 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14477 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.47075 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.22754 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.44244 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.16693 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.47062 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.19371 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.46446 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.47836 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.47088 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.26138 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.48289 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.43688 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.42671 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.57033 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.44603 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.51984 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.43635 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.52391 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49592 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.66230 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.41707 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.61675 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.46245 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.63188 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.64062 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.78770 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.53411 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.69700 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.63906 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.73332 * CGRectGetHeight(frame))];
    [facePath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.45344 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83864 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.64078 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.84047 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.45344 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83864 * CGRectGetHeight(frame))];
    [facePath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.26573 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.83864 * CGRectGetHeight(frame))];
    [facePath closePath];
    CGContextSaveGState(context);
    [facePath addClip];
    CGRect faceBounds = CGPathGetPathBoundingBox(facePath.CGPath);
    CGContextDrawLinearGradient(context, faceGradient,
                                CGPointMake(CGRectGetMidX(faceBounds), CGRectGetMinY(faceBounds)),
                                CGPointMake(CGRectGetMidX(faceBounds), CGRectGetMaxY(faceBounds)),
                                0);
    CGContextRestoreGState(context);
    [darkerGrey setStroke];
    facePath.lineWidth = 1;
    [facePath stroke];
    
    
    //// Plus Drawing
    UIBezierPath* plusPath = UIBezierPath.bezierPath;
    [plusPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25001 * CGRectGetHeight(frame))];
    [plusPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.84250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25000 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.84250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31894 * CGRectGetHeight(frame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.95250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39000 * CGRectGetHeight(frame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.95250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53000 * CGRectGetHeight(frame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53000 * CGRectGetHeight(frame))];
    [plusPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.67667 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.84250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60422 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.84250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.67667 * CGRectGetHeight(frame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.73750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.67667 * CGRectGetHeight(frame))];
    [plusPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.73750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.73750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.67667 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.73750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60422 * CGRectGetHeight(frame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.53000 * CGRectGetHeight(frame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.63250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39000 * CGRectGetHeight(frame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.73750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39000 * CGRectGetHeight(frame))];
    [plusPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.73750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25000 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.73750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.31894 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.73750 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25000 * CGRectGetHeight(frame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25000 * CGRectGetHeight(frame))];
    [plusPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.84250 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.25001 * CGRectGetHeight(frame))];
    [plusPath closePath];
    CGContextSaveGState(context);
    [plusPath addClip];
    CGRect plusBounds = CGPathGetPathBoundingBox(plusPath.CGPath);
    CGContextDrawLinearGradient(context, faceGradient,
                                CGPointMake(CGRectGetMidX(plusBounds), CGRectGetMinY(plusBounds)),
                                CGPointMake(CGRectGetMidX(plusBounds), CGRectGetMaxY(plusBounds)),
                                0);
    CGContextRestoreGState(context);
    [darkerGrey setStroke];
    plusPath.lineWidth = 1;
    [plusPath stroke];
    
    
    //// Cleanup
    CGGradientRelease(faceGradient);
    CGColorSpaceRelease(colorSpace);
}

@end
