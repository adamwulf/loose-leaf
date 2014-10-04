//
//  MMScrapCollectionStateDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 10/3/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMScrapCollectionState, MMScrapView;

@protocol MMScrapCollectionStateDelegate <NSObject>

-(NSString*) uuidOfScrapCollectionStateOwner;

#pragma mark - Scrap Sharing

-(MMScrapView*) scrapForUUIDIfAlreadyExistsInOtherContainer:(NSString*)scrapUUID;

#pragma mark - Loading and Unloading

/**
 * triggered when a scrap is laoded from disk that is
 * actively showing on the page
 */
-(void) didLoadScrapInContainer:(MMScrapView*)scrap;

/**
 * triggered when a scrap is laoded from disk that is
 * NOT actively showing on the page, and is only
 * available inside the page's undo/redo stacks
 */
-(void) didLoadScrapOutOfContainer:(MMScrapView*)scrap;

-(void) didLoadAllScrapsFor:(MMScrapCollectionState*)scrapState;

-(void) didUnloadAllScrapsFor:(MMScrapCollectionState*)scrapState;

@end
