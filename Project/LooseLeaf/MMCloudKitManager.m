//
//  MMCloudKitManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/22/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitManager.h"
#import <SimpleCloudKitManager/SPRSimpleCloudKitManager.h>
#import "NSThread+BlockAdditions.h"
#import "MMCloudKitLoginState.h"
#import "MMReachabilityManager.h"

@implementation MMCloudKitManager{
    MMCloudKitBaseState* currentState;
}

@synthesize delegate;

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudKitInfoDidChange) name:NSUbiquityIdentityDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange) name:kReachabilityChangedNotification object:nil];
        
        currentState = [[MMCloudKitBaseState alloc] init];
        
        // the UIApplicationDidBecomeActiveNotification will kickstart the process when the app launches
    }
    return self;
}

+ (MMCloudKitManager *) sharedManager {
    static dispatch_once_t onceToken;
    static MMCloudKitManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[MMCloudKitManager alloc] init];
    });
    return manager;
}

+(BOOL) isCloudKitAvailable{
    return [CKContainer class] != nil;
}

-(void) userRequestedToLogin{
    if(![currentState isKindOfClass:[MMCloudKitLoginState class]]){
        [self changeToState:[[MMCloudKitLoginState alloc] init]];
    }
}

-(void) changeToState:(MMCloudKitBaseState*)state{
    currentState = state;
    [currentState runState];
}

-(void) retryStateAfterDelay{
    [self performSelector:@selector(delayedRunStateFor:) withObject:currentState afterDelay:1];
}

-(void) delayedRunStateFor:(MMCloudKitBaseState*)aState{
    if(currentState == aState){
        [aState runState];
    }
}

#pragma mark - Notifications

-(void) cloudKitInfoDidChange{
    // handle change in cloudkit
    [currentState cloudKitInfoDidChange];
}

-(void) applicationDidBecomeActive{
    [currentState applicationDidBecomeActive];
}

-(void) reachabilityDidChange{
    [currentState reachabilityDidChange];
}



#pragma mark - Description

-(NSString*) description{
    NSString* cloudKitInfo = nil;
    if([SPRSimpleCloudKitManager sharedManager].accountStatus == CKAccountStatusAvailable){
        cloudKitInfo = @"Available";
        if([SPRSimpleCloudKitManager sharedManager].accountRecordID){
            cloudKitInfo = [cloudKitInfo stringByAppendingFormat:@"\nrecord id: %@", [SPRSimpleCloudKitManager sharedManager].accountRecordID];
        }
        if([SPRSimpleCloudKitManager sharedManager].accountInfo){
            cloudKitInfo = [cloudKitInfo stringByAppendingFormat:@"\ninfo: %@", [SPRSimpleCloudKitManager sharedManager].accountInfo];
        }
        if([SPRSimpleCloudKitManager sharedManager].permissionStatus == CKApplicationPermissionStatusCouldNotComplete){
            cloudKitInfo = [cloudKitInfo stringByAppendingString:@"\npermission: unknown"];
        }else if([SPRSimpleCloudKitManager sharedManager].permissionStatus == CKApplicationPermissionStatusDenied){
            cloudKitInfo = [cloudKitInfo stringByAppendingString:@"\npermission: denied"];
        }else if([SPRSimpleCloudKitManager sharedManager].permissionStatus == CKApplicationPermissionStatusGranted){
            cloudKitInfo = [cloudKitInfo stringByAppendingString:@"\npermission: granted"];
        }else if([SPRSimpleCloudKitManager sharedManager].permissionStatus == CKApplicationPermissionStatusInitialState){
            cloudKitInfo = [cloudKitInfo stringByAppendingString:@"\npermission: initial state"];
        }else if([SPRSimpleCloudKitManager sharedManager].permissionStatus == SCKMApplicationPermissionStatusLoading){
            cloudKitInfo = [cloudKitInfo stringByAppendingString:@"\npermission: loading"];
        }
    }else if([SPRSimpleCloudKitManager sharedManager].accountStatus == SCKMAccountStatusLoading){
        cloudKitInfo = @"Loading";
    }else{
        cloudKitInfo = @"Not Available";
    }
    return cloudKitInfo;
}




#pragma mark - Move This Into States

/*

-(void) updateState{
    accountStatus = [SPRSimpleCloudKitManager sharedManager].accountStatus;
    permissionStatus = [SPRSimpleCloudKitManager sharedManager].permissionStatus;
    accountRecordID = [SPRSimpleCloudKitManager sharedManager].accountRecordID;
    accountInfo = [SPRSimpleCloudKitManager sharedManager].accountInfo;
    
    switch (accountStatus) {
        case SCKMAccountStatusLoading:
            // noop, once it loads it'll call [updateState]
            // again, so just wait for that.
            break;
        case SCKMAccountStatusCouldNotDetermine:
            // accountStatus is unknown, so reload it
            accountStatus = SCKMAccountStatusLoading;
            permissionStatus = SCKMApplicationPermissionStatusLoading;
            accountRecordID = nil;
            accountInfo = nil;
            [self.delegate cloudKitDidError:mostRecentError];
            [self performSelector:@selector(silentlyLoadStateIfNeeded) withObject:nil afterDelay:1];
            break;
        case SCKMAccountStatusNoAccount:
        case SCKMAccountStatusRestricted:
            // notify that cloudKit is entirely unavailable
            [self.delegate cloudKitIsUnavailableForThisUser];
            break;
        case SCKMAccountStatusAvailable:
            switch (permissionStatus) {
                case SCKMApplicationPermissionStatusLoading:
                    // noop, once it loads it'll call [updateState]
                    // again, so just wait for that.
                    break;
                case SCKMApplicationPermissionStatusCouldNotComplete:
                    accountStatus = SCKMAccountStatusCouldNotDetermine;
                    permissionStatus = SCKMApplicationPermissionStatusLoading;
                    accountRecordID = nil;
                    accountInfo = nil;
                    [self performSelector:@selector(silentlyLoadStateIfNeeded) withObject:nil afterDelay:1];
                    break;
                case SCKMApplicationPermissionStatusDenied:
                    // account exists for iCloud, but the user has
                    // denied us permission to use it
                    [self.delegate cloudKitIsUnavailableForThisUser];
                    break;
                case SCKMApplicationPermissionStatusInitialState:
                    // unknown permission
                    [self.delegate cloudKitPermissionIsUnknownForThisUser];
                case SCKMApplicationPermissionStatusGranted:
                    // icloud is available for this user, so we need to
                    // fetch their account info if we don't already have it.
                    if(!accountRecordID || !accountInfo){
                        [self silentlyLoadAccountInformation];
                    }else{
                        // we have both account info and records
                        if(![friendList count]){
                            [self silentlyLoadFriendList];
                        }else{
                            // done! we have friends
                            // and all user information
                        }
                    }
                    break;
            }
            break;
    }
}

-(void) login{
    if(accountStatus == SCKMAccountStatusAvailable &&
       permissionStatus == SCKMApplicationPermissionStatusInitialState){
        [[SPRSimpleCloudKitManager sharedManager] promptAndFetchUserInfoOnComplete:^(SCKMAccountStatus accountStatus,
                                                                                     SCKMApplicationPermissionStatus permissionStatus,
                                                                                     CKRecordID *recordID,
                                                                                     CKDiscoveredUserInfo *userInfo,
                                                                                     NSError *error) {
            // noop
            [self updateState];
        }];
    }
}

-(void) silentlyLoadStateIfNeeded{
    if(accountStatus == SCKMAccountStatusCouldNotDetermine){
        [[SPRSimpleCloudKitManager sharedManager] silentlyVerifyiCloudAccountStatusOnComplete:^(SCKMAccountStatus _accountStatus,
                                                                                                SCKMApplicationPermissionStatus _permissionStatus,
                                                                                                NSError *error) {
            mostRecentError = error;
            if(!error){
                [self updateState];
            }else{
                [self performSelector:@selector(updateState) withObject:nil afterDelay:1];
            }
        }];
    }
}

-(void) silentlyLoadAccountInformation{
    if(accountStatus == SCKMAccountStatusAvailable &&
       permissionStatus == SCKMApplicationPermissionStatusGranted){
        [[SPRSimpleCloudKitManager sharedManager] silentlyFetchUserInfoOnComplete:^(CKRecordID* userRecord, CKDiscoveredUserInfo *userInfo, NSError *error) {
            mostRecentError = error;
            if(!error){
                [self updateState];
            }else{
                [self performSelector:@selector(updateState) withObject:nil afterDelay:1];
            }
        }];
    }
}

-(void) silentlyLoadFriendList{
    if(accountStatus == SCKMAccountStatusAvailable &&
       permissionStatus == SCKMApplicationPermissionStatusGranted &&
       accountRecordID &&
       accountInfo){
        [[SPRSimpleCloudKitManager sharedManager] discoverAllFriendsWithCompletionHandler:^(NSArray *friendRecords, NSError *error) {
            friendList = friendRecords;
            [self updateState];
            [self.delegate cloudKitDidLoadFriends:friendList];
        }];
    }
}
 */



@end
