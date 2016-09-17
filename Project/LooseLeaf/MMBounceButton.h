//
//  MMBounceButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/1/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMBounceButton : UIButton

@property (nonatomic, assign) CGFloat rotation;

-(UIColor*) borderColor;

-(UIColor*) backgroundColor;

-(CGAffineTransform) rotationTransform;

-(void) bounceButton;

-(BOOL) shouldBounce;

@end
