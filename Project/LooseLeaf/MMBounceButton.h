//
//  MMBounceButton.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/1/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMBounceButton : UIView

@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL selected;

-(UIColor*) borderColor;

-(UIColor*) backgroundColor;

-(CGAffineTransform) rotationTransform;

@end
