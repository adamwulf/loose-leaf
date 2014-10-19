//
//  NSObject_MMScrapCollectionState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 10/3/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMScrapCollectionState (Private)

#pragma mark - Saving Helpers

-(void) wasSavedAtUndoHash:(NSUInteger)savedUndoHash;

@end
