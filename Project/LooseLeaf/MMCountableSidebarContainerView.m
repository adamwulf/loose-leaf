//
//  MMCountableSidebarContainerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/27/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMCountableSidebarContainerView.h"
#import "Constants.h"

#define kAnimationDuration 0.3


@implementation MMCountableSidebarContainerView {
    CGFloat targetAlpha;
    NSMutableArray* viewsInSidebar;
}

@synthesize contentView = contentView;
@synthesize countButton;

- (id)initWithFrame:(CGRect)frame andCountButton:(MMCountBubbleButton*)_countButton {
    if (self = [super initWithFrame:frame forButton:_countButton animateFromLeft:NO]) {
        targetAlpha = 1;
        viewsInSidebar = [NSMutableArray array];

        countButton = _countButton;
        countButton.delegate = self;
        [countButton addTarget:self action:@selector(countButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (NSArray<MMUUIDView>*)viewsInSidebar {
    return [viewsInSidebar copy];
}

- (BOOL)containsView:(UIView<MMUUIDView>*)view {
    return [[self viewsInSidebar] containsObject:view];
}

- (BOOL)containsViewUUID:(NSString*)viewUUID {
    for (UIView<MMUUIDView>* view in [self viewsInSidebar]) {
        if ([view.uuid isEqualToString:viewUUID]) {
            return YES;
        }
    }
    return NO;
}

- (void)deleteAllViewsFromSidebar {
    for (UIView* otherBubble in self.subviews) {
        if ([otherBubble isKindOfClass:[MMCountBubbleButton class]]) {
            [otherBubble removeFromSuperview];
        }
    }

    [viewsInSidebar removeAllObjects];
}

- (void)didTapOnViewFromMenu:(UIView<MMUUIDView>*)view withPreferredScrapProperties:(NSDictionary*)properties below:(BOOL)below {
    [viewsInSidebar removeObject:view];
    view.center = [self convertPoint:view.center fromView:view.superview];

    if (below) {
        [self insertSubview:view atIndex:0];
    } else {
        [self addSubview:view];
    }

    [self sidebarCloseButtonWasTapped];
    [self.countButton setCount:[[self viewsInSidebar] count]];
}

- (void)addViewToCountableSidebar:(UIView<MMUUIDView>*)view animated:(BOOL)animated {
    [viewsInSidebar addObject:view];
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
        for (UIView<MMUUIDView>* subview in self.subviews) {
            if ([subview isKindOfClass:[MMSidebarButton class]]) {
                subview.alpha = targetAlpha;
            }
        }
    }
    if (!targetAlpha) {
        [self sidebarCloseButtonWasTapped];
    }
}

#pragma mark - Ignore Touches

/**
 * these two methods make sure that this scrap container view
 * can never intercept any touch input. instead it will
 * effectively pass through this view to the views behind it
 */
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
    for (UIView* bubble in self.subviews) {
        if ([bubble isKindOfClass:[MMSidebarButton class]]) {
            UIView* output = [bubble hitTest:[self convertPoint:point toView:bubble] withEvent:event];
            if (output)
                return output;
        }
    }
    if (contentView.alpha) {
        UIView* output = [contentView hitTest:[self convertPoint:point toView:contentView] withEvent:event];
        if (output)
            return output;
    }
    return [super hitTest:point withEvent:event];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    for (UIView* bubble in self.subviews) {
        if ([bubble isKindOfClass:[MMSidebarButton class]]) {
            if ([bubble pointInside:[self convertPoint:point toView:bubble] withEvent:event]) {
                return YES;
            }
        }
    }
    return [super pointInside:point withEvent:event];
}

#pragma mark - MMFullScreenSidebarContainingView

- (void)sidebarCloseButtonWasTapped {
    if ([self isVisible]) {
        [contentView viewWillHide];
        [self hide:YES onComplete:^(BOOL finished) {
            [contentView viewDidHide];
        }];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self setAlpha:1];
        } completion:nil];
        [self.delegate sidebarCloseButtonWasTapped];
    }
}


@end
