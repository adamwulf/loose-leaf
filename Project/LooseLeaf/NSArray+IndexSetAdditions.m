//
//  NSArray+IndexSetAdditions.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "NSArray+IndexSetAdditions.h"

<<<<<<< HEAD
@implementation NSArray_IndexSetAdditions

@end
=======
@implementation NSArray (IndexSetAddition)

- (NSArray *) subarrayWithIndexes: (NSIndexSet *)indexes{
    NSMutableArray *targetArray  = [NSMutableArray array];
    NSUInteger count = [self count];
    
    NSUInteger index = [indexes firstIndex];
    while ( index != NSNotFound )
    {
        if ( index < count )
            [targetArray addObject: [self objectAtIndex: index]];
        
        index = [indexes indexGreaterThanIndex: index];
    }
    
    return targetArray;
}

@end
>>>>>>> josh
