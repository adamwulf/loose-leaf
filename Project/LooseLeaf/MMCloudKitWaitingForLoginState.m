//
//  MMCloudKitWaitingForLoginState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitWaitingForLoginState.h"
#import "MMReachabilityManager.h"
#import "MMCloudKitOfflineState.h"
#import "MMCloudKitDeclinedPermissionState.h"
#import "MMCloudKitFetchingAccountInfoState.h"
#import "MMCloudKitFetchFriendsState.h"
#import "MMCloudKitAccountMissingState.h"
#import "MMCloudKitAskingForPermissionState.h"
#import "MMCloudKitManager.h"


@implementation MMCloudKitWaitingForLoginState {
    SCKMAccountStatus accountStatus;
}

- (id)initWithAccountStatus:(SCKMAccountStatus)_accountStatus {
    if (self = [super init]) {
        accountStatus = _accountStatus;
    }
    return self;
}

- (void)runState {
    if ([MMReachabilityManager sharedManager].currentReachabilityStatus == NotReachable) {
        // we can't connect to cloudkit, so move to an error state
        [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitOfflineState alloc] init]];
    } else {
        [MMCloudKitFetchingAccountInfoState clearAccountCache];
        [MMCloudKitFetchFriendsState clearFriendsCache];
    }
}

- (void)didAskToLogin {
    [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitAskingForPermissionState alloc] initWithAccountStatus:accountStatus]];
}


@end
