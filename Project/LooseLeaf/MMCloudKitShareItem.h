//
//  MMCloudKitShareItem.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/20/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMShareItem.h"
#import "MMOpenInAppOptionsViewDelegate.h"
#import <CloudKit/CloudKit.h>

@interface MMCloudKitShareItem : NSObject<MMShareItem,MMOpenInAppOptionsViewDelegate>

-(void) userIsAskingToShareTo:(CKDiscoveredUserInfo*)userInfo;

@end
