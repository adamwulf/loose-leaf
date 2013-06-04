//
//  MMBlockOperation.m
//  LooseLeaf
//
//  Created by Adam Wulf on 6/4/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMBlockOperation.h"

@implementation MMBlockOperation

/** Initialize with the provided block. */
- (id) initWithBlock: (void (^)()) block {
    if ((self = [super init]) == nil)
        return nil;
    
    /* Blocks must be copied */
    _block = [block copy];
    
    return self;
}

// from NSOperation
- (void) main {
    _block();
}


@end