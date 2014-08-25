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
    BOOL isCheckingStatus;
    CKRecordID* userRecord;
    CKDiscoveredUserInfo* userInfo;
    NSArray* friendList;
}

-(id) initWithUserRecord:(CKRecordID*)_userRecord andUserInfo:(CKDiscoveredUserInfo*)_userInfo andFriendList:(NSArray *)_friendList{
    if(self = [super init]){
        userRecord = _userRecord;
        userInfo = _userInfo;
        friendList = _friendList;
    }
    return self;
}

-(void) runState{
    @synchronized(self){
        if(isCheckingStatus){
            return;
        }
        isCheckingStatus = YES;
    }
    NSLog(@"Running state %@", NSStringFromClass([self class]));
    
    if([MMReachabilityManager sharedManager].currentReachabilityStatus == NotReachable){
        // we can't connect to cloudkit, so move to an error state
        isCheckingStatus = NO;
        [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitOfflineState alloc] init]];
    }else{
        isCheckingStatus = NO;
        
        
        NSLog(@"got friend list: %@", friendList);
    }
}

@end
