//
//  MMCloudKitFriendTableViewCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitFriendCollectionViewCell.h"
#import <SimpleCloudKitManager/SPRSimpleCloudKitManager.h>
#import "MMReplyButton.h"
#import "UIView+Animations.h"
#import "Constants.h"


@implementation MMCloudKitFriendCollectionViewCell {
    UILabel* textLabel;
    MMAvatarButton* avatarButton;
    MMReplyButton* replyButton;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGRect lblFr = self.bounds;
        lblFr.origin.x = 76;
        lblFr.size.width -= 76;
        textLabel = [[UILabel alloc] initWithFrame:lblFr];
        textLabel.font = [UIFont systemFontOfSize:20];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;

        [self addSubview:textLabel];
    }
    return self;
}

- (void)setShouldShowReplyIcon:(BOOL)shouldShowReplyIcon {
    if (shouldShowReplyIcon && !replyButton) {
        replyButton = [[MMReplyButton alloc] initWithFrame:avatarButton.bounds];
        replyButton.center = CGPointMake(self.bounds.size.width - replyButton.bounds.size.width / 2, replyButton.bounds.size.height / 2);
        replyButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:replyButton];
    } else if (!shouldShowReplyIcon && replyButton) {
        [replyButton removeFromSuperview];
        replyButton = nil;
    }
}

- (BOOL)shouldShowReplyIcon {
    return replyButton != nil;
}

- (void)setUserInfo:(NSDictionary*)userInfo forIndex:(NSInteger)index {
    CGFloat height = self.bounds.size.height - kWidthOfSidebarButtonBuffer / 4.0;
    [avatarButton removeFromSuperview];
    avatarButton = [[MMAvatarButton alloc] initWithFrame:CGRectMake(0, 0, height, height) forLetter:[userInfo objectForKey:@"initials"]];
    [self addSubview:avatarButton];

    CGRect lblFr = textLabel.frame;
    lblFr.origin.x = height;
    lblFr.size.width = self.bounds.size.width - height;
    textLabel.frame = lblFr;

    textLabel.text = [NSString stringWithFormat:@"%@ %@", [userInfo objectForKey:@"firstName"], [userInfo objectForKey:@"lastName"]];
    // fit width
    [textLabel sizeToFit];
    CGRect fr = textLabel.frame;
    fr.size.height = self.bounds.size.height;
    textLabel.frame = fr;
}

- (void)bounce {
    [avatarButton bounceButton];
    [replyButton bounceButton];
    [textLabel bounceWithTransform:CGAffineTransformIdentity stepOne:.2 stepTwo:-.1];
}

- (MMAvatarButton*)stealAvatarButton {
    MMAvatarButton* ret = avatarButton;
    avatarButton = nil;
    return ret;
}


#pragma mark - UITouch Control

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    return [super pointInside:point withEvent:event];
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
    if ([super hitTest:point withEvent:event]) {
        return self;
    }
    return nil;
}

@end
