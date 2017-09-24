//
//  MMShareStackSidebarContainerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 12/10/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMFullScreenSidebarContainingView.h"
#import "MMShareItemDelegate.h"
#import "MMVector.h"


@interface MMShareStackSidebarContainerView : MMFullScreenSidebarContainingView <MMShareItemDelegate>

@property (weak) NSObject<MMShareStackSidebarDelegate>* shareDelegate;

- (void)updateInterfaceTo:(UIInterfaceOrientation)orientation;

@end
