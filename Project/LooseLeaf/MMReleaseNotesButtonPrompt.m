//
//  MMReleaseNotesButtonPrompt.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/5/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMReleaseNotesButtonPrompt.h"
#import "UIColor+Shadow.h"
#import "Constants.h"


@implementation MMReleaseNotesButtonPrompt {
    UILabel* promptLabel;
    UIButton* confirmButton;
    UIButton* denyButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        promptLabel = [[UILabel alloc] initWithFrame:CGRectWithHeight(frame, 60)];
        promptLabel.font = [UIFont fontWithName:@"Lato-Bold" size:24];
        promptLabel.textAlignment = NSTextAlignmentCenter;
        promptLabel.text = NSLocalizedString(@"Are you enjoying Loose Leaf?", @"Are you enjoying Loose Leaf?");

        confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 50)];
        confirmButton.backgroundColor = [[UIColor blueShadowColor] colorWithAlphaComponent:1];
        [[confirmButton layer] setCornerRadius:8];
        [confirmButton setClipsToBounds:YES];
        [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:.7] forState:UIControlStateNormal];
        [confirmButton setTitle:NSLocalizedString(@"Definitely!", @"Definitely!") forState:UIControlStateNormal];
        [[confirmButton titleLabel] setFont:[UIFont fontWithName:@"Lato-Semibold" size:16]];
        [confirmButton addTarget:self action:@selector(isEnjoying:) forControlEvents:UIControlEventTouchUpInside];

        denyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 50)];
        denyButton.backgroundColor = [[UIColor blueShadowColor] colorWithAlphaComponent:1];
        [[denyButton layer] setCornerRadius:8];
        [denyButton setClipsToBounds:YES];
        [denyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [denyButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:.7] forState:UIControlStateNormal];
        [denyButton setTitle:NSLocalizedString(@"Not so much", @"Not so much") forState:UIControlStateNormal];
        [[denyButton titleLabel] setFont:[UIFont fontWithName:@"Lato-Semibold" size:16]];
        [denyButton addTarget:self action:@selector(notEnjoying:) forControlEvents:UIControlEventTouchUpInside];

        confirmButton.center = CGPointMake((CGRectGetWidth(frame) - CGRectGetWidth([confirmButton bounds]) - 60) / 2, 80);
        denyButton.center = CGPointMake((CGRectGetWidth(frame) + CGRectGetWidth([denyButton bounds]) + 60) / 2, 80);

        [self addSubview:promptLabel];
        [self addSubview:confirmButton];
        [self addSubview:denyButton];
    }
    return self;
}

#pragma mark - Properties

- (NSString*)prompt {
    return [promptLabel text];
}

- (void)setPrompt:(NSString*)prompt {
    [promptLabel setText:prompt];
}

- (NSString*)confirmAnswer {
    return [confirmButton titleForState:UIControlStateNormal];
}

- (void)setConfirmAnswer:(NSString*)confirmAnswer {
    [confirmButton setTitle:confirmAnswer forState:UIControlStateNormal];
}

- (NSString*)denyAnswer {
    return [denyButton titleForState:UIControlStateNormal];
}

- (void)setDenyAnswer:(NSString*)denyAnswer {
    [denyButton setTitle:denyAnswer forState:UIControlStateNormal];
}

#pragma mark - Actions

- (void)isEnjoying:(UIButton*)button {
    if (self.confirmBlock) {
        self.confirmBlock();
    }
}

- (void)notEnjoying:(UIButton*)button {
    if (self.denyBlock) {
        self.denyBlock();
    }
}

@end
