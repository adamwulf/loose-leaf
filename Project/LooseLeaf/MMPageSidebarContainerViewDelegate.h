//
//  MMPageSidebarContainerViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/27/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapView.h"
#import "MMUndoablePaperView.h"

@class MMCountableSidebarContainerView;

@protocol MMPageSidebarContainerViewDelegate <NSObject>

- (void)willAddView:(UIView<MMUUIDView>*)view toCountableSidebar:(MMCountableSidebarContainerView*)sidebar;

- (void)didAddView:(UIView<MMUUIDView>*)view toCountableSidebar:(MMCountableSidebarContainerView*)sidebar;

- (void)willAddScrapBackToPage:(MMScrapView*)scrap;

- (void)didRemoveView:(UIView<MMUUIDView>*)view atIndex:(NSUInteger)index hadProperties:(BOOL)hadProperties fromCountableSidebar:(MMCountableSidebarContainerView*)sidebar;

- (CGPoint)positionOnScreenToScaleViewTo:(MMScrapView*)scrap fromCountableSidebar:(MMCountableSidebarContainerView*)sidebar;

- (CGFloat)scaleOnScreenToScaleViewTo:(MMScrapView*)scrap givenOriginalScale:(CGFloat)originalScale fromCountableSidebar:(MMCountableSidebarContainerView*)sidebar;

- (MMScrappedPaperView*)pageForUUID:(NSString*)uuid;

@end
