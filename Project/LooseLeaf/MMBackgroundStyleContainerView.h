//
//  MMBackgroundStyleContainerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/3/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import "MMFullScreenSidebarContainingView.h"
#import "MMBackgroundStyleContainerViewDelegate.h"

@interface MMBackgroundStyleContainerView : MMFullScreenSidebarContainingView

@property (nonatomic, weak) NSObject<MMBackgroundStyleContainerViewDelegate>* bgDelegate;

@end
