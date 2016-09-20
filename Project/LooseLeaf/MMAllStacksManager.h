//
//  MMAllStacksManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/6/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMMAllStacksManagerUpgradeStartNotification @"kMMAllStacksManagerUpgradeStartNotification"


@interface MMAllStacksManager : NSObject

+ (MMAllStacksManager*)sharedInstance;

- (void)upgradeIfNecessary:(void (^)())upgradeCompleteBlock;

- (NSString*)stackDirectoryPathForUUID:(NSString*)uuid;

- (NSString*)createStack;

- (void)deleteStack:(NSString*)stackUUID;

- (NSArray*)stackIDs;

- (NSString*)nameOfStack:(NSString*)stackUUID;

- (NSArray*)cachedPagesForStack:(NSString*)stackUUID;

- (void)updateCachedPages:(NSArray*)allPages forStackUUID:(NSString*)stackUUID;

- (void)updateName:(NSString*)name forStack:(NSString*)stackUUID;

@end
