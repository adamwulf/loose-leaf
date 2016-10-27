//
//  MMCloudKitFriendTableViewCell.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>
#import "MMAvatarButton.h"


@interface MMCloudKitFriendCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) BOOL shouldShowReplyIcon;

- (void)setUserInfo:(NSDictionary*)userInfo forIndex:(NSInteger)index;

- (void)bounce;

- (MMAvatarButton*)stealAvatarButton;

@end
