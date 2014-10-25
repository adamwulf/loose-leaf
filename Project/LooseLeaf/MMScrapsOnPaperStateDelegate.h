//
//  MMScrapsOnPaperStateDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapCollectionStateDelegate.h"

@class MMScrapView, MMScrappedPaperView;

@protocol MMScrapsOnPaperStateDelegate <MMScrapCollectionStateDelegate>

-(MMScrappedPaperView*) page;

-(BOOL) isEditable;

-(NSString*) pagesPath;

-(NSString*) bundledPagesPath;

#pragma mark - Scrap Container for Sidebar

-(void) deleteScrapWithUUID:(NSString*)scrapUUID shouldRespectOthers:(BOOL)respectOthers;

@end
