//
//  MMSidebarImagePickerDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMFullScreenSidebarContainingView;

@protocol MMSlidingSidebarContainerViewDelegate <NSObject>

- (void)sidebarCloseButtonWasTapped:(MMFullScreenSidebarContainingView*)sidebar;

- (void)sidebarWillShow:(MMFullScreenSidebarContainingView*)sidebar;

- (void)sidebarWillHide:(MMFullScreenSidebarContainingView*)sidebar;

- (UIView*)viewForBlur;

@end
