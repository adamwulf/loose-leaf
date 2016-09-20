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

static Reachability* _localInstance = nil;

+ (Reachability*)sharedManager {
    if (!_instance) {
        _instance = [MMReachabilityManager reachabilityForInternetConnection];
        [_instance startNotifier];
    }
    return _instance;
}

+ (Reachability*)imgurManager {
    if (!_instance) {
        _instance = [MMReachabilityManager reachabilityWithHostName:@"imgur.com"];
        [_instance startNotifier];
    }
    return _instance;
}

+ (Reachability*)sharedLocalNetwork {
    if (!_localInstance) {
        _localInstance = [MMReachabilityManager reachabilityForLocalWiFi];
        [_localInstance startNotifier];
    }
    return _localInstance;
}

@end
