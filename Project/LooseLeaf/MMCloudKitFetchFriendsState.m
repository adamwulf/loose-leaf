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
#import "CKDiscoveredUserInfo+Initials.h"
#import <SimpleCloudKitManager/SPRSimpleCloudKitManager.h>

@implementation MMCloudKitFetchFriendsState{
    BOOL isCheckingStatus;
    CKRecordID* userRecord;
    NSDictionary* userInfo;
    NSArray* friendList;
}

@synthesize friendList;

-(id) initWithUserRecord:(CKRecordID *)_userRecord andUserInfo:(NSDictionary *)_userInfo andCachedFriendList:(NSArray*)_friendList{
    if(self = [super init]){
        userRecord = _userRecord;
        userInfo = _userInfo;
        friendList = _friendList;
    }
    return self;
}

-(NSArray*) friendList{
    return friendList;
}

+(NSString*) friendsPlistPath{
    return [[MMCloudKitManager cloudKitFilesPath] stringByAppendingPathComponent:@"friends.plist"];
}

-(id) initWithUserRecord:(CKRecordID*)_userRecord andUserInfo:(NSDictionary*)_userInfo{
    NSArray* cachedFriendList = [NSKeyedUnarchiver unarchiveObjectWithFile:[MMCloudKitFetchFriendsState friendsPlistPath]];
    
    return [self initWithUserRecord:_userRecord andUserInfo:_userInfo andCachedFriendList:cachedFriendList];
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
            if(error && !friendList){
                [self updateStateBasedOnError:error];
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
                    NSLog(@"couldn't archive CloudKit data");
                }
                [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitLoggedInState alloc] initWithUserRecord:userRecord
                                                                                                         andUserInfo:userInfo
                                                                                                       andFriendList:filteredAndUpdatedFriendList]];
            }
        }];
    }
}

@end
