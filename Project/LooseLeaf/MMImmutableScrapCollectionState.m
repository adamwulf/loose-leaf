//
//  MMImmutableScrapCollectionState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/4/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMImmutableScrapCollectionState.h"
#import "Constants.h"


@implementation MMImmutableScrapCollectionState

- (NSArray*)scraps {
    @throw kAbstractMethodException;
}

// returns YES if any changes actually saved,
// NO otherwise
- (BOOL)saveStateToDiskBlocking {
    @throw kAbstractMethodException;
}

- (NSUInteger)undoHash {
    @throw kAbstractMethodException;
}

@end
