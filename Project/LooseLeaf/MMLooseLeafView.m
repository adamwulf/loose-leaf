//
//  MMLooseLeafView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/26/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMLooseLeafView.h"
#import "MMLooseLeafViewController.h"


@implementation MMLooseLeafView

/**
 * these two methods make sure that this scrap container view
 * can never intercept any touch input. instead it will
 * effectively pass through this view to the views behind it
 */
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
    UIView* pagesSidebar = self.looseLeafController.bezelPagesContainer;
    UIView* output = [pagesSidebar hitTest:[self convertPoint:point toView:pagesSidebar] withEvent:event];
    if (output) {
        return output;
    }

    return [super hitTest:point withEvent:event];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    for (UIView* bubble in self.subviews) {
        if ([bubble conformsToProtocol:@protocol(MMBubbleButton)]) {
            if ([bubble pointInside:[self convertPoint:point toView:bubble] withEvent:event]) {
                return YES;
            }
        }
    }
    return [super pointInside:point withEvent:event];
}

@end
