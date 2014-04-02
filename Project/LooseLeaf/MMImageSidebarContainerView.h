//
//  MMImageSlidingSidebarView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMSlidingSidebarContainerView.h"
#import "MMImageSidebarContainerViewDelegate.h"

@interface MMImageSidebarContainerView : MMSlidingSidebarContainerView

@property (nonatomic, weak) NSObject<MMImageSidebarContainerViewDelegate>* delegate;

@end
