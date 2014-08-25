//
//  MMCloudKitOfflineState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitOfflineState.h"
#import "MMCloudKitManager.h"

@implementation MMCloudKitOfflineState

-(void) runState{
    NSLog(@"Running state %@", NSStringFromClass([self class]));
    // noop
}


#pragma mark - Notifications

-(void) cloudKitInfoDidChange{
    NSLog(@"%@ cloudKitInfoDidChange", NSStringFromClass([self class]));
    [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitBaseState alloc] init]];
}

-(void) applicationDidBecomeActive{
    NSLog(@"%@ applicationDidBecomeActive", NSStringFromClass([self class]));
    [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitBaseState alloc] init]];
}

-(void) reachabilityDidChange{
    NSLog(@"%@ reachabilityDidChange", NSStringFromClass([self class]));
    [[MMCloudKitManager sharedManager] changeToState:[[MMCloudKitBaseState alloc] init]];
}

@end
