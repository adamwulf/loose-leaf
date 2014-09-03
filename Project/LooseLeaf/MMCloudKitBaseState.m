//
//  MMCloudKitBaseState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitBaseState.h"
#import "MMReachabilityManager.h"
#import "MMCloudKitManager.h"
#import "MMCloudKitOfflineState.h"
#import "MMCloudKitAccountMissingState.h"
#import "MMCloudKitDeclinedPermissionState.h"
#import "MMCloudKitFetchingAccountInfoState.h"
#import "MMCloudKitWaitingForLoginState.h"
#import <SimpleCloudKitManager/SPRSimpleCloudKitManager.h>

//
// this is the first state of the state machine,
// and attempts to login to CloudKit. if login fails,
// then it will transition to an ErrorState for the
// appropriate reason
@implementation MMCloudKitBaseState{
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
        [[SPRSimpleCloudKitManager sharedManager] silentlyVerifyiCloudAccountStatusOnComplete:^(SCKMAccountStatus accountStatus,
                                                                                                SCKMApplicationPermissionStatus permissionStatus,
                                                                                                NSError *error) {
            NSLog(@"got account status and permisison info %d %d %p!", (int) accountStatus, (int) permissionStatus, error);
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
                                [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitFetchingAccountInfoState alloc] init]];
                                break;
                        }
                        break;
                }
            }
        }];
    }
}

-(void) updateStateBasedOnError:(NSError*)err{
    switch (err.code) {
        case SPRSimpleCloudMessengerErrorNetwork:
        case SPRSimpleCloudMessengerErrorServiceUnavailable:
            [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitOfflineState alloc] init]];
            break;
        case SPRSimpleCloudMessengerErroriCloudAccount:
            [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitAccountMissingState alloc] init]];
            break;
        case SPRSimpleCloudMessengerErrorMissingDiscoveryPermissions:
            // right now the ONLY permission is for discovery
            // if that changes in the future, will want to make this more accurate
            [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitDeclinedPermissionState alloc] init]];
            break;
        case SPRSimpleCloudMessengerErrorCancelled:
            // network command was somehow cancelled, so re-run it
        case SPRSimpleCloudMessengerErrorUnexpected:
            [[MMCloudKitManager sharedManager] retryStateAfterDelay];
            break;
    }
}

#pragma mark - Notifications

-(void) cloudKitInfoDidChange{
    NSLog(@"%@ cloudKitInfoDidChange", NSStringFromClass([self class]));
    @synchronized(self){
        [self runState];
    }
}

-(void) applicationDidBecomeActive{
    NSLog(@"%@ applicationDidBecomeActive", NSStringFromClass([self class]));
    @synchronized(self){
        [self runState];
    }
}

-(void) reachabilityDidChange{
    NSLog(@"%@ reachabilityDidChange", NSStringFromClass([self class]));
    @synchronized(self){
        [self runState];
    }
}

-(void) cloudKitDidRecievePush{
    // noop
}


@end
