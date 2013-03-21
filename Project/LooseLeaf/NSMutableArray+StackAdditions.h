//
//  NSMutableArray+StackAdditions.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/18/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (StackAdditions)

- (id) peek;
- (id)pop;
- (void)push:(id)obj;
- (void) addToBottomOfStack:(id)obj;

@end
