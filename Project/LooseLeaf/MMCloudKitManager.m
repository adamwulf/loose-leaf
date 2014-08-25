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
    // TODO: support user pressing login
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
        }
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
