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

@implementation MMRotatingKeyDemoLayer


-(id) initWithFrame:(CGRect)frame{
    if(self = [super init]){
        // setup our size
        self.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor].CGColor;
        
        
        CALayer* rotatingLayer = [CALayer layer];
        rotatingLayer.bounds = self.bounds;
        rotatingLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        
        CATransform3D perspective = CATransform3DIdentity;
        perspective.m34 = 1.0/400.0;

        MMCloudKeyIconLayer* keyLayer = [[MMCloudKeyIconLayer alloc] initWithFrame:CGRectMake(0, 0, 180, 180)];
        keyLayer.transform = perspective;
        keyLayer.doubleSided = NO;
        
        MMCloudLoadingIconLayer* animatingCloud = [[MMCloudLoadingIconLayer alloc] initWithFrame:CGRectMake(0, 0, 180, 180)];
        animatingCloud.transform = perspective;
        animatingCloud.doubleSided = NO;
        
        [rotatingLayer addSublayer:keyLayer];
        [rotatingLayer addSublayer:animatingCloud];

        
        [self addSublayer:rotatingLayer];
        
        
        CABasicAnimation *rota1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        rota1.duration = 4;
        rota1.removedOnCompletion = NO;
        rota1.fromValue = [NSNumber numberWithFloat: 0];
        rota1.toValue = [NSNumber numberWithFloat: 2*M_PI ];
        rota1.repeatCount = HUGE_VALF;
        
        CABasicAnimation *rota2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        rota2.duration = 4;
        rota2.removedOnCompletion = NO;
        rota2.fromValue = [NSNumber numberWithFloat: -M_PI];
        rota2.toValue = [NSNumber numberWithFloat: M_PI ];
        rota2.repeatCount = HUGE_VALF;

        // flip both at same time
        [CATransaction begin];
        [keyLayer addAnimation: rota1 forKey: @"rotation"];
        [animatingCloud addAnimation: rota2 forKey: @"rotation"];
        [CATransaction commit];
        
        
        
        
        
        // setup our location
        self.position = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
    }
    return self;
}
@end
