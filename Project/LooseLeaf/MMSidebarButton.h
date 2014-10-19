//
//  MMSidebarButton.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/21/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSidebarButtonDelegate.h"
#import "MMBounceButton.h"

@interface MMSidebarButton : MMBounceButton{
    NSObject<MMSidebarButtonDelegate>* __weak delegate;
}

@property (nonatomic, weak) NSObject<MMSidebarButtonDelegate>* delegate;
@property (nonatomic, readonly) UIColor* backgroundColor;
@property (nonatomic, readonly) UIColor* borderColor;
@property (nonatomic) UIColor* shadowColor;
@property (nonatomic) CGFloat shadowInset;

-(CGPoint) perpendicularUnitVectorForPoint:(CGPoint)p1 andPoint:(CGPoint) p2;
-(UIBezierPath*) pathForLineGivePoint:(CGPoint)p1 andPoint:(CGPoint) p2 andVector:(CGPoint)pv andWidth:(CGFloat)width;

-(CGRect) drawableFrame;
-(UIBezierPath*) ovalPath;
-(void) drawDropshadowIfSelected;

@end
