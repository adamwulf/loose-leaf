//
//  MMShapeFillerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 12/16/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMFilledShapeView : UIView

-(void) clear;

-(void) addShapePath:(UIBezierPath*)path;

@end
