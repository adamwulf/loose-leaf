//
//  MMImmutableScrapsInSidebarState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/15/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapCollectionState.h"
#import "MMImmutableScrapCollectionState.h"

@interface MMImmutableScrapsInSidebarState : MMImmutableScrapCollectionState

-(id) initWithScrapIDsPath:(NSString *)scrapIDsPath andAllScrapProperties:(NSArray*)allScrapProperties andOwnerState:(MMScrapCollectionState*)ownerState;

@end
