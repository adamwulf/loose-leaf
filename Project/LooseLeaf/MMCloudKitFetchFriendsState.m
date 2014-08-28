//
//  MMCloudKitLoggedInState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitFetchFriendsState.h"
#import "MMReachabilityManager.h"
#import "MMCloudKitManager.h"
#import "MMCloudKitOfflineState.h"
#import "MMCloudKitLoggedInState.h"
#import <SimpleCloudKitManager/SPRSimpleCloudKitManager.h>

@implementation MMCloudKitFetchFriendsState{
    BOOL isCheckingStatus;
    CKRecordID* userRecord;
    CKDiscoveredUserInfo* userInfo;
}

-(id) initWithUserRecord:(CKRecordID*)_userRecord andUserInfo:(CKDiscoveredUserInfo*)_userInfo{
    if(self = [super init]){
        userRecord = _userRecord;
        userInfo = _userInfo;
    }
    return self;
}

-(NSArray*) filteredFriendsList:(NSArray*)friendsList{
    NSArray* filteredFriends = [friendsList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        CKDiscoveredUserInfo* friend = (CKDiscoveredUserInfo*)evaluatedObject;
        return ![friend.userRecordID isEqual:userRecord];
    }]];
    return filteredFriends;
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
        @synchronized(self){
            isCheckingStatus = NO;
        }
        [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitOfflineState alloc] init]];
    }else{
        [[SPRSimpleCloudKitManager sharedManager] discoverAllFriendsWithCompletionHandler:^(NSArray *friendRecords, NSError *error) {
            @synchronized(self){
                isCheckingStatus = NO;
            }
            if(error){
                [self updateStateBasedOnError:error];
            }else{
                [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitLoggedInState alloc] initWithUserRecord:userRecord
                                                                                                         andUserInfo:userInfo
                                                                                                       andFriendList:[self filteredFriendsList:friendRecords]]];
            }
        }];
    }
}

@end
