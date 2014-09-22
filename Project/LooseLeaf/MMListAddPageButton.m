//
//  MMListAddPageIcon
//  Loose Leaf
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMListAddPageButton.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>

@implementation MMListAddPageButton

@synthesize delegate;

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
        [self.delegate didTapAddButtonInListView];
    }
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
