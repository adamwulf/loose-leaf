//
//  MMScrapCollectionState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/3/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapCollectionState.h"
#import "MMScrapView.h"
#import "NSThread+BlockAdditions.h"
#import "Constants.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMImmutableScrapCollectionState.h"


@implementation MMScrapCollectionState {
    NSMutableArray<NSBlockOperation*>* blocksToRunAfterLoad;
}

@synthesize allLoadedScraps;
@synthesize lastSavedUndoHash;
@synthesize isForgetful;
@synthesize isLoading;

static dispatch_queue_t importExportStateQueue;

static const void* const kImportExportStateQueueIdentifier = &kImportExportStateQueueIdentifier;

+ (dispatch_queue_t)importExportStateQueue {
    if (!importExportStateQueue) {
        importExportStateQueue = dispatch_queue_create("com.milestonemade.looseleaf.scraps.importExportStateQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(importExportStateQueue, kImportExportStateQueueIdentifier, (void*)kImportExportStateQueueIdentifier, NULL);
    }
    return importExportStateQueue;
}
+ (BOOL)isImportExportStateQueue {
    return dispatch_get_specific(kImportExportStateQueueIdentifier) != NULL;
}


- (id)init {
    if (self = [super init]) {
        expectedUndoHash = 0;
        lastSavedUndoHash = 0;
        allLoadedScraps = [NSMutableArray array];
        // initialize our target state
        targetLoadedState = MMScrapCollectionStateTargetUnloaded;
        blocksToRunAfterLoad = [NSMutableArray array];
    }
    return self;
}

@synthesize delegate;

#pragma mark - Properties

- (BOOL)hasEditsToSave {
    return !isForgetful && isLoaded && (hasEditsToSave || expectedUndoHash != lastSavedUndoHash);
}

- (NSUInteger)lastSavedUndoHash {
    @synchronized(self) {
        return lastSavedUndoHash;
    }
}

- (NSUInteger)countOfAllLoadedScraps {
    @synchronized(allLoadedScraps) {
        return [allLoadedScraps count];
    }
}

#pragma mark - Manage Scraps

- (void)scrapVisibilityWasUpdated:(MMScrapView*)scrap {
    @throw kAbstractMethodException;
}

- (MMScrapView*)scrapForUUID:(NSString*)uuid {
    @synchronized(allLoadedScraps) {
        for (MMScrapView* scrap in allLoadedScraps) {
            if ([scrap.uuid isEqualToString:uuid]) {
                return scrap;
            }
        }
    }
    return nil;
}

#pragma mark - Save and Load

- (MMImmutableScrapCollectionState*)immutableStateForPath:(NSString*)scrapIDsPath {
    @throw kAbstractMethodException;
}

- (BOOL)isStateLoaded {
    @synchronized(self) {
        return isLoaded;
    }
}

- (void)setIsLoading:(BOOL)_isLoading {
    if (isLoading != _isLoading) {
        isLoading = _isLoading;

        if (!isLoading) {
            @synchronized(blocksToRunAfterLoad) {
                for (NSBlockOperation* operation in blocksToRunAfterLoad) {
                    [operation start];
                }
                [blocksToRunAfterLoad removeAllObjects];
            }
        }
    }
}

- (void)runBlockWhenLoaded:(void (^)())block {
    if ([self isLoading]) {
        @synchronized(blocksToRunAfterLoad) {
            [blocksToRunAfterLoad addObject:[NSBlockOperation blockOperationWithBlock:block]];
        }
    } else {
        block();
    }
}

- (BOOL)isCollectionStateLoading {
    @synchronized(self) {
        return isLoading;
    }
}

- (void)wasSavedAtUndoHash:(NSUInteger)savedUndoHash {
    @synchronized(self) {
        lastSavedUndoHash = savedUndoHash;
    }
}

- (void)loadStateAsynchronously:(BOOL)async atPath:(NSString*)scrapIDsPath andMakeEditable:(BOOL)makeEditable andAdjustForScale:(BOOL)adjustForScale {
    @throw kAbstractMethodException;
}

- (void)unloadPaperState {
    CheckThreadMatches([MMScrapCollectionState isImportExportStateQueue]);
    if ([self hasEditsToSave]) {
        @throw [NSException exceptionWithName:@"StateInconsistentException" reason:@"Unloading ScrapCollectionState with edits pending save." userInfo:nil];
    }
    if ([self isStateLoaded] || isLoading) {
        @synchronized(self) {
            isUnloading = YES;
            targetLoadedState = MMScrapCollectionStateTargetUnloaded;
        }
        dispatch_async([MMScrapCollectionState importExportStateQueue], ^(void) {
            @autoreleasepool {
                @synchronized(self) {
                    if (targetLoadedState != MMScrapCollectionStateTargetUnloaded) {
                        DebugLog(@"MMScrapCollectionState: target load state is not to unload. bailing on unload early");
                    }
                }
                if ([self isStateLoaded]) {
                    NSArray* scrapsToUnload = nil;
                    @synchronized(allLoadedScraps) {
                        scrapsToUnload = [allLoadedScraps copy];
                        [allLoadedScraps removeAllObjects];
                    }
                    NSMutableArray* unloadedVisibleScraps = [NSMutableArray array];
                    for (MMScrapView* scrap in scrapsToUnload) {
                        if ([delegate scrapForUUIDIfAlreadyExistsInOtherContainer:scrap.uuid]) {
                            // if this is true, then the scrap is being held
                            // by the sidebar, so we shouldn't manage its
                            // state
                            //                                DebugLog(@"skipping unloading: %@", scrap.uuid);
                        } else {
                            [scrap unloadState];
                            [unloadedVisibleScraps addObject:scrap];
                        }
                    }
                    [NSThread performBlockOnMainThread:^{
                        for (MMScrapView* visibleScrap in unloadedVisibleScraps) {
                            // only remove unloaded scraps from their superview.
                            // all others are held by gestures / bezel
                            [visibleScrap removeFromSuperview];
                        }
                        [self.delegate didUnloadAllScrapsFor:self];
                    }];

                    @synchronized(self) {
                        isLoaded = NO;
                        isUnloading = NO;
                        expectedUndoHash = 0;
                        lastSavedUndoHash = 0;
                    }
                } else {
                    @synchronized(self) {
                        isUnloading = NO;
                    }
                }
            }
        });
    }
}

#pragma mark - Paths

- (NSString*)directoryPathForScrapUUID:(NSString*)uuid {
    @throw kAbstractMethodException;
}

- (NSString*)bundledDirectoryPathForScrapUUID:(NSString*)uuid {
    @throw kAbstractMethodException;
}


#pragma mark - Scrap Stealing

- (void)stealScrap:(NSString*)scrapUUID fromScrapCollectionState:(MMScrapCollectionState*)formerScrapCollectionState {
    DebugLog(@"bezel is stealing a scrap %@", scrapUUID);
    MMScrapView* scrapToOwn = nil;
    @synchronized(allLoadedScraps) {
        for (MMScrapView* loadedScrap in allLoadedScraps) {
            if ([loadedScrap.uuid isEqualToString:scrapUUID]) {
                scrapToOwn = loadedScrap;
                break;
            };
        }
    }
    if (!scrapToOwn) {
        @throw [NSException exceptionWithName:@"InvalidScrapUUIDException" reason:@"Bezel cannot steal scrap it doesn't contain" userInfo:nil];
    }

    // we found the scrap to steal, so that means
    // we have edits
    hasEditsToSave = YES;

    //
    // this needs to be synchronous, because we will be stealing scraps
    // during the trash queue. if we async, then the trash will delete the
    // files before we even get a chance to steal them.
    //
    // ok, at this point we have the state + formerstate + scrap.
    // first things first, lets move the files to our state
    dispatch_sync([MMScrapCollectionState importExportStateQueue], ^{
        // all of our state changes need to be done in our own queue
        if (scrapToOwn.state.isScrapStateLoaded || scrapToOwn.state.isScrapStateLoading) {
            @throw [NSException exceptionWithName:@"ChangingScrapOwnershipException" reason:@"Cannot change ownership of loaded scrap" userInfo:nil];
        }

        scrapToOwn.state.scrapsOnPaperState = self;

        NSString* directoryOfScrap = [formerScrapCollectionState directoryPathForScrapUUID:scrapUUID];
        NSString* bundledDirectoryOfScrap = [formerScrapCollectionState bundledDirectoryPathForScrapUUID:scrapUUID];

        NSMutableArray* directoryContents = [[NSFileManager defaultManager] recursiveContentsOfDirectoryAtPath:directoryOfScrap filesOnly:YES].mutableCopy;
        NSMutableArray* bundledContents = [[NSFileManager defaultManager] recursiveContentsOfDirectoryAtPath:bundledDirectoryOfScrap filesOnly:YES].mutableCopy;
        [bundledContents removeObjectsInArray:directoryContents];

        DebugLog(@"Need to copy these assets to the bezel:");
        DebugLog(@"  from bundled dir: %@", bundledContents);
        DebugLog(@"  from page's dir: %@", directoryContents);


        NSString* scrapLocationInBezel = [self directoryPathForScrapUUID:scrapUUID];
        [NSFileManager ensureDirectoryExistsAtPath:scrapLocationInBezel];

        void (^moveFileIntoBezel)(NSString*, NSString*) = ^(NSString* originalDir, NSString* path) {
            NSError* err = nil;
            [[NSFileManager defaultManager] moveItemAtPath:[originalDir stringByAppendingPathComponent:path]
                                                    toPath:[scrapLocationInBezel stringByAppendingPathComponent:path]
                                                     error:&err];
            if (!err) {
                DebugLog(@"moved %@ into %@", path, scrapLocationInBezel);
            } else {
                DebugLog(@"error copying scrap %@", err);
            }

        };

        for (NSString* path in bundledContents) {
            moveFileIntoBezel(bundledDirectoryOfScrap, path);
        }
        for (NSString* path in directoryContents) {
            moveFileIntoBezel(directoryOfScrap, path);
        }

        // remove the old scrap directory
        NSError* err = nil;
        [[NSFileManager defaultManager] removeItemAtPath:directoryOfScrap error:&err];
        if (!err) {
            DebugLog(@"deleted: %@", directoryOfScrap);
        } else {
            DebugLog(@"error deleting directory %@ scrap %@", directoryOfScrap, err);
        }


        [NSThread performBlockOnMainThread:^{
            // now reload the background view from
            // the file that's in the new location
            [scrapToOwn.state reloadBackgroundView];
        }];

        DebugLog(@"done moving scrap files.");
    });
}

#pragma mark - Deleting Assets

- (void)deleteScrapWithUUID:(NSString*)scrapUUID shouldRespectOthers:(BOOL)respectOthers {
    @throw kAbstractMethodException;
}

@end
