//
//  MMSidebarImagePicker.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSidebarButton.h"
#import "MMSlidingSidebarContainerViewDelegate.h"

#define kBounceWidth 10.0


@interface MMSlidingSidebarContentView : UIView{
    __weak NSObject<MMSlidingSidebarContainerViewDelegate>* delegate;
}

@property (nonatomic, weak) NSObject<MMSlidingSidebarContainerViewDelegate>* delegate;

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton*)_button animateFromLeft:(BOOL)fromLeft;

- (void)bounceAnimationForButtonWithDuration:(CGFloat)animationDuration;

-(CGRect) contentBounds;

@end
