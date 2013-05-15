//
//  MMSidebarButton.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSidebarButtonDelegate.h"

@interface MMSidebarButton : UIButton{
    NSObject<MMSidebarButtonDelegate>* delegate;
}

@property (nonatomic, assign) NSObject<MMSidebarButtonDelegate>* delegate;
@property (nonatomic, readonly) UIColor* backgroundColor;
@property (nonatomic, readonly) UIColor* borderColor;

-(CGPoint) midPointOfPath:(UIBezierPath*)path;
-(CGPoint) perpendicularUnitVectorForPoint:(CGPoint)p1 andPoint:(CGPoint) p2;
-(UIBezierPath*) pathForLineGivePoint:(CGPoint)p1 andPoint:(CGPoint) p2 andVector:(CGPoint)pv andWidth:(CGFloat)width;

@end
