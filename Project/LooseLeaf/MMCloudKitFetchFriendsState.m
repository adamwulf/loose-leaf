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
#import "NSArray+MapReduce.h"
#import <SimpleCloudKitManager/SPRSimpleCloudKitManager.h>
#import "Constants.h"

@implementation MMCloudKitFetchFriendsState{
    BOOL isCheckingStatus;
    CKRecordID* userRecord;
    NSDictionary* userInfo;
    NSArray* friendList;
}

@synthesize friendList;

+(NSString*) friendsPlistPath{
    return [[MMCloudKitManager cloudKitFilesPath] stringByAppendingPathComponent:@"friends.plist"];
}

+(void) clearFriendsCache{
    [[NSFileManager defaultManager] removeItemAtPath:[MMCloudKitFetchFriendsState friendsPlistPath] error:nil];
}

-(id) initWithUserRecord:(CKRecordID *)_userRecord andUserInfo:(NSDictionary *)_userInfo andCachedFriendList:(NSArray*)_friendList{
    if(self = [super init]){
        userRecord = _userRecord;
        userInfo = _userInfo;
        friendList = _friendList;
    }
    return self;
}

-(id) initWithUserRecord:(CKRecordID*)_userRecord andUserInfo:(NSDictionary*)_userInfo{
    NSArray* cachedFriendList = [NSKeyedUnarchiver unarchiveObjectWithFile:[MMCloudKitFetchFriendsState friendsPlistPath]];
    
    return [self initWithUserRecord:_userRecord andUserInfo:_userInfo andCachedFriendList:cachedFriendList];
}

-(NSArray*) friendList{
    return friendList;
}

-(NSArray*) filteredFriendsList:(NSArray*)friendsList{
    NSArray* filteredFriends = [friendsList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        CKDiscoveredUserInfo* friend = (CKDiscoveredUserInfo*)evaluatedObject;
        return ![friend.userRecordID isEqual:userRecord];
    }]];
    return [filteredFriends map:^id(id obj, NSUInteger index) {
        return [obj asDictionary];
    }];
}

-(void) runState{
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
        [[SPRSimpleCloudKitManager sharedManager] discoverAllFriendsWithCompletionHandler:^(NSArray *friendRecords, NSError *error) {
            if([MMCloudKitManager sharedManager].currentState != self){
                // bail early. the network probably went offline
                // while we were waiting for a reply. if we're not current,
                // then we shouldn't process / change state.
                return;
            }
            @synchronized(self){
                isCheckingStatus = NO;
            }
            if(error && !friendList){
                [[MMCloudKitManager sharedManager] changeToStateBasedOnError:error];
            }else if(error){
                // probably rate limited, but we already have
                // some cached friends, so no biggie, just use those
                [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitLoggedInState alloc] initWithUserRecord:userRecord
                                                                                                         andUserInfo:userInfo
                                                                                                       andFriendList:self.friendList]];
            }else{
                // no error, so send our new friend list to the
                // logged in state
                NSArray* filteredAndUpdatedFriendList = [self filteredFriendsList:friendRecords];
                
                if(![NSKeyedArchiver archiveRootObject:filteredAndUpdatedFriendList toFile:[MMCloudKitFetchFriendsState friendsPlistPath]]){
                    DebugLog(@"couldn't archive CloudKit data");
                }
                [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitLoggedInState alloc] initWithUserRecord:userRecord
                                                                                                         andUserInfo:userInfo
                                                                                                       andFriendList:filteredAndUpdatedFriendList]];
            }
        }];
    }
}

-(BOOL) isLoggedInAndReadyForAnything{
    return friendList != nil;
}

@end
