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

typedef enum{
    MMScrapCollectionStateTargetLoadedEditable,
    MMScrapCollectionStateTargetLoadedNotEditable,
    MMScrapCollectionStateTargetUnloaded
} MMScrapCollectionStateStatus;

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
    //
    // target load/unload status
    MMScrapCollectionStateStatus targetLoadedState;
}

+(dispatch_queue_t) importExportStateQueue;
+(BOOL) isImportExportStateQueue;

@property (nonatomic, readonly) NSObject<MMScrapCollectionStateDelegate>* delegate;
@property (nonatomic, readonly) int fullByteSize;
@property (readonly) BOOL hasEditsToSave;
@property (readonly) NSArray* allLoadedScraps;
@property (readonly) NSUInteger lastSavedUndoHash;
@property (readonly) NSUInteger countOfAllLoadedScraps;

#pragma mark - Manage Scraps

-(void) scrapVisibilityWasUpdated:(MMScrapView*)scrap;

// returns the scrap for the specified uuid, or nil if there's no match
-(MMScrapView*) scrapForUUID:(NSString*)uuid;

#pragma mark - Save and Load

-(MMImmutableScrapCollectionState*) immutableStateForPath:(NSString*)scrapIDsPath;

-(BOOL) isStateLoaded;
-(BOOL) isCollectionStateLoading;

-(void) loadStateAsynchronously:(BOOL)async atPath:(NSString*)scrapIDsPath andMakeEditable:(BOOL)makeEditable;

-(void) unloadPaperState;

#pragma mark - Paths

-(NSString*) directoryPathForScrapUUID:(NSString*)uuid;

-(NSString*) bundledDirectoryPathForScrapUUID:(NSString*)uuid;

#pragma mark - Scrap Stealing

-(void) stealScrap:(NSString*)scrapUUID fromScrapCollectionState:(MMScrapCollectionState*)formerScrapOwner;

#pragma mark - Deleting Assets

-(void) deleteScrapWithUUID:(NSString*)scrapUUID shouldRespectOthers:(BOOL)respectOthers;

@end
