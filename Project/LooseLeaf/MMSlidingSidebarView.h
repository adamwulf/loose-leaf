//
//  MMSidebarImagePicker.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSidebarButton.h"

#define kBounceWidth 10.0

@class MMSlidingSidebarContainerView;

@interface MMSlidingSidebarView : UIView{
    __weak MMSlidingSidebarContainerView* delegate;
}

@property (nonatomic, weak) MMSlidingSidebarContainerView* delegate;

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton*)_button animateFromLeft:(BOOL)fromLeft;

-(CGRect) contentBounds;

-(BOOL) isVisible;

-(void) willShow;

-(void) showForDuration:(CGFloat)duration;

-(void) hideAnimation;

-(void) didHide;

@end
