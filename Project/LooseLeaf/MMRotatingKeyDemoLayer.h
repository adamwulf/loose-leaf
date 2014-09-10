//
//  MMRotatingKeyDemoLayer.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface MMRotatingKeyDemoLayer : CALayer

@property (nonatomic, readonly) BOOL isFlipped;

-(id) initWithFrame:(CGRect)frame;

-(void) flipWithoutAnimation;

-(void) bounceAndFlipWithCompletion:(void (^)())completion;

@end
