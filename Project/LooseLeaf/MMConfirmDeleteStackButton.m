//
//  MMConfirmDeleteStackButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 11/3/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMConfirmDeleteStackButton.h"
#import "MMListPaperStackView.h"
#import "MMRoundedButton.h"
#import "MMTrashButton.h"
#import "MMUndoRedoButton.h"


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
        backgroundLayer.fillColor = [UIColor colorWithWhite:1.0 alpha:.3].CGColor;

        [self.layer addSublayer:borderLayer];
        [self.layer addSublayer:backgroundLayer];
        self.alpha = 0;

        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectWithHeight(self.bounds, 250)];
        lbl.text = @"Are you sure you want to delete these pages?";
        lbl.textColor = [UIColor colorWithWhite:.2 alpha:1.0];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:20];
        [self addSubview:lbl];


        UIColor* halfGreyFill = [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:0.5];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 40), NO, 0);
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -8, 0);
        [MMTrashButton drawTrashCanInRect:CGRectMake(0, 0, 40, 40) withColor:lbl.textColor withBackground:halfGreyFill];
        UIImage* trashImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(36, 40), NO, 0);
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -2, 3);
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 18, 18);
        CGContextRotateCTM(UIGraphicsGetCurrentContext(), M_PI);
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -18, -18);

        [MMUndoRedoButton drawArrowInRect:CGRectMake(0, 0, 40, 40) reversed:YES withColor:lbl.textColor];
        UIImage* undoImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        MMRoundedButton* confirmButton = [[MMRoundedButton alloc] initWithFrame:CGRectZero];
        [confirmButton setImage:trashImg forState:UIControlStateNormal];
        [confirmButton setTitle:@"Delete" forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(didTapConfirmButton) forControlEvents:UIControlEventTouchUpInside];
        [confirmButton setTitleColor:lbl.textColor forState:UIControlStateNormal];
        [self addSubview:confirmButton];

        MMRoundedButton* cancelButton = [[MMRoundedButton alloc] initWithFrame:CGRectZero];
        [cancelButton setImage:undoImg forState:UIControlStateNormal];
        [cancelButton setTitle:@"Undo" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(didTapCancelButton) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitleColor:lbl.textColor forState:UIControlStateNormal];
        [self addSubview:cancelButton];

        CGFloat widthOfButtons = confirmButton.bounds.size.width + cancelButton.bounds.size.width + 20;
        CGFloat buttonMargin = (self.bounds.size.width - widthOfButtons) / 2;
        cancelButton.center = CGPointMake(self.bounds.size.width - buttonMargin - cancelButton.bounds.size.width / 2, 200);
        confirmButton.center = CGPointMake(buttonMargin + confirmButton.bounds.size.width / 2, 200);
    }
    return self;
}

- (void)didTapConfirmButton {
}

- (void)didTapCancelButton {
}


@end
