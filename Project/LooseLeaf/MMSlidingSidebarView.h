//
//  MMSlidingSidebarView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMSidebarButton.h"
#import "MMSlidingSidebarContentView.h"
#import "MMSlidingSidebarViewDelegate.h"

@interface MMSlidingSidebarView : UIView<MMSlidingSidebarViewDelegate>{
    MMSlidingSidebarContentView* sidebarContentView;
    __weak NSObject<MMSlidingSidebarViewDelegate>* delegate;
}

@property (nonatomic, weak) NSObject<MMSlidingSidebarViewDelegate>* delegate;

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton*)_button animateFromLeft:(BOOL)fromLeft;

-(BOOL) isVisible;

-(void) hide:(BOOL)animated;

-(void) show:(BOOL)animated;

@end
