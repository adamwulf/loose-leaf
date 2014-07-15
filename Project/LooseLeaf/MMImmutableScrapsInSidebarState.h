//
//  MMImmutableScrapsInSidebarState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/15/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapsInSidebarState.h"

@interface MMImmutableScrapsInSidebarState : MMScrapsInSidebarState

@property (nonatomic, readonly) NSArray* scraps;

-(id) initWithScrapIDsPath:(NSString *)scrapIDsPath andAllScraps:(NSArray*)allScraps;

// returns YES if any changes actually saved,
// NO otherwise
-(BOOL) saveStateToDiskBlocking;

@end
