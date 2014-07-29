//
//  MMImmutableScrapState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/30/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapsOnPaperState.h"

@interface MMImmutableScrapsOnPaperState : MMScrapsOnPaperState

@property (nonatomic, readonly) NSArray* scraps;

-(id) initWithScrapIDsPath:(NSString *)scrapIDsPath andAllScraps:(NSArray*)allScraps andScrapsOnPage:(NSArray*)scrapsOnPage andScrapsOnPaperState:(MMScrapsOnPaperState*)ownerState;

// returns YES if any changes actually saved,
// NO otherwise
-(BOOL) saveStateToDiskBlocking;

-(NSUInteger) undoHash;

@end
