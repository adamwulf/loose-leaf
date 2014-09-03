//
//  MMCloudKitFetchingAccountInfoState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitFetchingAccountInfoState.h"
#import "MMReachabilityManager.h"
#import "MMCloudKitManager.h"
#import "MMCloudKitOfflineState.h"
#import "MMCloudKitFetchFriendsState.h"
#import <SimpleCloudKitManager/SPRSimpleCloudKitManager.h>

@implementation MMCloudKitFetchingAccountInfoState{
    BOOL isCheckingStatus;
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
        
        [[SPRSimpleCloudKitManager sharedManager] silentlyFetchUserInfoOnComplete:^(CKRecordID* userRecord, CKDiscoveredUserInfo *userInfo, NSError *error) {
            NSLog(@"got cloudkit user info %@ %@ %p!", userRecord, userInfo, error);
            @synchronized(self){
                isCheckingStatus = NO;
            }
            if(error){
                [self updateStateBasedOnError:error];
            }else{
                [[SPRSimpleCloudKitManager sharedManager] promptForRemoteNotificationsIfNecessary];
                if([SPRSimpleCloudKitManager sharedManager])
                [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitFetchFriendsState alloc] initWithUserRecord:userRecord andUserInfo:userInfo]];
            }
        }];
    }
}


@end
