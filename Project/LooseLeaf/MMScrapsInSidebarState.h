//
//  MMScrapsInSidebarState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/14/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapsInSidebarStateDelegate.h"
#import "MMScrapCollectionState.h"


@interface MMScrapsInSidebarState : MMScrapCollectionState

@property (nonatomic, readonly) NSObject<MMScrapsInSidebarStateDelegate>* delegate;
@property (readonly) NSString* scrapIDsPath;

- (id)initWithDelegate:(NSObject<MMScrapsInSidebarStateDelegate>*)delegate;

#pragma mark - Manage Scraps

// returns the scrap for the specified uuid, or nil if there's no match
- (MMScrapView*)scrapForUUID:(NSString*)uuid;

- (void)scrapIsAddedToSidebar:(MMScrapView*)scrap;

- (void)scrapIsRemovedFromSidebar:(MMScrapView*)scrap;

@end
