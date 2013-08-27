//
//  NSArray+Extras.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "NSArray+Extras.h"

@implementation NSArray (Extras)

-(NSArray*) reverseArray{
    NSMutableArray* outArray = [NSMutableArray array];
    for(id obj in self.reverseObjectEnumerator){
        [outArray addObject:obj];
    }
    return [NSArray arrayWithArray:outArray];
}

@end
