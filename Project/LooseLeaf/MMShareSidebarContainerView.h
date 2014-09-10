//
//  MMShareSidebarContainerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMSlidingSidebarContainerView.h"
#import "MMShareItemDelegate.h"
#import "MMCloudKitManagerDelegate.h"
#import "MMVector.h"

@interface MMShareSidebarContainerView : MMSlidingSidebarContainerView<MMShareItemDelegate,MMCloudKitManagerDelegate>

@property (weak) NSObject<MMShareItemDelegate>* shareDelegate;

-(void) updateInterfaceTo:(UIInterfaceOrientation)orientation;

@end
