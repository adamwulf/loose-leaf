//
//  SLSidebarButton.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLSidebarButtonDelegate.h"

@interface SLSidebarButton : UIButton{
    NSObject<SLSidebarButtonDelegate>* delegate;
}

@property (nonatomic, assign) NSObject<SLSidebarButtonDelegate>* delegate;
@property (nonatomic, readonly) UIColor* backgroundColor;
@property (nonatomic, readonly) UIColor* borderColor;

-(CGPoint) midPointOfPath:(UIBezierPath*)path;
-(CGPoint) perpendicularUnitVectorForPoint:(CGPoint)p1 andPoint:(CGPoint) p2;
-(UIBezierPath*) pathForLineGivePoint:(CGPoint)p1 andPoint:(CGPoint) p2 andVector:(CGPoint)pv andWidth:(CGFloat)width;

@end
