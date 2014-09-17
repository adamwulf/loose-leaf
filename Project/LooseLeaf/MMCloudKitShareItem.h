//
//  MMCloudKitShareItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/20/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMShareItem.h"
#import <CloudKit/CloudKit.h>
#import "MMCloudKitManagerDelegate.h"

@interface MMCloudKitShareItem : NSObject<MMShareItem>

-(void) userIsAskingToShareTo:(NSDictionary*)userInfo fromButton:(MMBounceButton*)button;

-(NSDictionary*) cloudKitSenderInfo;

-(void) didTapInviteButton;

#pragma mark - Cloud Kit

-(void) cloudKitDidChangeState:(MMCloudKitBaseState *)currentState;

@end
