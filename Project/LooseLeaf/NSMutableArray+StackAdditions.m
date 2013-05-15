//
//  NSMutableArray+StackAdditions.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "NSMutableArray+StackAdditions.h"

@implementation NSMutableArray (StackAdditions)

- (id) peek{
    return [[[self lastObject] retain] autorelease];
}

- (id)pop{
    // nil if [self count] == 0
    id lastObject = [[[self lastObject] retain] autorelease];
    if (lastObject)
        [self removeLastObject];
    return lastObject;
}

- (void)push:(id)obj{
    [self addObject: obj];
}

- (void) addToBottomOfStack:(id)obj{
    [self insertObject:obj atIndex:0];
}
@end
