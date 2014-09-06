//
//  MMCloudKitLoggedInState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitLoggedInState.h"
#import "MMReachabilityManager.h"
#import "MMCloudKitManager.h"
#import "MMCloudKitOfflineState.h"
#import "MMCloudKitFetchFriendsState.h"

@implementation MMCloudKitLoggedInState{
    CKRecordID* userRecord;
    NSDictionary* userInfo;
    NSArray* friendList;
    NSTimer* fetchAllMessagesTimer;
    BOOL hasEverFetchedNewMessages;
}

@synthesize friendList;

-(id) initWithUserRecord:(CKRecordID*)_userRecord andUserInfo:(NSDictionary*)_userInfo andFriendList:(NSArray *)_friendList{
    if(self = [super init]){
        userRecord = _userRecord;
        userInfo = _userInfo;
        friendList = _friendList;
    }
    return self;
}

-(void) runState{
    NSLog(@"Running state %@", NSStringFromClass([self class]));
    if([MMReachabilityManager sharedManager].currentReachabilityStatus == NotReachable){
        // we can't connect to cloudkit, so move to an error state
        [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitOfflineState alloc] init]];
    }else{
        if(!hasEverFetchedNewMessages){
            [fetchAllMessagesTimer invalidate];
            fetchAllMessagesTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(fetchAllNewMessages) userInfo:nil repeats:NO];
        }else{
            [self cloudKitDidCheckForNotifications];
        }
        
        // we'll periodically swap back to the fetch friends state
        // just in case the user has added anyone to their contact list
        // and/or anyone new in their list has logged into icloud recently.
        //
        // CloudKit seems to rate limit this to once every ~900s, so it's
        // rare that this would do anything, but nice to have i suppose
        [self performSelector:@selector(swapToFriendsState) withObject:nil afterDelay:60];
    }
}

-(void) applicationDidBecomeActive{
    [self swapToFriendsState];
}

-(void) killState{
    [fetchAllMessagesTimer invalidate];
    fetchAllMessagesTimer = nil;
    [super killState];
}

-(void) swapToFriendsState{
    [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitFetchFriendsState alloc] initWithUserRecord:userRecord andUserInfo:userInfo andCachedFriendList:friendList]];
}

-(void) fetchAllNewMessages{
    [fetchAllMessagesTimer invalidate];
    fetchAllMessagesTimer = nil;
    [[MMCloudKitManager sharedManager] fetchAllNewMessages];
}

-(void) cloudKitDidRecievePush{
    [self runState];
}

-(void) cloudKitDidCheckForNotifications{
    if(![UIApplication sharedApplication].isRegisteredForRemoteNotifications || ![SPRSimpleCloudKitManager sharedManager].isSubscribed){
        [fetchAllMessagesTimer invalidate];
        fetchAllMessagesTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(fetchAllNewMessages) userInfo:nil repeats:NO];
    }
}

@end
