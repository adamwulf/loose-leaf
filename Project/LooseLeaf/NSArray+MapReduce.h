//
//  NSArray+MapReduce.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray <ObjectType> (MapReduce) - (NSArray*)map : (id (^)(ObjectType obj, NSUInteger index))mapfunc;
- (id)reduce:(id (^)(ObjectType obj, NSUInteger index, id accum))reducefunc;
- (BOOL)reduceToBool:(BOOL (^)(ObjectType obj, NSUInteger index, BOOL accum))reducefunc;
@end
