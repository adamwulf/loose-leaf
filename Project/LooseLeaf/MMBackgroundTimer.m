//
//  MMBackgroundTimer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMBackgroundTimer.h"

@implementation MMBackgroundTimer

-(id) initWithInterval:(NSTimeInterval)_interval andTarget:(id)_target andSelector:(SEL)_action{
    if(self = [super init]){
        target = _target;
        action = _action;
        interval = _interval;
        done = NO;
    }
    return self;
}

-(void) main
{
    if ([self isCancelled])
    {
        return;
    }
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                      target:target
                                                    selector:action
                                                    userInfo:nil
                                                     repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    //keep the runloop going as long as needed
    while (!done && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                              beforeDate:[NSDate distantFuture]]);
    
}

@end
