//
//  MMShareSidebarContainerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMSlidingSidebarContainerView.h"
#import "MMShareItemDelegate.h"

@interface MMShareSidebarContainerView : MMSlidingSidebarContainerView<MMShareItemDelegate>

@property (weak) NSObject<MMShareItemDelegate>* shareDelegate;

-(void) updatePhotoRotation;

@end
