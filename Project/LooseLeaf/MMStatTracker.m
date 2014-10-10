//
//  MMTracker.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMStatTracker.h"
#import "Mixpanel.h"
#import "Constants.h"

@implementation MMStatTracker{
    NSString* statName;
    NSInteger targetCount;
}

static NSMutableDictionary* trackers;

+(MMStatTracker*) trackerWithName:(NSString *)name{
    MMStatTracker* tracker = [trackers objectForKey:name];
    if(tracker) return tracker;
    tracker = [[MMStatTracker alloc] initWithName:name andTargetCount:10];
    [trackers setObject:tracker forKey:name];
    return tracker;
}

- (instancetype)initWithName:(NSString*)_statName andTargetCount:(NSInteger)_targetCount{
    if(self = [super init]){
        statName = _statName;
        targetCount = _targetCount;
    }
    return self;
}

-(void) trackValue:(CGFloat)nextVal{
    // get current count value
    NSInteger currCount = [[NSUserDefaults standardUserDefaults] integerForKey:[statName stringByAppendingString:@" count"]];
    CGFloat currVal = [[NSUserDefaults standardUserDefaults] floatForKey:[statName stringByAppendingString:@" val"]];
    
    // increment the new sum
    nextVal = nextVal + currCount * currVal;

    // increment to track this one
    currCount++;
    
    // calculate average
    nextVal = nextVal / (float)currCount;

    // if the count is large enough, start
    // sending it to mixpanel
    if(currCount >= targetCount){
        [[[Mixpanel sharedInstance] people] set:statName to:@(nextVal)];
    }

    [[NSUserDefaults standardUserDefaults] setInteger:currCount forKey:[statName stringByAppendingString:@" count"]];
    [[NSUserDefaults standardUserDefaults] setFloat:nextVal forKey:[statName stringByAppendingString:@" val"]];
}

@end
