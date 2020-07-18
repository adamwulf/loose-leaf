//
//  MMExportablePaperView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/28/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMExportablePaperView.h"
#import "MMEditablePaperViewSubclass.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "NSString+UUID.h"
#import <ZipArchive/ZipArchive.h>
#import "MMTrashManager.h"
#import "MMScrapsInBezelContainerView.h"
#import "MMImmutableScrapsOnPaperState.h"
#import "MMSingleStackManager.h"
#import "Mixpanel.h"


@implementation MMExportablePaperView {
    BOOL isCurrentlyExporting;
    BOOL isCurrentlySaving;
    BOOL waitingForExport;
    BOOL waitingForSave;
    BOOL waitingForUnload;
}

@synthesize isCurrentlySaving;

- (void)moveAssetsFrom:(id<MMPaperViewDelegate>)previousDelegate {
    [super moveAssetsFrom:previousDelegate];

    NSString* previousDirectory = [MMEditablePaperView pagesPathForStackUUID:previousDelegate.stackManager.uuid andPageUUID:[self uuid]];
    NSString* newDirectory = [MMEditablePaperView pagesPathForStackUUID:self.delegate.stackManager.uuid andPageUUID:[self uuid]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:previousDirectory] && ![previousDirectory isEqualToString:newDirectory]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:newDirectory]) {
            // Yikes! We should never have the same page UUID directory in two places
            [[NSFileManager defaultManager] removeItemAtPath:newDirectory error:nil];
#ifdef DEBUG
            @throw [NSException exceptionWithName:@"DuplicateUUIDDirectoryException" reason:@"A page UUID should never have two directories" userInfo:nil];
#endif
        }

        NSError* err;
        [[NSFileManager defaultManager] moveItemAtPath:previousDirectory toPath:newDirectory error:&err];

        if (err) {
            [[Mixpanel sharedInstance] track:kMPEventCrashAverted properties:@{ @"Error": [err description] }];
#ifdef DEBUG
            @throw [NSException exceptionWithName:@"MoveDirectoryException" reason:[err description] userInfo:nil];
#endif
        }

        if ([[NSFileManager defaultManager] fileExistsAtPath:previousDirectory] || ![[NSFileManager defaultManager] fileExistsAtPath:newDirectory]) {
#ifdef DEBUG
            @throw [NSException exceptionWithName:@"MoveDirectoryException" reason:@"The move did not complete properly" userInfo:nil];
#endif
        }
    }
}

#pragma mark - Retry Saving, Exporting, and Unloading

- (void)retrySaveOrExport {
    if (waitingForSave) {
        __block __strong MMExportablePaperView* strongSelf = self;
        [[MMMainOperationQueue sharedQueue] addOperationWithBlock:^{
            @autoreleasepool {
                if (isCurrentlySaving == YES) {
                    // already saving. will need to wait for a save
                } else {
                    [strongSelf saveToDisk:^(BOOL didSaveEdits) {
                        if ([self hasEditsToSave]) {
                            // save failed, try again
                            waitingForSave = YES;
                            [strongSelf retrySaveOrExport];
                        }
                    }];
                }
                strongSelf = nil;
            }
        }];
    } else if (waitingForExport) {
        [self exportAsynchronouslyToZipFile];
    } else if (waitingForUnload) {
        [[MMMainOperationQueue sharedQueue] addOperationWithBlock:^{
            @autoreleasepool {
                [self unloadState];
            }
        }];
    }
}


#pragma mark - Saving

- (void)saveToDisk:(void (^)(BOOL didSaveEdits))onComplete {
    @synchronized(self) {
        if (isCurrentlySaving || isCurrentlyExporting) {
            waitingForSave = YES;
            if (onComplete)
                onComplete(YES);
            return;
        }
        isCurrentlySaving = YES;
        waitingForSave = NO;
    }
    [super saveToDisk:^(BOOL didSaveEdits) {
        if (onComplete)
            onComplete(didSaveEdits);
    }];
}

- (void)saveToDiskHelper:(void (^)(BOOL))onComplete {
    __block __strong MMExportablePaperView* strongSelf = self;
    [super saveToDiskHelper:^(BOOL hadEditsToSave) {
        @synchronized(self) {
            isCurrentlySaving = NO;
            [strongSelf retrySaveOrExport];
            strongSelf = nil;
        }
        if (onComplete)
            onComplete(hadEditsToSave);
    }];
}

#pragma mark - Unload State Listener

- (void)setDidUnloadState:(void (^)())didUnloadState {
    if ([self isStateLoaded] && didUnloadState) {
        _didUnloadState = didUnloadState;
    } else if (didUnloadState) {
        didUnloadState();
    }
}

#pragma mark - JotViewStateProxyDelegate

- (void)didUnloadState:(JotViewStateProxy*)state {
    [super didUnloadState:state];
    if (_didUnloadState) {
        _didUnloadState();
        _didUnloadState = nil;
    }
}

#pragma mark - Load and Unload

- (void)loadStateAsynchronously:(BOOL)async withSize:(CGSize)pagePixelSize andScale:(CGFloat)scale andContext:(JotGLContext*)context {
    @synchronized(self) {
        if (waitingForUnload) {
            // if we're waiting for an unload, but have since
            // been asked to load, then cancel waiting
            waitingForUnload = NO;
        }
    }
    [super loadStateAsynchronously:async withSize:pagePixelSize andScale:scale andContext:context];
}

- (void)unloadState {
    @synchronized(self) {
        if (isCurrentlyExporting || isCurrentlySaving) {
            waitingForUnload = YES;
            return;
        }
        DebugLog(@"MMExportablePaperView: saved unloading during save/export");
        waitingForUnload = NO;
    }
    [super unloadState];
}


#pragma mark - Export

- (void)exportAsynchronouslyToZipFile {
    @synchronized(self) {
        [[JotDiskAssetManager sharedManager] blockUntilCompletedForDirectory:[self pagesPath]];
        if (isCurrentlySaving || isCurrentlyExporting) {
            waitingForExport = YES;
            return;
        }
        isCurrentlyExporting = YES;
        waitingForExport = NO;
    }
    if ([self hasEditsToSave]) {
        @synchronized(self) {
            // welp, we can't export yet, we need
            // to save first. so set that we're waiting
            // and save immediately
            isCurrentlyExporting = NO;
            waitingForExport = YES;
        }
        DebugLog(@"saved exporing while save is still needed");
        [self saveToDisk:nil];
        return;
    }

    dispatch_async([self serialBackgroundQueue], ^{
        @autoreleasepool {
            NSString* generatedZipFile = [self generateZipFile];
            @synchronized(self) {
                isCurrentlyExporting = NO;
                if (generatedZipFile) {
                    [self.delegate didExportPage:self toZipLocation:generatedZipFile];
                } else {
                    [self.delegate didFailToExportPage:self];
                }
                [self retrySaveOrExport];
            }
        }
    });
}


- (NSString*)generateZipFile {
    NSString* pathOfPageFiles = [self pagesPath];

    NSUInteger hash1 = self.paperState.lastSavedUndoHash;
    NSUInteger hash2 = self.scrapsOnPaperState.lastSavedUndoHash;
    NSString* zipFileName = [NSString stringWithFormat:@"%@%lu%lu.zip", self.uuid, (unsigned long)hash1, (unsigned long)hash2];

    NSString* fullPathToZip = [NSTemporaryDirectory() stringByAppendingPathComponent:zipFileName];

    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPathToZip]) {
        NSString* fullPathToTempZip = [fullPathToZip stringByAppendingPathExtension:@"temp"];
        // make sure temp file is deleted
        [[NSFileManager defaultManager] removeItemAtPath:fullPathToTempZip error:nil];

        NSMutableArray* directoryContents = [[NSFileManager defaultManager] recursiveContentsOfDirectoryAtPath:pathOfPageFiles filesOnly:YES].mutableCopy;
        NSMutableArray* bundledContents = [[NSFileManager defaultManager] recursiveContentsOfDirectoryAtPath:[self bundledPagesPath] filesOnly:YES].mutableCopy;

        [bundledContents removeObjectsInArray:directoryContents];
        DebugLog(@"generating zip file for path %@", pathOfPageFiles);
        DebugLog(@"contents of path %d vs %d", (int)[directoryContents count], (int)[bundledContents count]);


        // find all scrap ids that are on the page vs just in our undo history
        NSDictionary* scrapInfo = [NSDictionary dictionaryWithContentsOfFile:[self scrapIDsPath]];
        NSString* locationOfUpdatedScrapInfo = nil;

        if (scrapInfo) {
            NSArray* allScrapIDsOnPage = [scrapInfo objectForKey:@"scrapsOnPageIDs"];

            // make sure to filter out scraps that are in our undo history.
            typedef BOOL (^FilterBlock)(id evaluatedObject, NSDictionary* bindings);
            FilterBlock (^filter)(NSString* basePath) = ^(NSString* basePath) {
                return ^BOOL(id evaluatedObject, NSDictionary* bindings) {
                    if ([evaluatedObject hasSuffix:@"sender.plist"]) {
                        // don't include sender information
                        return NO;
                    } else if ([evaluatedObject hasSuffix:@"undoRedo.plist"]) {
                        // don't include undo redo
                        return NO;
                    } else if ([evaluatedObject hasPrefix:@"Scraps/"]) {
                        // ensure the id is in the allowed scraps
                        NSString* scrapID = [evaluatedObject substringFromIndex:@"Scraps/".length];
                        if ([scrapID containsString:@"/"]) {
                            scrapID = [scrapID substringToIndex:[scrapID rangeOfString:@"/"].location];
                            if ([allScrapIDsOnPage containsObject:scrapID]) {
                                // noop, the scrap is good to go
                            } else {
                                // this scrap isn't visible, so filter it out
                                return NO;
                            }
                        }
                    }
                    return YES;
                };
            };
            [directoryContents filterUsingPredicate:[NSPredicate predicateWithBlock:filter(pathOfPageFiles)]];
            [bundledContents filterUsingPredicate:[NSPredicate predicateWithBlock:filter([self bundledPagesPath])]];

            NSArray* scrapProperties = [scrapInfo objectForKey:@"allScrapProperties"];
            scrapProperties = [scrapProperties filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bindings) {
                return [allScrapIDsOnPage containsObject:[evaluatedObject objectForKey:@"uuid"]];
            }]];

            NSDictionary* updatedScrapPlist = @{ @"allScrapProperties": scrapProperties,
                                                 @"scrapsOnPageIDs": allScrapIDsOnPage };

            locationOfUpdatedScrapInfo = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString createStringUUID]];
            [updatedScrapPlist writeToFile:locationOfUpdatedScrapInfo atomically:YES];
        }

        ZipArchive* zip = [[ZipArchive alloc] init];
        if ([zip createZipFileAt:fullPathToTempZip]) {
            for (int filesSoFar = 0; filesSoFar < [directoryContents count]; filesSoFar++) {
                NSString* aFileInPage = [directoryContents objectAtIndex:filesSoFar];
                NSString* fullPathOfFile = [pathOfPageFiles stringByAppendingPathComponent:aFileInPage];
                if ([aFileInPage isEqualToString:@"scrapIDs.plist"] && locationOfUpdatedScrapInfo) {
                    fullPathOfFile = locationOfUpdatedScrapInfo;
                }
                if ([zip addFileToZip:fullPathOfFile
                          toPathInZip:aFileInPage]) {
                } else {
                    DebugLog(@"error for path: %@", aFileInPage);
                }
                CGFloat percentSoFar = ((CGFloat)filesSoFar / ([directoryContents count] + [bundledContents count]));
                [self.delegate isExportingPage:self withPercentage:percentSoFar toZipLocation:fullPathToZip];
            }
            for (int filesSoFar = 0; filesSoFar < [bundledContents count]; filesSoFar++) {
                NSString* aFileInPage = [bundledContents objectAtIndex:filesSoFar];
                NSString* fullPathOfFile = [[self bundledPagesPath] stringByAppendingPathComponent:aFileInPage];
                if ([aFileInPage isEqualToString:@"scrapIDs.plist"] && locationOfUpdatedScrapInfo) {
                    fullPathOfFile = locationOfUpdatedScrapInfo;
                }
                if ([zip addFileToZip:fullPathOfFile
                          toPathInZip:aFileInPage]) {
                } else {
                    DebugLog(@"error for path: %@", aFileInPage);
                }
                CGFloat percentSoFar = ((CGFloat)filesSoFar / ([directoryContents count] + [bundledContents count]));
                [self.delegate isExportingPage:self withPercentage:percentSoFar toZipLocation:fullPathToZip];
            }
            if ([directoryContents count] + [bundledContents count] == 0) {
                // page is entirely blank
                // send an empty file in the zip
                NSString* emptyFilename = [NSTemporaryDirectory() stringByAppendingPathComponent:@"empty"];
                [@"" writeToFile:emptyFilename atomically:YES encoding:NSUTF8StringEncoding error:nil];
                [zip addFileToZip:emptyFilename toPathInZip:@"empty"];
            }
            [zip closeZipFile];
        }

        if (![[NSFileManager defaultManager] fileExistsAtPath:fullPathToTempZip]) {
            // file wasn't created
            return nil;
        } else {
            DebugLog(@"success? file generated at %@", fullPathToTempZip);
            NSDictionary* attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPathToTempZip error:nil];
            if (attribs) {
                DebugLog(@"zip file is %@", [NSByteCountFormatter stringFromByteCount:[attribs fileSize] countStyle:NSByteCountFormatterCountStyleFile]);
            }


            DebugLog(@"validating zip file");
            zip = [[ZipArchive alloc] init];
            [zip unzipOpenFile:fullPathToTempZip];
            NSArray* contents = [zip contentsOfZipFile];
            [zip unzipCloseFile];

            NSInteger expectedContentsCount = [directoryContents count] + [bundledContents count];
            if (expectedContentsCount == 0)
                expectedContentsCount = 1;
            if ([contents count] > 0 && [contents count] == expectedContentsCount) {
                DebugLog(@"valid zip file, contents: %d", (int)[contents count]);
                [[NSFileManager defaultManager] moveItemAtPath:fullPathToTempZip toPath:fullPathToZip error:nil];
            } else {
                DebugLog(@"invalid zip file: %@ vs %@", contents, directoryContents);
                [[NSFileManager defaultManager] removeItemAtPath:fullPathToTempZip error:nil];
                return nil;
            }
        }
    } else {
        DebugLog(@"success? file already exists at %@", fullPathToZip);
        NSDictionary* attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPathToZip error:nil];
        if (attribs) {
            DebugLog(@"zip file is %@", [NSByteCountFormatter stringFromByteCount:[attribs fileSize] countStyle:NSByteCountFormatterCountStyleFile]);
        }
        DebugLog(@"validating...");
        ZipArchive* zip = [[ZipArchive alloc] init];
        if ([zip unzipOpenFile:fullPathToZip]) {
            DebugLog(@"valid");
            [zip closeZipFile];
        } else {
            DebugLog(@"invalid");
            [[NSFileManager defaultManager] removeItemAtPath:fullPathToZip error:nil];
            return nil;
        }
    }


    /*
    
    DebugLog(@"contents of zip: %@", contents);
    
    
    
    DebugLog(@"unzipping file");
    
    NSString* unzipTargetDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"safeDir"];
    
    zip = [[ZipArchive alloc] init];
    [zip unzipOpenFile:fullPathToZip];
    [zip unzipFileTo:unzipTargetDirectory overWrite:YES];
    [zip unzipCloseFile];
    
    
    directoryContents = [[NSFileManager defaultManager] recursiveContentsOfDirectoryAtPath:unzipTargetDirectory filesOnly:YES];
    DebugLog(@"unzipped: %@", directoryContents);
    */

    return fullPathToZip;
}

#pragma mark - Delete

- (void)deleteScrapWithUUID:(NSString*)scrapUUID shouldRespectOthers:(BOOL)respectOthers {
    //    DebugLog(@"page %@ asked to delete scrap %@ with respect? %d", self.uuid, scrapUUID, respectOthers);

    //
    // Step 1: check the bezel
    //
    // first check the bezel to see if the scrap exists outside the page
    BOOL (^checkScrapExistsInBezel)() = ^{
        if ([self.delegate.bezelContainerView containsViewUUID:scrapUUID]) {
            DebugLog(@"scrap %@ is in bezel, can't delete assets", scrapUUID);
            return YES;
        }
        return NO;
    };

    // first, we need to check if we're even eligible to
    // delete the scrap or not.
    //
    // if the scrap is being held in the undo/redo manager
    // then we need to keep the scraps assets on disk.
    // otherwise we can delete them.
    BOOL (^checkScrapExistsInUndoRedoManager)() = ^{
        dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
        __block BOOL existsInUndoRedoManager = NO;
        dispatch_async([self serialBackgroundQueue], ^{
            @autoreleasepool {
                BOOL needsLoad = ![self.undoRedoManager isLoaded];
                if (needsLoad) {
                    [self.undoRedoManager loadFrom:[self undoStatePath]];
                }
                existsInUndoRedoManager = [self.undoRedoManager containsItemForScrapUUID:scrapUUID];
                if (needsLoad) {
                    [self.undoRedoManager unloadState];
                }
            }
            dispatch_semaphore_signal(sema1);
        });
        dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
        return existsInUndoRedoManager;
    };


    // next, we need to check if the scrap is still on the
    // actual page. it may have been moved to bezel =>
    // then back again, which could trigger a request
    // to delete after some additional edits
    BOOL (^checkScrapExistsOnItsPage)() = ^{
        dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
        __block BOOL existsOnItsPage = NO;
        dispatch_async([self serialBackgroundQueue], ^{
            @autoreleasepool {
                if ([self isStateLoaded]) {
                    //                    DebugLog(@"only check this if our state is loaded");
                    existsOnItsPage = [[self.scrapsOnPaper filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bindings) {
                        return [[evaluatedObject uuid] isEqualToString:scrapUUID];
                    }]] count] > 0;
                }
            }
            dispatch_semaphore_signal(sema1);
        });
        dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
        return existsOnItsPage;
    };


    // we've been told to delete a scrap from disk.
    // so do this on our low priority background queue
    dispatch_async([[MMTrashManager sharedInstance] trashManagerQueue], ^{
        @autoreleasepool {
            //
            // Step 2: check the undo manager for the page
            //         (optionally)
            if (respectOthers) {
                // only check the undo manager if we were asked to.
                // we might ignore it if we're trying to delete
                // the page as well
                if (checkScrapExistsInUndoRedoManager()) {
                    // the scrap exists in the page's undo manager,
                    // so don't bother deleting it
                    //                DebugLog(@"TrashManager found scrap in page's undo state. keeping files.");
                    return;
                }
                // now double check if its on the page
                if (checkScrapExistsOnItsPage()) {
                    // yep, its still on the page, just nothing in the
                    // undo manager specifically about this scrap
                    return;
                }
            }

            if (checkScrapExistsInBezel()) {
                // scrap exists in the bezel, but not
                // in the actual page. so we should move
                // its assets into the bezel so that
                // its not loaded with the page
                DebugLog(@"scrap in bezel only, should move assets into bezel ownership");
                // synchronous, so that the files will be gone
                // from our page by the time this returns
                [self.scrapsOnPaperState removeScrapWithUUID:scrapUUID];
                [self.delegate.bezelContainerView.sidebarScrapState stealScrap:scrapUUID fromScrapCollectionState:self.scrapsOnPaperState];
                NSObject<MMPaperViewDelegate>* pageOriginalDelegate = self.delegate;
                [[MMMainOperationQueue sharedQueue] addOperationWithBlock:^{
                    [pageOriginalDelegate.bezelContainerView saveScrapContainerToDisk];
                    [self saveToDisk:nil];
                }];
                return;
            }

            __block MMScrapView* scrapThatIsBeingDeleted = nil;
            @autoreleasepool {
                //
                // if we made it this far, then the scrap is not in the page's
                // undo manager, and it's not in the bezel, so it's safe to delete
                //
                // Step 3: delete from the page's state
                // now the scrap is off disk, so remove it from the page's state too
                // delete from the page's scrapsOnPaperState
                void (^removeFromScrapsOnPaperState)() = ^{
                    CheckThreadMatches([MMScrapCollectionState isImportExportStateQueue]);
                    @autoreleasepool {
                        scrapThatIsBeingDeleted = [self.scrapsOnPaperState removeScrapWithUUID:scrapUUID];
                        if (respectOthers) {
                            // we only need to save the page's state back to disk
                            // if we respect that page's state at all. if we don't
                            // (it's being deleted anyways), then we can skip it.
                            //
                            // now wait for the save + all blocks to complete
                            // and ensure no pending saves
                            //                            [[self.scrapsOnPaperState immutableStateForPath:self.scrapIDsPath] saveStateToDiskBlocking];
                        } else {
                            //                    DebugLog(@"disrespect to page state saves time");
                        }
                    }
                };
                if ([self.scrapsOnPaperState isStateLoaded]) {
                    //
                    // if the state is already loaded, then we shouldn't force save it
                    // to disk, b/c it'll be saving to disk anyways, we should ask it
                    // to save to disk async
                    dispatch_sync([MMScrapCollectionState importExportStateQueue], removeFromScrapsOnPaperState);
                } else {
                    [self performBlockForUnloadedScrapStateSynchronously:^{
                        dispatch_sync([MMScrapCollectionState importExportStateQueue], removeFromScrapsOnPaperState);
                    } andImmediatelyUnloadState:YES andSavePaperState:respectOthers];
                }
                //
                // now that we've edited the scrap state
                // of the page, we need to save it to disk
                // if we respect it
                if (respectOthers) {
                    dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
                    [[MMMainOperationQueue sharedQueue] addOperationWithBlock:^{
                        [self saveToDisk:^(BOOL didSaveEdits) {
                            dispatch_semaphore_signal(sema1);
                        }];
                    }];
                    dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
                }
            }


            //
            // Step 4: remove former owner ScrapsOnPaperState
            dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
            [[MMMainOperationQueue sharedQueue] addOperationWithBlock:^{
                @autoreleasepool {
                    // we need to remove the scraps on paper state delegate,
                    // otherwise it will recieve notifiactions when this
                    // scrap changes superview (as we throw it away) which
                    // would incorrectly mark the page as hasEdits
                    scrapThatIsBeingDeleted.state.scrapsOnPaperState = nil;
                    // now, without the paper state, we can remove it
                    // from the UI safely
                    if (scrapThatIsBeingDeleted.superview) {
                        [scrapThatIsBeingDeleted removeFromSuperview];
                    }
                }
                dispatch_semaphore_signal(sema1);
            }];
            dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);


            //
            // Step 5: make sure the scrap has fully loaded from disk
            // and that it's fully saved to disk, or alternatively,
            // that it is already 100% unloaded
            while (scrapThatIsBeingDeleted.state.hasEditsToSave || scrapThatIsBeingDeleted.state.isScrapStateLoading) {
                if (scrapThatIsBeingDeleted.state.hasEditsToSave) {
                    [[MMMainOperationQueue sharedQueue] addOperationWithBlock:^{
                        @autoreleasepool {
                            if (scrapThatIsBeingDeleted.state.hasEditsToSave) {
                                [scrapThatIsBeingDeleted saveScrapToDisk:^(BOOL hadEditsToSave) {
                                    dispatch_semaphore_signal(sema1);
                                }];
                            }
                        }
                    }];
                    dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
                } else if (scrapThatIsBeingDeleted.state.isScrapStateLoading) {
                    //                DebugLog(@"waiting for scrap to finish loading before deleting...");
                }
                [NSThread sleepForTimeInterval:1];
                if (scrapThatIsBeingDeleted.state.hasEditsToSave) {
                    //                DebugLog(@"scrap was saved, still has edits? %d", scrapThatIsBeingDeleted.state.hasEditsToSave);
                } else if (scrapThatIsBeingDeleted.state.isScrapStateLoading) {
                    //                DebugLog(@"scrap state is still loading");
                }
            }

            //
            // Step 6: delete the assets off disk
            // now that the scrap is out of the page's state, then
            // we can delete it off disk too
            NSString* scrapPath = [[self.pagesPath stringByAppendingPathComponent:@"Scraps"] stringByAppendingPathComponent:scrapUUID];
            BOOL isDirectory = NO;
            if ([[NSFileManager defaultManager] fileExistsAtPath:scrapPath isDirectory:&isDirectory]) {
                if (isDirectory) {
                    NSError* err = nil;
                    if ([[NSFileManager defaultManager] removeItemAtPath:scrapPath error:&err]) {
                        //                        DebugLog(@"deleted scrap %@", scrapUUID);
                    }
                    if (err) {
                        //                    DebugLog(@"error deleting %@: %@", scrapPath, err);
                    }
                } else {
                    //                DebugLog(@"found path, but it isn't a directory: %@", scrapPath);
                }
            } else {
                //            DebugLog(@"path to delete doesn't exist %@", scrapPath);
            }
        }
    });
}

@end
