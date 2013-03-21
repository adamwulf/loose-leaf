//
//  NSArray+MapReduce.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (MapReduce)
- (NSArray*)map:(id (^)(id obj, NSUInteger index))mapfunc;
- (id)reduce:(id (^)(id obj, NSUInteger index, id accum))reducefunc;
@end

