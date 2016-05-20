//
//  MMGenericBackgroundViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/16/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMGenericBackgroundView;

@protocol MMGenericBackgroundViewDelegate <NSObject>

-(UIView*) contextViewForGenericBackground:(MMGenericBackgroundView*)backgroundView;

-(CGFloat) contextRotationForGenericBackground:(MMGenericBackgroundView*)backgroundView;

-(CGPoint) currentCenterOfBackgroundForGenericBackground:(MMGenericBackgroundView*)backgroundView;

@end
