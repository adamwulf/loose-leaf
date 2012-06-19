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

@end
