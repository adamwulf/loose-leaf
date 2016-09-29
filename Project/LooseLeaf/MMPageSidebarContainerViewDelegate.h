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

- (MMUndoablePaperView*)didRemoveView:(UIView<MMUUIDView>*)view atIndex:(NSUInteger)index fromCountableSidebar:(MMCountableSidebarContainerView*)sidebar;

- (CGPoint)positionOnScreenToScaleScrapTo:(MMScrapView*)scrap;

- (CGFloat)scaleOnScreenToScaleScrapTo:(MMScrapView*)scrap givenOriginalScale:(CGFloat)originalScale;

- (MMScrappedPaperView*)pageForUUID:(NSString*)uuid;

@end
