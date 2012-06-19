//
//  NSArray+MapReduce.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "NSArray+MapReduce.h"

@implementation NSArray (MapReduce)

//NSArray* arr            = [NSArray arrayWithObjects:@"Apple", @"Banana", @"Peanut", @"Tree", NULL];
//NSArray* butters        = [arr map:^(id obj, NSUInteger idx) {
//    return [NSString stringWithFormat:@"%@ Butter", obj];
//}];
- (NSArray*)map:(id (^)(id obj, NSUInteger index))mapfunc {
	NSMutableArray* result = [[NSMutableArray alloc] init];
	NSUInteger index;
	for( index = 0; index < [self count]; index++ ) {
		[result addObject:mapfunc( [self objectAtIndex:index], index )];
	}
	return [result autorelease];
}

//NSNumber* sum = [numbers reduce:^(id obj, NSUInteger idx, id accum) {
//    if( accum == NULL ) {
//        accum = [NSNumber numberWithInt:0];
//    }
//    return (id)[NSNumber numberWithInt:[obj intValue] + [accum intValue]];
//}];
- (id)reduce:(id (^)(id obj, NSUInteger index, id accum))reducefunc {
	id result = NULL;
	NSUInteger index;
	for( index = 0; index < [self count]; index++ ) {
		result = reducefunc( [self objectAtIndex:index], index, result );
	}
	return result;
}

@end
