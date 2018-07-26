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

- (instancetype)init {
    if (self = [super init]) {
        [self finishButtonBoxInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self finishButtonBoxInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self finishButtonBoxInit];
    }
    return self;
}

- (void)finishButtonBoxInit {
    _buttonSize = CGSizeMake(kWidthOfSidebarButton, kWidthOfSidebarButton);
    _buttonMargin = 0;
}

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
    NSUInteger targetColumnCount = _columns ?: [[self buttons] count];

    if (targetColumnCount) {
        NSUInteger rows = ceil([[self buttons] count] / (double)targetColumnCount);

        return CGSizeMake(_buttonSize.width * targetColumnCount + _buttonMargin * (targetColumnCount - 1),
                          _buttonSize.height * rows + _buttonMargin * (targetColumnCount - 1));
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

    NSUInteger targetColumnCount = _columns ?: [[self buttons] count];
    NSUInteger rows = ceil([[self buttons] count] / (double)targetColumnCount);

    for (NSUInteger row = 0; row < rows; row++) {
        for (NSUInteger col = 0; col < targetColumnCount; col++) {
            NSUInteger buttonIndex = row * targetColumnCount + col;

            if (buttonIndex >= [[self buttons] count]) {
                return;
            }

            CGRect frame = CGRectMake(col * (_buttonSize.width + _buttonMargin),
                                      row * (_buttonSize.height + _buttonMargin),
                                      _buttonSize.width,
                                      _buttonSize.height);

            [[[self buttons] objectAtIndex:buttonIndex] setFrame:frame];
        }
    }
}

@end
