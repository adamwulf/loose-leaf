//
//  MMCloudKitAskingForPermissionState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitAskingForPermissionState.h"
#import "MMReachabilityManager.h"
#import "MMCloudKitManager.h"
#import "MMCloudKitOfflineState.h"
#import "MMCloudKitAccountMissingState.h"
#import "MMCloudKitDeclinedPermissionState.h"
#import "MMCloudKitFetchFriendsState.h"
#import "MMCloudKitWaitingForLoginState.h"

@implementation MMCloudKitAskingForPermissionState{
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
        [[SPRSimpleCloudKitManager sharedManager] promptAndFetchUserInfoOnComplete:^(SCKMAccountStatus accountStatus,
                                                                                     SCKMApplicationPermissionStatus permissionStatus,
                                                                                     CKRecordID *recordID,
                                                                                     CKDiscoveredUserInfo *userInfo,
                                                                                     NSError *error) {
            @synchronized(self){
                isCheckingStatus = NO;
            }
            if(error){
                [self updateStateBasedOnError:error];
            }else{
                switch (accountStatus) {
                    case SCKMAccountStatusCouldNotDetermine:
                        // accountStatus is unknown, so reload it
                        [[MMCloudKitManager sharedManager] retryStateAfterDelay];
                        break;
                    case SCKMAccountStatusNoAccount:
                    case SCKMAccountStatusRestricted:
                        // notify that cloudKit is entirely unavailable
                        [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitAccountMissingState alloc] init]];
                        break;
                    case SCKMAccountStatusAvailable:
                        switch (permissionStatus) {
                            case SCKMApplicationPermissionStatusCouldNotComplete:
                                [[MMCloudKitManager sharedManager] retryStateAfterDelay];
                                break;
                            case SCKMApplicationPermissionStatusDenied:
                                // account exists for iCloud, but the user has
                                // denied us permission to use it
                                [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitDeclinedPermissionState alloc] init]];
                                break;
                            case SCKMApplicationPermissionStatusInitialState:
                                // unknown permission
                                // waiting for manual login
                                [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitWaitingForLoginState alloc] init]];
                                break;
                            case SCKMApplicationPermissionStatusGranted:
                                // icloud is available for this user, so we need to
                                // fetch their account info if we don't already have it.
                                if(recordID && userInfo){
                                    [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitFetchFriendsState alloc] initWithUserRecord:recordID andUserInfo:userInfo]];
                                }else{
                                    [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitBaseState alloc] init]];
                                }
                                break;
                        }
                        break;
                }
            }
        }];
    }
}


@end
