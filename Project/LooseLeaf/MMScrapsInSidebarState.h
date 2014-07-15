//
//  MMScrapsInSidebarState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/14/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapsInSidebarStateDelegate.h"

@class MMImmutableScrapsInSidebarState;

@interface MMScrapsInSidebarState : NSObject{
    __weak NSObject<MMScrapsInSidebarStateDelegate>* delegate;
}

@property (nonatomic, readonly) NSObject<MMScrapsInSidebarStateDelegate>* delegate;
@property (readonly) NSString* scrapIDsPath;
@property (nonatomic, readonly) int fullByteSize;
@property (readonly) BOOL hasEditsToSave;
@property (readonly) NSArray* allScrapsInSidebar;

+(dispatch_queue_t) importExportStateQueue;

-(id) initWithDelegate:(NSObject<MMScrapsInSidebarStateDelegate>*)delegate;

#pragma mark - Save and Load

-(BOOL) isStateLoaded;

-(void) loadStateAsynchronously:(BOOL)async atPath:(NSString*)scrapIDsPath andMakeEditable:(BOOL)makeEditable;

-(void) unload;

-(MMImmutableScrapsInSidebarState*) immutableStateForPath:(NSString*)scrapIDsPath;

#pragma mark - Manage Scraps

// returns the scrap for the specified uuid, or nil if there's no match
-(MMScrapView*) scrapForUUID:(NSString*)uuid;

-(void) scrapIsAddedToSidebar:(MMScrapView*)scrap;

-(void) scrapIsRemovedFromSidebar:(MMScrapView*)scrap;

@end
