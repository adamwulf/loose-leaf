//
//  NSArray+Map.h
//  LooseLeaf
//
//  Created by Adam Wulf on 6/4/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray <ObjectType> (Map)

- (NSArray*)mapObjectsUsingBlock : (id (^)(ObjectType obj, NSUInteger idx))block;

- (NSArray*)mapObjectsUsingSelector:(SEL)selector;

@end
