//
//  MMBackgroundTimer.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMBackgroundTimer : NSOperation{
    BOOL done;
    id target;
    SEL action;
    NSTimeInterval interval;
}

-(id) initWithInterval:(NSTimeInterval)interval andTarget:(id)target andSelector:(SEL)action;

@end
