//
//  MMImmutableScrapState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/30/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapsOnPaperState.h"

@interface MMImmutableScrapsOnPaperState : MMScrapsOnPaperState

-(id) initWithScrapIDsPath:(NSString *)scrapIDsPath andScraps:(NSArray*)scraps;

-(void) saveToDisk;

@end
