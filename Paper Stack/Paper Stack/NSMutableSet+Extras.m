//
//  NSMutableSet+Extras.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "NSMutableSet+Extras.h"

@implementation NSMutableSet (Extras)

-(void) removeObjectsInSet:(NSSet*)set{
    for(id obj in set){
        [self removeObject:obj];
    }
}

-(NSSet*) setByRemovingObject:(id)obj{
    NSMutableSet* ret = [NSMutableSet setWithSet:self];
    [ret removeObject:obj];
    return ret;
}

@end


@implementation NSMutableOrderedSet (Extras)

-(void) removeObjectsInSet:(NSSet*)set{
    for(id obj in set){
        [self removeObject:obj];
    }
}

-(NSOrderedSet*) setByRemovingObject:(id)obj{
    NSMutableOrderedSet* ret = [[obj copy] autorelease];
    [ret removeObject:obj];
    return ret;
}

@end
