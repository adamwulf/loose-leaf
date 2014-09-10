//
//  MMRotatingKeyDemoLayer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMRotatingKeyDemoLayer.h"
#import "MMCloudKeyIconLayer.h"
#import "MMCloudLoadingIconLayer.h"

@implementation MMRotatingKeyDemoLayer{
    MMCloudKeyIconLayer* keyLayer;
    MMCloudLoadingIconLayer* animatingCloud;
    BOOL isFlipped;
    BOOL isAnimating;
}


-(id) initWithFrame:(CGRect)frame{
    if(self = [super init]){
        // setup our size
        isFlipped = NO;
        isAnimating = NO;
        
        self.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor].CGColor;
        
        
        CALayer* rotatingLayer = [CALayer layer];
        rotatingLayer.bounds = self.bounds;
        rotatingLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        
        CATransform3D perspective = CATransform3DIdentity;
        perspective.m34 = 1.0/400.0;

        keyLayer = [[MMCloudKeyIconLayer alloc] initWithFrame:CGRectMake(0, 0, 180, 180)];
        keyLayer.transform = perspective;
        
        animatingCloud = [[MMCloudLoadingIconLayer alloc] initWithFrame:CGRectMake(0, 0, 180, 180)];
        animatingCloud.opacity = 0;
        animatingCloud.transform = perspective;
        
        [rotatingLayer addSublayer:keyLayer];
        [rotatingLayer addSublayer:animatingCloud];

        
        [self addSublayer:rotatingLayer];
        
        // setup our location
        self.position = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
    }
    return self;
}

-(void) bounceAndFlip{
    if(isAnimating){
        return;
    }
    
    isAnimating = YES;
    isFlipped = !isFlipped;
    
    // update our model layer immediately
    if(isFlipped){
        animatingCloud.opacity = 1.0;
        keyLayer.opacity = 0.0;
    }else{
        animatingCloud.opacity = 0.0;
        keyLayer.opacity = 1.0;
    }
    
    // now we add the animation which will
    // update the presentation layer.
    // if we updated model after these animations,
    // then it would flicker the values
    CGFloat duration = 0.6;
    NSInteger numberOfFlips = 2;
    CGFloat bounceSize = .2;
    
    CGFloat timestampOfMagicSwitch = (ceilf(numberOfFlips/2.0) + .25) / numberOfFlips;
    
    CGFloat fullFlip = 2*M_PI;

  
    
    // rotation
    CABasicAnimation *rota1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rota1.duration = duration;
    rota1.removedOnCompletion = YES;
    rota1.fromValue = [NSNumber numberWithFloat: 0];
    rota1.toValue = [NSNumber numberWithFloat: numberOfFlips*fullFlip ];
    
    CABasicAnimation *rota2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rota2.duration = duration;
    rota2.removedOnCompletion = YES;
    rota2.fromValue = [NSNumber numberWithFloat: 0];
    rota2.toValue = [NSNumber numberWithFloat: numberOfFlips*fullFlip ];
    
    // scale
    CAKeyframeAnimation* scale11 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scale11.removedOnCompletion = YES;
    scale11.duration = duration;
    scale11.values = @[[NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                       [NSValue valueWithCGPoint:CGPointMake(1.0 + bounceSize, 1.0 + bounceSize)],
                       [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]];
    scale11.keyTimes = @[@(0), @(.5), @(1.0)];
    scale11.fillMode = kCAFillModeBoth;
    scale11.calculationMode = kCAAnimationCubic;
    
    CAKeyframeAnimation* scale21 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scale21.removedOnCompletion = YES;
    scale21.duration = duration;
    scale21.values = @[[NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                       [NSValue valueWithCGPoint:CGPointMake(1.0 + bounceSize, 1.0 + bounceSize)],
                       [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]];
    scale21.keyTimes = @[@(0), @(.5), @(1.0)];
    scale21.fillMode = kCAFillModeBoth;
    scale21.calculationMode = kCAAnimationCubic;
    
    // opacity
    CAKeyframeAnimation* hide1 = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    hide1.removedOnCompletion = YES;
    hide1.duration = duration;
    hide1.values = isFlipped ? @[@(1.0),@(0.0), @(0.0)] : @[@(0.0),@(1.0), @(1.0)];
    hide1.keyTimes = @[@(0), @(timestampOfMagicSwitch), @(1.0)];
    hide1.fillMode = kCAFillModeBoth;
    hide1.calculationMode = kCAAnimationDiscrete;
    
    CAKeyframeAnimation* hide2 = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    hide2.removedOnCompletion = YES;
    hide2.duration = duration;
    hide2.values = isFlipped ? @[@(0.0),@(1.0), @(1.0)] : @[@(1.0),@(0.0), @(0.0)];
    hide2.keyTimes = @[@(0), @(timestampOfMagicSwitch), @(1.0)];
    hide2.fillMode = kCAFillModeBoth;
    hide2.calculationMode = kCAAnimationDiscrete;
    
    // flip both at same time
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        isAnimating = NO;
    }];
    [CATransaction setAnimationDuration:duration];
    [keyLayer addAnimation:hide1 forKey: @"hide"];
    [keyLayer addAnimation:rota1 forKey: @"rotation"];
    [keyLayer addAnimation:scale11 forKey:@"scalex"];
    [animatingCloud addAnimation:hide2 forKey: @"hide"];
    [animatingCloud addAnimation:rota2 forKey: @"rotation"];
    [animatingCloud addAnimation:scale21 forKey:@"scalex"];
    [CATransaction commit];
    
}

-(void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    NSLog(@"animation stopped");
}



@end
