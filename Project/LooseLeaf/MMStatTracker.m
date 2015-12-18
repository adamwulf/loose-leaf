//
//  MMTracker.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/10/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMStatTracker.h"
#import <Mixpanel/Mixpanel.h>
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


#pragma mark - Dispatch Queue

static dispatch_queue_t statTrackerQueue;

+(dispatch_queue_t) statTrackerQueue{
    if(!statTrackerQueue){
        statTrackerQueue = dispatch_queue_create("com.milestonemade.looseleaf.statTrackerQueue", DISPATCH_QUEUE_SERIAL);
    }
    return statTrackerQueue;
}

#pragma mark - Trackers

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
        dispatch_async([MMStatTracker statTrackerQueue], ^{
            NSDictionary* defaultValues = [[NSUserDefaults standardUserDefaults] dictionaryForKey:statName];

            NSData* storedValues = [defaultValues objectForKey:@"values"];
            if(storedValues){
                // if we have data, fill it
                memcpy(values, [storedValues bytes], (size_t) MIN(valuesLen, storedValues.length));
            }
        });
    }
    return self;
}

-(void) trackValue:(CGFloat)thisVal{
    dispatch_async([MMStatTracker statTrackerQueue], ^{
        
        NSMutableDictionary* storedValues = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:statName] mutableCopy];
        
        
        // get current count value
        
        NSInteger currCount = [[storedValues objectForKey:@"count"] integerValue];
        CGFloat currVal = [[storedValues objectForKey:@"val"] floatValue];
        
        // increment to track this one
        currCount++;
        if(currCount > targetCount){
            currCount = targetCount;
        }
        
        // calculate average
        CGFloat movingAvg = (thisVal + (currCount-1) * currVal) / (float)currCount;
        

        //
        // next, calculate the moving standard deviation
        NSInteger sumSquares = [[storedValues objectForKey:@"sumSquares"] integerValue];
        NSInteger offset = [[storedValues objectForKey:@"offset"] integerValue];
        
        CGFloat deviation = thisVal - movingAvg;
        // remove old value
        sumSquares -= values[offset];
        // add in new value
        values[offset] = deviation*deviation;
        // move our offset to the next space
        offset = (offset+1)%targetCount;
        sumSquares += deviation*deviation;
        
        // update our data
        [storedValues setObject:@(currCount) forKey:@"count"];
        [storedValues setObject:@(movingAvg) forKey:@"val"];
        [storedValues setObject:@(sumSquares) forKey:@"sumSquares"];
        [storedValues setObject:[NSData dataWithBytes:values length:valuesLen] forKey:@"values"];
        [storedValues setObject:@(offset) forKey:@"offset"];

        [[NSUserDefaults standardUserDefaults] setObject:storedValues forKey:statName];
        
        
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
    });
}

@end
