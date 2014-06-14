//
//  MMRulerToolGestureRecognizer.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/10/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "Constants.h"
#import "MMPanAndPinchGestureRecognizer.h"

@interface MMRulerToolGestureRecognizer : MMPanAndPinchGestureRecognizer<MMPanAndPinchScrapGestureRecognizerDelegate,UIGestureRecognizerDelegate>


@property (nonatomic, readonly) CGFloat initialDistance;

-(BOOL) containsTouch:(UITouch*)touch;

-(CGPoint) point1InView:(UIView*)view;
-(CGPoint) point2InView:(UIView*)view;

@end
