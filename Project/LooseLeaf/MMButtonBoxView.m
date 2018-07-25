//
//  MMButtonBoxView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/24/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMButtonBoxView.h"
#import "Constants.h"


@implementation MMButtonBoxView

#pragma mark - Properties

- (void)setButtons:(NSArray<UIButton*>*)buttons {
    _buttons = buttons;

    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    [buttons enumerateObjectsUsingBlock:^(UIButton* _Nonnull button, NSUInteger idx, BOOL* _Nonnull stop) {
        [self addSubview:button];
    }];

    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setColumns:(NSUInteger)columns {
    _columns = columns;

    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

#pragma mark - UIView

- (CGSize)intrinsicContentSize {
    if (_columns) {
        NSUInteger rows = [[self buttons] count] / _columns + 1;

        return CGSizeMake(kWidthOfSidebarButton * _columns, kWidthOfSidebarButton * rows);
    }

    return CGSizeZero;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize ideal = [self intrinsicContentSize];

    if (ideal.width < size.width) {
        ideal.width = size.width;
    }

    if (ideal.height < size.height) {
        ideal.height = size.height;
    }

    return ideal;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    NSUInteger rows = [[self buttons] count] / _columns + 1;

    for (NSUInteger row = 0; row < rows; row++) {
        for (NSUInteger col = 0; col < _columns; col++) {
            NSUInteger buttonIndex = row * _columns + col;

            if (buttonIndex >= [[self buttons] count]) {
                return;
            }

            CGRect frame = CGRectMake(col * kWidthOfSidebarButton, row * kWidthOfSidebarButton, kWidthOfSidebarButton, kWidthOfSidebarButton);

            [[[self buttons] objectAtIndex:buttonIndex] setFrame:frame];
        }
    }
}

@end
