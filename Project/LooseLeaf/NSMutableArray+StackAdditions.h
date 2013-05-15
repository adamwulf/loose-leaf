//
//  NSMutableArray+StackAdditions.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (StackAdditions)

- (id) peek;
- (id)pop;
- (void)push:(id)obj;
- (void) addToBottomOfStack:(id)obj;

@end
