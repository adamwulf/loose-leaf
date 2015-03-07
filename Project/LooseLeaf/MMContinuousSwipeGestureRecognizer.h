//
//  MMContinuousSwipeGestureRecognizer.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/6/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMContinuousSwipeGestureRecognizer : UIPanGestureRecognizer

-(CGPoint) distanceSinceBegin;

@end
