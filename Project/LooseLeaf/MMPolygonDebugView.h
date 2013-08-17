//
//  MMPolygonDebugView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/17/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMPolygonDebugView : UIView

-(void) addTouchPoint:(CGPoint)point;

-(void) clear;

-(void) complete;

-(void) addDebugPoint:(CGPoint)point;

@end
