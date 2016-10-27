//
//  NSMutableArray+QueueAdditions.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "NSMutableArray+QueueAdditions.h"


@implementation NSMutableArray (QueueAdditions)

// Queues are first-in-first-out, so we remove objects from the head
- (id)dequeue {
    // if ([self count] == 0) return nil; // to avoid raising exception (Quinn)
    id __strong headObject = [self objectAtIndex:0];
    if (headObject != nil) {
        [self removeObjectAtIndex:0];
    }
    return headObject;
}

// Add to the tail of the queue (no one likes it when people cut in line!)
- (void)enqueue:(id)anObject {
    [self addObject:anObject];
    //this method automatically adds to the end of the array
}

@end
