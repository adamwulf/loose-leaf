//
//  MMScrapsInSidebarStateDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/15/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapCollectionStateDelegate.h"

@class MMScrapsOnPaperState;

@protocol MMScrapsInSidebarStateDelegate <MMScrapCollectionStateDelegate>

-(MMScrapsOnPaperState*) paperStateForPageUUID:(NSString*)uuidOfPage;

@end
