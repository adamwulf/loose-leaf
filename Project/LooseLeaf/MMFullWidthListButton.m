//
//  MMFullWidthListButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 11/17/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMFullWidthListButton.h"
#import "MMListPaperStackView.h"
#import "MMRoundedButton.h"
#import "MMTrashButton.h"
#import "MMUndoRedoButton.h"
#import "UIImage+MMColor.h"


@implementation MMFullWidthListButton

@synthesize delegate;

- (instancetype)initWithFrame:(CGRect)frame andPrompt:(NSString*)prompt andLeftIcon:(UIImage*)leftIcon andLeftTitle:(NSString*)leftTitle andRightIcon:(UIImage*)rightIcon andRightTitle:(NSString*)rightTitle {
    if (self = [super initWithFrame:frame]) {
        CGFloat rowHeight = [MMListPaperStackView rowHeight];
        CGFloat lblY = 215.0 / 273.0 * rowHeight;
        CGFloat buttonY = 185.0 / 273.0 * rowHeight;

        UIColor* quarterWhite = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.25];
        CGFloat cornerRadius = roundf(.125 * [MMListPaperStackView columnWidth]);
        CGFloat buffer = [MMListPaperStackView bufferWidth];
        CGRect confirmationRect = CGRectMake(buffer, 0, CGRectGetWidth(frame) - 2 * buffer, CGRectGetHeight(frame));
        UIBezierPath* border = [UIBezierPath bezierPathWithRoundedRect:confirmationRect cornerRadius:cornerRadius];
        CAShapeLayer* borderLayer = [CAShapeLayer layer];
        borderLayer.path = border.CGPath;
        borderLayer.strokeColor = quarterWhite.CGColor;
        [borderLayer setLineDashPattern:@[@35, @10]];
        [borderLayer setRepeatCount:2];
        [borderLayer setLineDashPhase:0];
        [borderLayer setFillColor:[[UIColor clearColor] CGColor]];
        borderLayer.backgroundColor = borderLayer.fillColor;

        UIBezierPath* background = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(confirmationRect, 4, 4) cornerRadius:cornerRadius - 4];
        CAShapeLayer* backgroundLayer = [CAShapeLayer layer];
        backgroundLayer.path = background.CGPath;
        backgroundLayer.fillColor = [UIColor colorWithWhite:1.0 alpha:.3].CGColor;

        [self.layer addSublayer:borderLayer];
        [self.layer addSublayer:backgroundLayer];
        self.alpha = 0;

        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectWithHeight(self.bounds, lblY)];
        lbl.text = prompt;
        lbl.textColor = [UIColor colorWithWhite:.2 alpha:1.0];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:20];
        [self addSubview:lbl];

        MMRoundedButton* confirmButton = [[MMRoundedButton alloc] initWithFrame:CGRectZero];
        [confirmButton setImage:leftIcon forState:UIControlStateNormal];
        [confirmButton setTitle:leftTitle forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(didTapLeftButton) forControlEvents:UIControlEventTouchUpInside];
        [confirmButton setTitleColor:lbl.textColor forState:UIControlStateNormal];
        [confirmButton setTitleColor:[UIColor colorWithWhite:.6 alpha:1.0] forState:UIControlStateHighlighted];
        [self addSubview:confirmButton];

        MMRoundedButton* cancelButton = [[MMRoundedButton alloc] initWithFrame:CGRectZero];
        [cancelButton setImage:rightIcon forState:UIControlStateNormal];
        [cancelButton setTitle:rightTitle forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(didTapRightButton) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitleColor:lbl.textColor forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor colorWithWhite:.6 alpha:1.0] forState:UIControlStateHighlighted];
        [self addSubview:cancelButton];

        CGFloat widthOfButtons = confirmButton.bounds.size.width + cancelButton.bounds.size.width + 20;
        CGFloat buttonMargin = (self.bounds.size.width - widthOfButtons) / 2;
        cancelButton.center = CGPointMake(self.bounds.size.width - buttonMargin - cancelButton.bounds.size.width / 2, buttonY);
        confirmButton.center = CGPointMake(buttonMargin + confirmButton.bounds.size.width / 2, buttonY);
    }
    return self;
}

- (void)didTapLeftButton {
    [self.delegate didTapLeftInFullWidthButton:self];
}

- (void)didTapRightButton {
    [self.delegate didTapRightInFullWidthButton:self];
}


@end
