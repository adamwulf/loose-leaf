//
//  MMDecryptPDFStackButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 12/13/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMDecryptPDFStackButton.h"
#import "MMTrashButton.h"
#import "MMUndoRedoButton.h"
#import "MMPDFPageAsset.h"
#import "Constants.h"


@interface MMDecryptPDFStackButton () <UITextFieldDelegate>

@end


@implementation MMDecryptPDFStackButton {
    UITextField* passwordField;
}

- (instancetype)initWithFrame:(CGRect)frame {
    UIColor* iconColor = [UIColor colorWithWhite:.2 alpha:1.0];

    UIImage* trashImg = [MMTrashButton trashIconWithColor:iconColor];
    UIImage* undoImg = [MMPDFPageAsset lockIconWithColor:iconColor];

    if (self = [super initWithFrame:frame andPrompt:@"Enter the password for this PDF:" andLeftIcon:trashImg andLeftTitle:@"Delete" andRightIcon:undoImg andRightTitle:@"Unlock"]) {
        passwordField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        passwordField.delegate = self;
        passwordField.placeholder = @"Password";
        passwordField.secureTextEntry = YES;
        passwordField.layer.cornerRadius = 10;
        passwordField.layer.borderWidth = 1;
        passwordField.layer.borderColor = [UIColor blackColor].CGColor;
        passwordField.textAlignment = NSTextAlignmentCenter;
        [self addSubview:passwordField];
        passwordField.center = CGPointTranslate(CGRectGetMidPoint([self bounds]), 0, -8);
    }
    return self;
}

- (void)bouncePasswordInput {
    passwordField.layer.borderWidth = 1;
    passwordField.layer.borderColor = [UIColor blackColor].CGColor;

    CGColorRef originalColor = passwordField.layer.borderColor;
    CGFloat originalWidth = passwordField.layer.borderWidth;

    CABasicAnimation* color = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    // animate from red to blue border ...
    color.fromValue = (id)[UIColor redColor].CGColor;
    color.toValue = (__bridge id)originalColor;

    CABasicAnimation* width = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
    // animate from 2pt to 4pt wide border ...
    width.fromValue = @3;
    width.toValue = @(originalWidth);

    CAAnimationGroup* both = [CAAnimationGroup animation];
    // animate both as a group
    both.duration = .75;
    both.animations = @[color, width];
    both.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    both.removedOnCompletion = YES;

    [passwordField.layer addAnimation:both forKey:@"color and width"];
}

- (NSString*)password {
    return passwordField.text;
}

- (CGFloat)additionalVerticalSpacing {
    return 30;
}

- (void)setAlpha:(CGFloat)alpha {
    if (alpha != 1) {
        [passwordField resignFirstResponder];
    }
    [super setAlpha:alpha];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    [self.delegate didTapRightInFullWidthButton:self];
    return NO;
}


@end
