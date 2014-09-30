//
//  MMBounceButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/1/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMBounceButton.h"
#import "UIView+Animations.h"

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

-(void) bounceButton{
    [self bounceButton:nil];
}

-(void) bounceButton:(id)sender{
    if(self.enabled){
        self.center = self.center;
        [self bounceWithTransform:[self rotationTransform]];
    }
}

@end
