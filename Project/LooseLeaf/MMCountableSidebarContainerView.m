//
//  MMCountableSidebarContainerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/27/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMCountableSidebarContainerView.h"
#import "Constants.h"


@implementation MMCountableSidebarContainerView {
    CGFloat targetAlpha;
}

@synthesize contentView = contentView;
@synthesize countButton;

- (id)initWithFrame:(CGRect)frame andCountButton:(MMCountBubbleButton*)_countButton {
    if (self = [super initWithFrame:frame forButton:_countButton animateFromLeft:NO]) {
        targetAlpha = 1;

        countButton = _countButton;
        countButton.delegate = self;
        [countButton addTarget:self action:@selector(countButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (NSArray*)viewsInSidebar {
    @throw kAbstractMethodException;
}

- (void)deleteAllViewsFromSidebar {
    @throw kAbstractMethodException;
}

- (void)didTapOnViewFromMenu:(UIView*)view {
    @throw kAbstractMethodException;
}

#pragma mark - Actions

// count button was tapped,
// so show or hide the menu
// so the user can choose a scrap to add
- (void)countButtonTapped:(UIButton*)button {
    if (countButton.alpha) {
        countButton.alpha = 0;
        [contentView viewWillShow];
        [contentView prepareContentView];
        [self show:YES];
    }
}

#pragma mark - MMSidebarButtonDelegate

- (CGFloat)sidebarButtonRotation {
    return 0;
}

#pragma mark - Helper Methods

- (CGPoint)centerForBubbleAtIndex:(NSInteger)index {
    CGFloat rightBezelSide = self.bounds.size.width - 100;
    // midpoint calculates for 6 buttons
    CGFloat midPointY = (self.bounds.size.height - 6 * 80) / 2;
    CGPoint ret = CGPointMake(rightBezelSide + 40, midPointY + 40);
    ret.y += 80 * index;
    return ret;
}

- (CGFloat)alpha {
    return targetAlpha;
}

- (void)setAlpha:(CGFloat)alpha {
    targetAlpha = alpha;
    if ([[self viewsInSidebar] count] > kMaxButtonsInBezelSidebar) {
        countButton.alpha = targetAlpha;
    } else {
        countButton.alpha = 0;
        for (UIView* subview in self.subviews) {
            if ([subview isKindOfClass:[MMScrapBubbleButton class]]) {
                subview.alpha = targetAlpha;
            }
        }
    }
    if (!targetAlpha) {
        [self sidebarCloseButtonWasTapped];
    }
}
@end
