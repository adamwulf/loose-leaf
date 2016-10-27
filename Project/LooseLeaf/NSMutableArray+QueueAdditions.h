//
//  NSMutableArray+QueueAdditions.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableArray (QueueAdditions)

- (id)dequeue;
- (void)enqueue:(id)obj;

@end
