//
//  MMCloudKitOfflineState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitOfflineState.h"
#import "MMCloudKitManager.h"
#import "Constants.h"

@implementation MMCloudKitOfflineState

-(void) runState{
    // noop
}


#pragma mark - Notifications

-(void) cloudKitInfoDidChange{
    DebugLog(@"%@ cloudKitInfoDidChange", NSStringFromClass([self class]));
    [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitBaseState alloc] init]];
}

-(void) reachabilityDidChange{
    [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitBaseState alloc] init]];
}

@end
