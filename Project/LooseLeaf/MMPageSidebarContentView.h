//
//  MMPageSidebarContentView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/27/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMPagesInBezelContainerView.h"


@interface MMPageSidebarContentView : UIView <UIScrollViewDelegate> {
    __weak MMPagesInBezelContainerView* delegate;
}

@property (nonatomic, weak) MMPagesInBezelContainerView* delegate;
@property (nonatomic, assign) NSInteger columnCount;

- (void)setRotation:(CGFloat)radians;

- (void)didRotateToIdealOrientation:(UIInterfaceOrientation)orientation;

- (void)prepareContentView;

- (void)flashScrollIndicators;

- (void)viewWillShow;

- (void)viewWillHide;

- (void)viewDidHide;


@end
