//
//  NSArray+MapReduce.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (MapReduce)
- (NSArray*)map:(id (^)(id obj, NSUInteger index))mapfunc;
- (id)reduce:(id (^)(id obj, NSUInteger index, id accum))reducefunc;
@end

