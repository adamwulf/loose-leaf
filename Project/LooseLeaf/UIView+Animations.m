//
//  UIView+Animations.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/27/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "UIView+Animations.h"
#import <QuartzCore/QuartzCore.h>
#import "MMShadowedView.h"

@implementation UIView (Animations)

-(void) removeAllAnimationsAndPreservePresentationFrame{
    if([[self.layer animationKeys] count]){
        // look at the presentation of the view (as would be seen during animation)
        CGRect lFrame = [self.layer.presentationLayer frame];
        // look at the view frame to compare
        CGRect vFrame = self.frame;
        if([self isKindOfClass:[MMShadowedView class]]){
            vFrame = [MMShadowedView expandFrame:vFrame];
        }
        if(!CGRectEqualToRect(lFrame, vFrame) && !CGRectEqualToRect(lFrame, CGRectZero)){
            // if they're not equal, then remove all animations
            // and set the frame to the presentation layer's frame
            // so that the gesture will pick up in the middle
            // of the animation instead of immediately reset to
            // its end state
            self.frame = lFrame;
        }
        [self.layer removeAllAnimations];
    }
}

/**
 * this will set the anchor point for a scrap, so that it rotates
 * underneath the gesture realistically, instead of always from
 * it's center
 */
+(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

-(void) bounceWithTransform:(CGAffineTransform)transform{
    // run animation for a fraction of a second
    CGFloat duration = .30;
    
    ////////////////////////////////////////////////////////
    // Animate the button!
    
    // Create a keyframe animation to follow a path back to the center
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    bounceAnimation.removedOnCompletion = YES;
    
    CATransform3D transform3d = CATransform3DMakeAffineTransform(transform);
    
    NSMutableArray* keyTimes = [NSMutableArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.0],
                                [NSNumber numberWithFloat:0.4],
                                [NSNumber numberWithFloat:0.7],
                                [NSNumber numberWithFloat:1.0], nil];
    bounceAnimation.keyTimes = keyTimes;
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSValue valueWithCATransform3D:CATransform3DConcat(transform3d, CATransform3DMakeScale(1.0, 1.0, 1.0))],
                              [NSValue valueWithCATransform3D:CATransform3DConcat(transform3d, CATransform3DMakeScale(1.4, 1.4, 1.0))],
                              [NSValue valueWithCATransform3D:CATransform3DConcat(transform3d, CATransform3DMakeScale(0.8, 0.8, 1.0))],
                              [NSValue valueWithCATransform3D:CATransform3DConcat(transform3d, CATransform3DMakeScale(1.0, 1.0, 1.0))],
                              nil];
    bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], nil];
    
    bounceAnimation.duration = duration;
    
    ///////////////////////////////////////////////
    // Add the animations to the layers
    [self.layer addAnimation:bounceAnimation forKey:@"animateSize"];
}

-(void) bounce{
    [self bounceWithTransform:CGAffineTransformIdentity];
}

@end
