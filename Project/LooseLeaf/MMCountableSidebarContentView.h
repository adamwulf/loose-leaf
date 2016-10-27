//
//  MMCountableSidebarContentView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/27/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMCountableSidebarContainerView;


@interface MMCountableSidebarContentView : UIView <UIScrollViewDelegate> {
    UIScrollView* scrollView;
}

@property (nonatomic, weak) MMCountableSidebarContainerView* delegate;
@property (nonatomic, assign) NSInteger columnCount;
@property (nonatomic, readonly) NSArray* itemViews;

- (void)setRotation:(CGFloat)radians;

- (void)didRotateToIdealOrientation:(UIInterfaceOrientation)orientation;

- (void)prepareContentView NS_REQUIRES_SUPER;

- (void)flashScrollIndicators;

- (void)viewWillShow;

- (void)viewWillHide;

- (void)viewDidHide;

@end
