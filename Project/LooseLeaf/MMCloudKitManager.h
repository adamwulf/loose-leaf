//
//  MMCloudKitManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/22/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMCloudKitManagerDelegate.h"
#import <SimpleCloudKitManager/SPRSimpleCloudKitManager.h>

@interface MMCloudKitManager : NSObject

@property (nonatomic, weak) NSObject<MMCloudKitManagerDelegate>* delegate;

+ (MMCloudKitManager *) sharedManager;

+(BOOL) isCloudKitAvailable;

@end
