//
//  MMStopWatch.m
//  LooseLeaf
//
//  Created by Adam Wulf on 2/23/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMStopWatch.h"
#import <mach/mach_time.h>  // for mach_absolute_time() and friends

@implementation MMStopWatch{
    mach_timebase_info_data_t info;
    CGFloat duration;
    
    BOOL isRunning;
    uint64_t start;
    
    BOOL wasRunning;
}

-(id) init{
    if(self = [super init]){
        duration = 0;
        isRunning = NO;
        if (mach_timebase_info(&info) != KERN_SUCCESS) return nil;
        [self registerNotifications];
    }
    return self;
}

-(id) initWithDuration:(CGFloat)_duration{
    if(self = [super init]){
        duration = _duration;
        isRunning = NO;
        if (mach_timebase_info(&info) != KERN_SUCCESS) return nil;
        [self registerNotifications];
    }
    return self;
}

-(void) registerNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL) isRunning{
    @synchronized(self){
        return isRunning;
    }
}

// start running the stop watch
-(void) start{
    @synchronized(self){
        if(!isRunning){
            isRunning = YES;
            start = mach_absolute_time ();
        }
    }
}

// stop running the stop watch
-(CGFloat) stop{
    @synchronized(self){
        duration = [self read];
        isRunning = NO;
    }
    return duration;
}

// read the watch w/o stopping it
-(CGFloat) read{
    @synchronized(self){
        if(isRunning){
            uint64_t end = mach_absolute_time ();
            uint64_t elapsed = end - start;
            
            uint64_t nanos = elapsed * info.numer / info.denom;
            return duration + (CGFloat)nanos / NSEC_PER_SEC;
        }else{
            return duration;
        }
    }
}

#pragma mark - Notifications

-(void) didEnterBackground{
    @synchronized(self){
        if([self isRunning]){
            wasRunning = YES;
            [self stop];
        }
    }
}

-(void) didBecomeActive{
    @synchronized(self){
        if(wasRunning){
            wasRunning = NO;
            [self start];
        }
    }
}



@end
