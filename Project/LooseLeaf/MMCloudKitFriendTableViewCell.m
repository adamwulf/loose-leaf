//
//  MMCloudKitFriendTableViewCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitFriendTableViewCell.h"
#import "UIView+Debug.h"
#import "UIView+Animations.h"
#import "Constants.h"

@implementation MMCloudKitFriendTableViewCell{
    UILabel* textLabel;
    MMAvatarButton* avatarButton;
}

@synthesize avatarButton;

- (id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        CGRect lblFr = self.bounds;
        lblFr.origin.x = 76;
        lblFr.size.width -= 76;
        textLabel = [[UILabel alloc] initWithFrame:lblFr];
        textLabel.font = [UIFont systemFontOfSize:20];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;

        [self showDebugBorder];
        
        [self addSubview:textLabel];
    }
    return self;
}

-(void) setUserInfo:(CKDiscoveredUserInfo*)userInfo forIndex:(NSInteger)index{
    NSString* firstLetter = userInfo.firstName.length > 1 ? [userInfo.firstName substringToIndex:1] : @"";
    NSString* lastLetter = userInfo.lastName.length > 1 ? [userInfo.lastName substringToIndex:1] : @"";
    NSString* initials = [[NSString stringWithFormat:@"%@%@", firstLetter, lastLetter] uppercaseString];
    initials = [NSString stringWithFormat:@"%d", (int) index];

    CGFloat height = self.bounds.size.height - kWidthOfSidebarButtonBuffer / 4.0;
    [avatarButton removeFromSuperview];
    avatarButton = [[MMAvatarButton alloc] initWithFrame:CGRectMake(0, 0, height, height) forLetter:initials];
    [self addSubview:avatarButton];

    CGRect lblFr = textLabel.frame;
    lblFr.origin.x = height;
    lblFr.size.width = self.bounds.size.width - height;
    textLabel.frame = lblFr;
    
    textLabel.text = [NSString stringWithFormat:@"%@ %@ %d", userInfo.firstName, userInfo.lastName, (int) index];
    // fit width
    [textLabel sizeToFit];
    CGRect fr = textLabel.frame;
    fr.size.height = self.bounds.size.height;
    textLabel.frame = fr;
}

-(void) bounce{
    [avatarButton bounceButton];
    [textLabel bounceWithTransform:CGAffineTransformIdentity stepOne:.2 stepTwo:-.1];
}

@end
