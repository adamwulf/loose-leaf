//
//  MMCloudKitExportAnimationView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitExportView.h"
#import "MMUntouchableView.h"
#import "NSThread+BlockAdditions.h"

@implementation MMCloudKitExportView

#pragma mark - Sharing

-(void) didShareTopPageToUser:(CKRecordID*)userId fromButton:(MMAvatarButton*)avatarButton{
    CGRect fr = [avatarButton convertRect:avatarButton.bounds toView:self];
    avatarButton.frame = fr;
    [self addSubview:avatarButton];
    
    [UIView animateWithDuration:.5 animations:^{
        CGRect fr = avatarButton.frame;
        fr.origin.y = 0;
        fr.origin.x = 100;
        avatarButton.frame = fr;
    } completion:^(BOOL finished) {
        [[NSThread mainThread] performBlock:^{
            [avatarButton removeFromSuperview];
        } afterDelay:5];
    }];
}

@end
