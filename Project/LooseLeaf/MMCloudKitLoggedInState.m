//
//  MMCloudKitLoggedInState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitLoggedInState.h"
#import "MMReachabilityManager.h"
#import "MMCloudKitManager.h"
#import "MMCloudKitOfflineState.h"

@implementation MMCloudKitLoggedInState{
    CKRecordID* userRecord;
    CKDiscoveredUserInfo* userInfo;
    NSArray* friendList;
    NSTimer* fetchAllMessagesTimer;
}

@synthesize friendList;

-(id) initWithUserRecord:(CKRecordID*)_userRecord andUserInfo:(CKDiscoveredUserInfo*)_userInfo andFriendList:(NSArray *)_friendList{
    if(self = [super init]){
        userRecord = _userRecord;
        userInfo = _userInfo;
        friendList = _friendList;
    }
    return self;
}

-(void) runState{
    NSLog(@"Running state %@", NSStringFromClass([self class]));
    if([MMReachabilityManager sharedManager].currentReachabilityStatus == NotReachable){
        // we can't connect to cloudkit, so move to an error state
        [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitOfflineState alloc] init]];
    }else{
        NSLog(@"got friend list: %@", friendList);
        [self fetchAllNewMessages];
    }
}

-(void) fetchAllNewMessages{
    [fetchAllMessagesTimer invalidate];
    fetchAllMessagesTimer = nil;
    [[MMCloudKitManager sharedManager] fetchAllNewMessages];
}

-(void) cloudKitDidRecievePush{
    [self runState];
//    if([UIApplication sharedApplication].isRegisteredForRemoteNotifications){
//        NSLog(@"registered for push.");
//    }else{
//        NSLog(@"NOT registered for push.");
//    }
}

-(void) cloudKitDidCheckForNotifications{
    [fetchAllMessagesTimer invalidate];
    fetchAllMessagesTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(fetchAllNewMessages) userInfo:nil repeats:NO];
}

@end
