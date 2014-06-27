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

-(id) initWithScrapIDsPath:(NSString *)scrapIDsPath andScraps:(NSArray*)scraps;

// returns YES if any changes actually saved,
// NO otherwise
-(BOOL) saveStateToDiskBlockingAtPath:(NSString*)path;

@end
