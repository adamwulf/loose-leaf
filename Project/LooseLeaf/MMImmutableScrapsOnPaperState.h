//
//  MMImmutableScrapState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/30/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapsOnPaperState.h"
#import "MMImmutableScrapCollectionState.h"

@interface MMImmutableScrapsOnPaperState : MMImmutableScrapCollectionState

@property (nonatomic, readonly) NSArray* scraps;

-(id) initWithScrapIDsPath:(NSString *)scrapIDsPath andAllScraps:(NSArray*)allScraps andScrapsOnPage:(NSArray*)scrapsOnPage andOwnerState:(MMScrapCollectionState*)ownerState;

@end
