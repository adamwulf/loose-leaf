//
//  MMSlidingSidebarView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSidebarButton.h"
#import "MMSlidingSidebarView.h"
#import "MMSlidingSidebarContainerViewDelegate.h"

@interface MMFullScreenSidebarContainingView : UIView{
    MMSlidingSidebarView* slidingSidebarView;
    __weak NSObject<MMSlidingSidebarContainerViewDelegate>* delegate;
}

@property (nonatomic, weak) NSObject<MMSlidingSidebarContainerViewDelegate>* delegate;

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton*)_button animateFromLeft:(BOOL)fromLeft;

-(void) sidebarCloseButtonWasTapped;

-(BOOL) isVisible;

-(void) hide:(BOOL)animated onComplete:(void(^)(BOOL finished))onComplete;

-(void) show:(BOOL)animated;

-(UIView*) viewForBlur;

@end
