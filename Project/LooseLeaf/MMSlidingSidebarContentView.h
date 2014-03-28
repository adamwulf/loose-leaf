//
//  MMSidebarImagePicker.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSidebarButton.h"
#import "MMSlidingSidebarViewDelegate.h"

#define kBounceWidth 10.0


@interface MMSlidingSidebarContentView : UIView{
    __weak NSObject<MMSlidingSidebarViewDelegate>* delegate;
}

@property (nonatomic, weak) NSObject<MMSlidingSidebarViewDelegate>* delegate;

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton*)_button animateFromLeft:(BOOL)fromLeft;

- (void)bounceAnimationForButtonWithDuration:(CGFloat)animationDuration;

-(CGRect) contentBounds;

@end
