//
//  UIView+Animations.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/27/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Animations)

-(void) removeAllAnimationsAndPreservePresentationFrame;

+(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view;

-(void) bounceWithTransform:(CGAffineTransform)transform;

-(void) bounce;

@end
