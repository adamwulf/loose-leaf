//
//  MMScrapBezelMenuView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/5/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMScrapSidebarContentViewDelegate.h"
#import "MMSlidingSidebarContainerView.h"

@interface MMScrapSidebarContentView : UIView{
    __weak MMSlidingSidebarContainerView<MMScrapSidebarContentViewDelegate>* delegate;
}

@property (nonatomic, weak) MMSlidingSidebarContainerView<MMScrapSidebarContentViewDelegate>* delegate;
@property (nonatomic, assign) NSInteger columnCount;

-(void) prepareContentView;

-(void) flashScrollIndicators;

@end
