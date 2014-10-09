//
//  NSArray+Extras.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "NSArray+Extras.h"

@implementation NSArray (Extras)

-(NSArray*) reversedArray{
    NSMutableArray* outArray = [NSMutableArray array];
    for(id obj in self.reverseObjectEnumerator){
        [outArray addObject:obj];
    }
    return [NSArray arrayWithArray:outArray];
}

-(NSArray*) arrayByRemovingObject:(id)obj{
    NSMutableArray* ret = [NSMutableArray arrayWithArray:self];
    [ret removeObject:obj];
    return ret;
}

-(NSArray*) shuffledArray{
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:self];
    for(NSUInteger i = [self count]; i > 1; i--) {
        NSUInteger j = arc4random_uniform((unsigned int)i);
        [temp exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
    return [NSArray arrayWithArray:temp];
}

-(NSSet*) asSet{
    return [NSSet setWithArray:self];
}

@end


@implementation NSMutableArray (Extras)

-(void) shuffle{
    for(NSUInteger i = [self count]; i > 1; i--) {
        NSUInteger j = arc4random_uniform((unsigned int)i);
        [self exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
}

@end
