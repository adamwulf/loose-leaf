//
//  MMCountableSidebarContainerViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/29/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMCountableSidebarContainerView, MMUndoablePaperView;

@protocol MMCountableSidebarContainerViewDelegate <NSObject>

- (void)willAddView:(UIView<MMUUIDView>*)view toCountableSidebar:(MMCountableSidebarContainerView*)sidebar;

- (void)didAddView:(UIView<MMUUIDView>*)view toCountableSidebar:(MMCountableSidebarContainerView*)sidebar;

- (void)willRemoveView:(UIView<MMUUIDView>*)view fromCountableSidebar:(MMCountableSidebarContainerView*)sidebar;

- (MMUndoablePaperView*)didRemoveView:(UIView<MMUUIDView>*)view atIndex:(NSUInteger)index fromCountableSidebar:(MMCountableSidebarContainerView*)sidebar;

@end
