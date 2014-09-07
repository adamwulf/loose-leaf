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

+(NSString*) accountPlistPath{
    return [[MMCloudKitManager cloudKitFilesPath] stringByAppendingPathComponent:@"account.plist"];
}

+(void) clearAccountCache{
    [[NSFileManager defaultManager] removeItemAtPath:[MMCloudKitFetchingAccountInfoState accountPlistPath] error:nil];
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
        [[SPRSimpleCloudKitManager sharedManager] silentlyFetchUserRecordIDOnComplete:^(CKRecordID *userRecord, NSError *error) {
            if([MMCloudKitManager sharedManager].currentState != self){
                // bail early. the network probably went offline
                // while we were waiting for a reply. if we're not current,
                // then we shouldn't process / change state.
                return;
            }
            if(error){
                @synchronized(self){
                    isCheckingStatus = NO;
                }
                [[MMCloudKitManager sharedManager] changeToStateBasedOnError:error];
            }else{
                
                // we now have the user record id, find out
                // if our info matches what we have stored
                // on disk (if anything)
                NSDictionary* cachedUserInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:[MMCloudKitFetchingAccountInfoState accountPlistPath]];
                if(cachedUserInfo && [cachedUserInfo isKindOfClass:[NSDictionary class]]){
                    // sanity check with the class comparison
                    if([[cachedUserInfo objectForKey:@"recordId"] isEqual:userRecord]){
                        NSLog(@"using cached account information");
                        @synchronized(self){
                            isCheckingStatus = NO;
                        }
                        [[SPRSimpleCloudKitManager sharedManager] promptForRemoteNotificationsIfNecessary];
                        [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitFetchFriendsState alloc] initWithUserRecord:userRecord andUserInfo:cachedUserInfo]];
                        [self fetchAccountInformationInBackgroundForUserRecord:userRecord
                                                                 andSaveToPath:[MMCloudKitFetchingAccountInfoState accountPlistPath]
                                                    andUpdateStateWhenComplete:NO];
                        return;
                    }else{
                        // our records don't match, so delete the file
                        // and tell the friends state to delete too
                        [MMCloudKitFetchingAccountInfoState clearAccountCache];
                        [MMCloudKitFetchFriendsState clearFriendsCache];
                    }
                }
                [self fetchAccountInformationInBackgroundForUserRecord:userRecord
                                                         andSaveToPath:[MMCloudKitFetchingAccountInfoState accountPlistPath]
                                            andUpdateStateWhenComplete:YES];
            }
        }];
    }
}


-(void) fetchAccountInformationInBackgroundForUserRecord:(CKRecordID*)userRecord andSaveToPath:(NSString*)userInfoPlistPath andUpdateStateWhenComplete:(BOOL)shouldUpdateState{
    [[SPRSimpleCloudKitManager sharedManager] silentlyFetchUserInfoForUserId:userRecord onComplete:^(CKDiscoveredUserInfo* discoveredInfo, NSError* error) {
        if(shouldUpdateState && [MMCloudKitManager sharedManager].currentState != self){
            // bail early. the network probably went offline
            // while we were waiting for a reply. if we're not current,
            // then we shouldn't process / change state.
            return;
        }
        @synchronized(self){
            isCheckingStatus = NO;
        }
        if(error){
            if(shouldUpdateState){
                [[MMCloudKitManager sharedManager] changeToStateBasedOnError:error];
            }else{
                // the state was already changed because we had cache data.
                // we only loaded it again to update our cache in the background.
                // we can die silently here.
            }
        }else{
            if(![NSKeyedArchiver archiveRootObject:[discoveredInfo asDictionary] toFile:userInfoPlistPath]){
                NSLog(@"couldn't archive CloudKit account data");
            }
            [[SPRSimpleCloudKitManager sharedManager] promptForRemoteNotificationsIfNecessary];
            if(shouldUpdateState){
                [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitFetchFriendsState alloc] initWithUserRecord:userRecord
                                                                                                             andUserInfo:[discoveredInfo asDictionary]]];
            }else{
                // the state was already changed because we had cache data.
                // we only loaded it again to update our cache in the background.
            }
        }
    }];
}

@end
