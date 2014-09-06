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
#import "CKDiscoveredUserInfo+Initials.h"

@implementation MMCloudKitAskingForPermissionState{
    BOOL isCheckingStatus;
    SCKMAccountStatus accountStatus;
}

-(id) initWithAccountStatus:(SCKMAccountStatus) _accountStatus{
    if(self = [super init]){
        accountStatus = _accountStatus;
    }
    return self;
}

-(void) runState{
    NSLog(@"Running state %@", NSStringFromClass([self class]));
    
    if([MMReachabilityManager sharedManager].currentReachabilityStatus == NotReachable){
        // we can't connect to cloudkit, so move to an error state
        [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitOfflineState alloc] init]];
    }else{
        @synchronized(self){
            if(isCheckingStatus){
                return;
            }
            isCheckingStatus = YES;
        }
        [[SPRSimpleCloudKitManager sharedManager] promptAndFetchUserInfoOnComplete:^(SCKMApplicationPermissionStatus permissionStatus,
                                                                                     CKRecordID *recordID,
                                                                                     CKDiscoveredUserInfo *userInfo,
                                                                                     NSError *error) {
            if([MMCloudKitManager sharedManager].currentState != self){
                // bail early. the network probably went offline
                // while we were waiting for a reply. if we're not current,
                // then we shouldn't process / change state.
                return;
            }
            @synchronized(self){
                isCheckingStatus = NO;
            }
            [MMCloudKitBaseState clearCache];
            if(error){
                [[MMCloudKitManager sharedManager] changeToStateBasedOnError:error];
            }else{
                switch (permissionStatus) {
                    case SCKMApplicationPermissionStatusCouldNotComplete:
                        [[MMCloudKitManager sharedManager] retryStateAfterDelay:3];
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
                            [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitFetchFriendsState alloc] initWithUserRecord:recordID andUserInfo:[userInfo asDictionary]]];
                        }else{
                            [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitBaseState alloc] init]];
                        }
                        break;
                }
            }
        }];
    }
}


@end
