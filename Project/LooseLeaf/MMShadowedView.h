//
//  MMShadowedView.h
//  Loose Leaf
//
//  Created by Adam Wulf on 7/5/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMShadowedView : UIView{
    UIView* contentView;
}
@property (nonatomic, readonly) UIView* contentView;

+(CGRect) expandFrame:(CGRect)rect;
+(CGRect) contractFrame:(CGRect)rect;
+(CGRect) expandBounds:(CGRect)rect;
+(CGRect) contractBounds:(CGRect)rect;

+(CGFloat) shadowWidth;
@end
