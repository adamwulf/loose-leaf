//
//  MMReachabilityManager.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "Reachability.h"

@interface MMReachabilityManager : Reachability

+(Reachability*) sharedManager;

+(Reachability*) sharedLocalNetwork;

@end
