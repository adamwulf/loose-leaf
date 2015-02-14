//
//  NSSet+Array.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/24/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "NSSet+Array.h"

@implementation NSSet (Array)

-(NSArray*) array{
    NSMutableArray* arr = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [arr addObject:obj];
    }];
    return arr;
}

@end
