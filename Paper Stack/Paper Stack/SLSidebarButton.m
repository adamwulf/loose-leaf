//
//  SLSidebarButton.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLSidebarButton.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>

@implementation SLSidebarButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        [self addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bounceButton:)] autorelease]];
    }
    return self;
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
        
        NSMutableArray* keyTimes = [NSMutableArray arrayWithObjects:
                                    [NSNumber numberWithFloat:0.0],
                                    [NSNumber numberWithFloat:0.4],
                                    [NSNumber numberWithFloat:0.7],
                                    [NSNumber numberWithFloat:1.0], nil];
        bounceAnimation.keyTimes = keyTimes;
        bounceAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
                                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.4, 1.4, 1.0)],
                                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)],
                                  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
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
