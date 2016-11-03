//
//  MMConfirmDeleteStackButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 11/3/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMConfirmDeleteStackButton.h"
#import "MMListPaperStackView.h"


@implementation MMConfirmDeleteStackButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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
        backgroundLayer.fillColor = [UIColor colorWithWhite:1.0 alpha:.2].CGColor;

        [self.layer addSublayer:borderLayer];
        [self.layer addSublayer:backgroundLayer];
        self.alpha = 0;

        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectWithHeight(self.bounds, 250)];
        lbl.text = @"Are you sure you want to delete these pages?";
        lbl.textColor = [UIColor colorWithWhite:.2 alpha:1.0];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:20];
        [self addSubview:lbl];
    }
    return self;
}

@end
