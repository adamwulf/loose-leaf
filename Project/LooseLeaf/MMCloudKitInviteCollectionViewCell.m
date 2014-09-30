//
//  MMInviteFriendCollectionViewCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitInviteCollectionViewCell.h"

@implementation MMCloudKitInviteCollectionViewCell{
    MMInviteUserButton* inviteButton;
}

@synthesize delegate;

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        inviteButton = [[MMInviteUserButton alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        [self addSubview:inviteButton];
        inviteButton.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        inviteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        inviteButton.delegate = self;
    }
    return self;
}

#pragma mark - MMInviteUserButtonDelegate

-(void) didTapInviteButton{
    [self.delegate didTapInviteButton];
}

@end
