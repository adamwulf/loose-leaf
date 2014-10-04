//
//  MMImmutableScrapCollectionState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 10/4/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMImmutableScrapCollectionState : NSObject

// returns YES if any changes actually saved,
// NO otherwise
-(BOOL) saveStateToDiskBlocking;

-(NSUInteger) undoHash;

@end
