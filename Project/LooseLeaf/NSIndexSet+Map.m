//
//  NSIndexSet+Map.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/18/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "NSIndexSet+Map.h"

@implementation NSIndexSet (Map)

- (NSIndexSet *)mapIndexesUsingBlock:(NSUInteger (^)(NSUInteger idx))block {
    NSMutableIndexSet *result = [NSMutableIndexSet indexSet];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [result addIndex:block(idx)];
    }];
    return result;
}


@end
