//
//  NSMutableArray+StackAdditions.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "NSMutableArray+StackAdditions.h"

@implementation NSMutableArray (StackAdditions)

- (id) peek{
    return [self lastObject];
}

- (id)pop{
    // nil if [self count] == 0
    id __strong lastObject = [self lastObject];
    if (lastObject){
        [self removeLastObject];
    }
    return lastObject;
}

- (void)push:(id)obj{
    [self addObject: obj];
}

- (void) addToBottomOfStack:(id)obj{
    [self insertObject:obj atIndex:0];
}
@end
