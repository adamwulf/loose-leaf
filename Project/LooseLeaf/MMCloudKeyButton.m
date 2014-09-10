//
//  MMCloudKeyButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKeyButton.h"
#import "MMRotatingKeyDemoLayer.h"

@implementation MMCloudKeyButton{
    MMRotatingKeyDemoLayer* needLoginView;
    NSTimer* bounceTimer;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        needLoginView = [[MMRotatingKeyDemoLayer alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.layer addSublayer:needLoginView];
        
        [self addTarget:needLoginView action:@selector(bounceAndFlip) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(didTapButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void) setupTimer{
    if(!bounceTimer){
        bounceTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(bounceLightly) userInfo:nil repeats:YES];
        [self bounceLightly];
    }
}

-(void) tearDownTimer{
    [bounceTimer invalidate];
    bounceTimer = nil;
}

-(void) didTapButton{
    [self tearDownTimer];
    self.enabled = NO;
}

-(void)bounceLightly{
    CGFloat duration = 0.4;
    [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.25 animations:^{
            self.transform = CGAffineTransformMakeScale(0.9, 0.9);
        }];
        [UIView addKeyframeWithRelativeStartTime:.3 relativeDuration:.4 animations:^{
            self.transform = CGAffineTransformMakeScale(1.1, 1.1);
        }];
        [UIView addKeyframeWithRelativeStartTime:.7 relativeDuration:.35 animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    } completion:nil];
}

@end
