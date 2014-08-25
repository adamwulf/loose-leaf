//
//  MMCloudKitFriendTableViewCell.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>

@interface MMCloudKitFriendTableViewCell : UITableViewCell

-(void) setUserInfo:(CKDiscoveredUserInfo*)userInfo;

@end
