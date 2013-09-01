//
//  MMBounceButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/1/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMBounceButton.h"

@implementation MMBounceButton{
    CGFloat rotation;
}

@synthesize rotation;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        [self addTarget:self action:@selector(bounceButton:) forControlEvents:UIControlEventTouchUpInside];
        self.adjustsImageWhenDisabled = NO;
        self.adjustsImageWhenHighlighted = NO;
    }
    return self;
}

-(UIColor*) borderColor{
    return [UIColor colorWithRed: 0.26 green: 0.26 blue: 0.26 alpha: 0.35];
}

-(UIColor*) backgroundColor{
    return [UIColor colorWithRed: 0.84 + (self.enabled ? 0 : -0.3) green: 0.84 + (self.enabled ? 0 : -0.3) blue: 0.84 + (self.enabled ? 0 : -0.3) alpha: 0.5 + (self.enabled ? 0 : -0.2)];
}

-(CGAffineTransform) rotationTransform{
    return CGAffineTransformMakeRotation([self rotation]);
}

-(void) bounceButton:(id)sender{
    if(self.enabled){
        self.center = self.center;
        
        // run animation for a fraction of a second
        CGFloat duration = .30;
        
        ////////////////////////////////////////////////////////
        // Animate the button!
        
        // Create a keyframe animation to follow a path back to the center
        CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        bounceAnimation.removedOnCompletion = YES;
        
        CATransform3D rotationTransform = CATransform3DMakeAffineTransform([self rotationTransform]);
        
        NSMutableArray* keyTimes = [NSMutableArray arrayWithObjects:
                                    [NSNumber numberWithFloat:0.0],
                                    [NSNumber numberWithFloat:0.4],
                                    [NSNumber numberWithFloat:0.7],
                                    [NSNumber numberWithFloat:1.0], nil];
        bounceAnimation.keyTimes = keyTimes;
        bounceAnimation.values = [NSArray arrayWithObjects:
                                  [NSValue valueWithCATransform3D:CATransform3DConcat(rotationTransform, CATransform3DMakeScale(1.0, 1.0, 1.0))],
                                  [NSValue valueWithCATransform3D:CATransform3DConcat(rotationTransform, CATransform3DMakeScale(1.4, 1.4, 1.0))],
                                  [NSValue valueWithCATransform3D:CATransform3DConcat(rotationTransform, CATransform3DMakeScale(0.8, 0.8, 1.0))],
                                  [NSValue valueWithCATransform3D:CATransform3DConcat(rotationTransform, CATransform3DMakeScale(1.0, 1.0, 1.0))],
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
    
}

@end
