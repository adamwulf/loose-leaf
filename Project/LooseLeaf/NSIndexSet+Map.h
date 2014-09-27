//
//  NSIndexSet+Map.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/18/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexSet (Map)

- (NSIndexSet *)mapIndexesUsingBlock:(NSUInteger (^)(NSUInteger idx))block;

@end
