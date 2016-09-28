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


@interface MMCountableSidebarContainerView <ViewType : UIView*> : MMFullScreenSidebarContainingView<MMSidebarButtonDelegate>{
    MMCountableSidebarContentView* contentView;
}

@property (nonatomic, strong) MMCountBubbleButton* countButton;
@property (readonly) NSArray* viewsInSidebar;
@property (nonatomic, readonly) MMCountableSidebarContentView* contentView;

- (id)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (id)initWithFrame:(CGRect)frame andCountButton:(MMCountBubbleButton*)countButton;


- (CGPoint)centerForBubbleAtIndex:(NSInteger)index;

- (void)deleteAllViewsFromSidebar;

- (void)didTapOnViewFromMenu:(ViewType)view;

@end
