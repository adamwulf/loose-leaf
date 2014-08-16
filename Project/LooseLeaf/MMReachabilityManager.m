//
//  MMReachabilityManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMReachabilityManager.h"

@implementation MMReachabilityManager

static Reachability* _instance = nil;

+(Reachability*) sharedManager{
    if(!_instance){
        _instance = [MMReachabilityManager reachabilityWithHostName:@"imgur.com"];
        [_instance startNotifier];
    }
    return _instance;
}
@end
