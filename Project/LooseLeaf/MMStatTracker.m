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

    // this array will track all of the values
    // of our data, so we can calculate a
    // moving standard deviation
    NSInteger* values;
    NSInteger valuesLen;
}

static NSMutableDictionary* trackers;

+(MMStatTracker*) trackerWithName:(NSString *)name andTargetCount:(NSInteger)targetCount{
    MMStatTracker* tracker = [trackers objectForKey:name];
    if(tracker) return tracker;
    tracker = [[MMStatTracker alloc] initWithName:name andTargetCount:targetCount];
    [trackers setObject:tracker forKey:name];
    
    return tracker;
}

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
        

        values = calloc(sizeof(NSInteger), targetCount);
        valuesLen = sizeof(NSInteger) * targetCount;
        NSData* storedValues = [[NSUserDefaults standardUserDefaults] dataForKey:[statName stringByAppendingString:@" values"]];
        if(storedValues){
            // if we have data, fill it
            memcpy(values, [storedValues bytes], (size_t) MIN(valuesLen, storedValues.length));
        }
    }
    return self;
}

-(void) trackValue:(CGFloat)thisVal{
    
    // get current count value
    NSInteger currCount = [[NSUserDefaults standardUserDefaults] integerForKey:[statName stringByAppendingString:@" count"]];
    CGFloat currVal = [[NSUserDefaults standardUserDefaults] floatForKey:[statName stringByAppendingString:@" val"]];
    
    // increment to track this one
    currCount++;
    if(currCount > targetCount){
        currCount = targetCount;
    }
    
    // calculate average
    CGFloat movingAvg = (thisVal + (currCount-1) * currVal) / (float)currCount;

    // now store the moving average and data count
    [[NSUserDefaults standardUserDefaults] setInteger:currCount forKey:[statName stringByAppendingString:@" count"]];
    [[NSUserDefaults standardUserDefaults] setFloat:movingAvg forKey:[statName stringByAppendingString:@" val"]];
    
    
    //
    // next, calculate the moving standard deviation
    NSInteger sumSquares = [[NSUserDefaults standardUserDefaults] integerForKey:[statName stringByAppendingString:@" sumSquares"]];
    NSInteger offset = [[NSUserDefaults standardUserDefaults] integerForKey:[statName stringByAppendingString:@" offset"]];

    CGFloat deviation = thisVal - movingAvg;
    // remove old value
    sumSquares -= values[offset];
    // add in new value
    values[offset] = deviation*deviation;
    // move our offset to the next space
    offset = (offset+1)%targetCount;
    sumSquares += deviation*deviation;
    
    // update our data
    [[NSUserDefaults standardUserDefaults] setInteger:sumSquares forKey:[statName stringByAppendingString:@" sumSquares"]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSData dataWithBytes:values length:valuesLen] forKey:[statName stringByAppendingString:@" values"]];
    [[NSUserDefaults standardUserDefaults] setInteger:offset forKey:[statName stringByAppendingString:@" offset"]];

    
    CGFloat stDev = sqrt(sumSquares/targetCount);
    
    
    
    // if the count is large enough, start
    // sending it to mixpanel
    if(currCount >= targetCount){
        if(!isnan(movingAvg)){
            [[[Mixpanel sharedInstance] people] set:[statName stringByAppendingString:@" Avg"] to:@(movingAvg)];
        }
        if(!isnan(stDev)){
            [[[Mixpanel sharedInstance] people] set:[statName stringByAppendingString:@" StDev"] to:@(stDev)];
        }
//        DebugLog(@"%@ => avg: %f  stdev: %f   dev:%f", statName, movingAvg, stDev, deviation);
    }
    
}

@end
