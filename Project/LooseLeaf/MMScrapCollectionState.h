//
//  MMScrapCollectionState.h
//  LooseLeaf
//
//  Created by Adam Wulf on 10/3/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMScrapsOnPaperStateDelegate.h"

@class MMImmutableScrapCollectionState;

@interface MMScrapCollectionState : NSObject{
    // loading state
    BOOL isLoaded;
    BOOL isLoading;
    BOOL isUnloading;
    // scraps
    NSMutableArray* allLoadedScraps;
    BOOL hasEditsToSave;
    // this is the undo hash of the most recent immutable state
    // we were asked to generate
    NSUInteger expectedUndoHash;
    // this is the undo hash of our most recent save.
    // if these two are different, then we have a pending save
    NSUInteger lastSavedUndoHash;
    // delegate
    __weak NSObject<MMScrapCollectionStateDelegate>* delegate;
    // all of the loaded properties for all this state's scraps
    NSMutableArray* allPropertiesForScraps;
}

+(dispatch_queue_t) importExportStateQueue;

@property (nonatomic, readonly) NSObject<MMScrapCollectionStateDelegate>* delegate;
@property (nonatomic, readonly) int fullByteSize;
@property (readonly) BOOL hasEditsToSave;
@property (readonly) NSArray* allLoadedScraps;
@property (readonly) NSUInteger lastSavedUndoHash;

#pragma mark - Manage Scraps

-(void) scrapVisibilityWasUpdated:(MMScrapView*)scrap;

#pragma mark - Save and Load

-(MMImmutableScrapCollectionState*) immutableStateForPath:(NSString*)scrapIDsPath;

-(BOOL) isStateLoaded;

-(void) loadStateAsynchronously:(BOOL)async atPath:(NSString*)scrapIDsPath andMakeEditable:(BOOL)makeEditable;

-(void) unload;

#pragma mark - Paths

-(NSString*) directoryPathForScrapUUID:(NSString*)uuid;

-(NSString*) bundledDirectoryPathForScrapUUID:(NSString*)uuid;

@end
