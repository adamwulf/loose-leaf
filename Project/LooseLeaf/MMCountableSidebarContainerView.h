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
#import "MMCountableSidebarContainerViewDelegate.h"


@interface MMCountableSidebarContainerView < ViewType : UIView <MMUUIDView>
* > : MMFullScreenSidebarContainingView<MMSidebarButtonDelegate> {
    MMCountableSidebarContentView* contentView;
    NSMutableDictionary* bubbleForScrap;
}

@property (nonatomic, readonly) MMCountBubbleButton* countButton;
@property (readonly) NSArray<ViewType>* viewsInSidebar;
@property (nonatomic, readonly) MMCountableSidebarContentView* contentView;
@property (nonatomic, weak) NSObject<MMCountableSidebarContainerViewDelegate>* bubbleDelegate;

- (id)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (id)initWithFrame:(CGRect)frame forReferenceButtonFrame:(CGRect)buttonFrame animateFromLeft:(BOOL)fromLeft NS_UNAVAILABLE;
- (id)initWithFrame:(CGRect)frame andCountButton:(MMCountBubbleButton*)countButton;

- (BOOL)containsView:(ViewType)view;

- (BOOL)containsViewUUID:(NSString*)viewUUID;

- (CGPoint)centerForBubbleAtIndex:(NSInteger)index;

- (CGFloat)targetAlphaForBubbleButton:(UIView<MMBubbleButton>*)bubble;

- (CGAffineTransform)targetTransformForBubbleButton:(UIView<MMBubbleButton>*)bubble;

- (void)deleteAllViewsFromSidebar NS_REQUIRES_SUPER;

- (void)didTapOnViewFromMenu:(ViewType)view withPreferredProperties:(NSDictionary*)properties below:(BOOL)below;

- (void)addViewToCountableSidebar:(ViewType)view animated:(BOOL)animated;

- (void)didRotateToIdealOrientation:(UIInterfaceOrientation)orientation;

// for sidebar content

- (Class)sidebarButtonClass;

// protected

- (CGSize)sizeForButton;

- (UIView<MMBubbleButton>*)newBubbleForView:(ViewType)scrap;

- (void)bubbleTapped:(UITapGestureRecognizer*)gesture;

- (void)loadCachedPreviewForView:(ViewType)view;

- (void)unloadCachedPreviewForView:(ViewType)view;

- (NSDictionary*)idealPropertiesForViewInBubble:(UIView<MMBubbleButton>*)bubble;

@end
