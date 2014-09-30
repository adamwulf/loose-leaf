//
//  MMDebugDrawView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/7/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMDebugDrawView : UIView

+(MMDebugDrawView*) sharedInstance;

-(void) clear;

-(void) addCurve:(UIBezierPath*)path;

-(void) drawPoint:(CGPoint)p;

@end
