//
//  MMScrapsInSidebarStateDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/15/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMScrapView, MMScrapsInSidebarState, MMScrapContainerView,MMScrapSidebarContainerView,MMScrapsOnPaperState;

@protocol MMScrapsInSidebarStateDelegate <NSObject>

-(NSArray*) scrapsOnPaper;

/**
 * triggered when a scrap is laoded from disk that is
 * actively showing on the page
 */
-(void) didLoadScrapInSidebar:(MMScrapView*)scrap;

-(void) didLoadAllScrapsInSidebar:(MMScrapsInSidebarState*)scrapState;

-(void) didUnloadAllScrapsInSidebar:(MMScrapsInSidebarState*)scrapState;

-(MMScrapsOnPaperState*) paperStateForPageUUID:(NSString*)uuidOfPage;

@end
