//
//  MMColoredTextField.m
//  LooseLeaf
//
//  Created by Adam Wulf on 11/11/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMColoredTextField.h"
#import "UIColor+MMAdditions.h"
#import "UIView+NRTextTransitions.h"


@implementation MMColoredTextField {
    UIColor* targetColor;
    BOOL isAnimating;
}

- (void)setTintColor:(UIColor*)tintColor {
    [self setTintColor:tintColor animated:NO];
}

- (void)setTintColor:(UIColor*)tintColor animated:(BOOL)animated {
    if (isAnimating) {
        targetColor = tintColor;
        return;
    }
    isAnimating = YES;

    UIColor* color;
    if ([tintColor isBright]) {
        color = [tintColor darken:.7];
    } else {
        color = [tintColor brighten:.7];
    }

    [UIView animateTextTransitionForObjects:@[self] withDuration:animated ? .75 : .2 delay:0 animations:^{
        [self setTextColor:color];
        //        [self setBackgroundColor:tintColor];
    } completion:^{
        isAnimating = NO;
        if (targetColor) {
            [self setTintColor:targetColor];
            targetColor = nil;
        }
    }];
}


@end
