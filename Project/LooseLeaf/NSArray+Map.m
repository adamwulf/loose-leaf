//
//  NSArray+Map.m
//  LooseLeaf
//
//  Created by Adam Wulf on 6/4/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "NSArray+Map.h"

@implementation NSArray (Map)

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}

- (NSArray *)mapObjectsUsingSelector:(SEL)selector{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // suppress selector warning:
        // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
        [result addObject:[obj performSelector:selector]];
#pragma clang diagnostic pop
    }];
    return result;
}

@end
