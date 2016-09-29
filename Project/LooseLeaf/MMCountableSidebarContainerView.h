//
//  MMCountableSidebarContainerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/27/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMFullScreenSidebarContainingView.h"
#import "MMCountBubbleButton.h"
#import "MMCountableSidebarContentView.h"
#import "MMUUIDView.h"
#import "MMBubbleButton.h"


@interface MMCountableSidebarContainerView < ViewType : UIView <MMUUIDView>
* > : MMFullScreenSidebarContainingView<MMSidebarButtonDelegate> {
    MMCountableSidebarContentView* contentView;
}

@property (nonatomic, strong) MMCountBubbleButton* countButton;
@property (readonly) NSArray<ViewType>* viewsInSidebar;
@property (nonatomic, readonly) MMCountableSidebarContentView* contentView;

- (id)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (id)initWithFrame:(CGRect)frame andCountButton:(MMCountBubbleButton*)countButton;

- (UIView<MMBubbleButton>*)newButtonForView:(ViewType)scrap;

- (BOOL)containsView:(ViewType)view;

- (BOOL)containsViewUUID:(NSString*)viewUUID;

- (CGPoint)centerForBubbleAtIndex:(NSInteger)index;

- (void)deleteAllViewsFromSidebar NS_REQUIRES_SUPER;

- (void)didTapOnViewFromMenu:(ViewType)view withPreferredScrapProperties:(NSDictionary*)properties below:(BOOL)below;

- (void)addViewToCountableSidebar:(ViewType)view animated:(BOOL)animated;


// protected

- (void)bubbleTapped:(UITapGestureRecognizer*)gesture;

- (void)loadCachedPreviewForView:(ViewType)view;

- (void)unloadCachedPreviewForView:(ViewType)view;

@end
