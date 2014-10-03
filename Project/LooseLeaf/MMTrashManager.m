//
//  MMTrashManager.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/26/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMTrashManager.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMImmutableScrapsOnPaperState.h"
#import "MMUndoablePaperView.h"
#import "MMPageCacheManager.h"
#import "MMExportablePaperView.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMScrapsInBezelContainerView.h"

@implementation MMTrashManager{
    dispatch_queue_t trashManagerQueue;
    NSFileManager* fileManager;
}

#pragma mark - Dispatch Queue

-(dispatch_queue_t) trashManagerQueue{
    if(!trashManagerQueue){
        trashManagerQueue = dispatch_queue_create("com.milestonemade.looseleaf.trashManagerQueue", DISPATCH_QUEUE_SERIAL);
    }
    return trashManagerQueue;
}

#pragma mark - Singleton

static MMTrashManager* _instance = nil;

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        _instance = self;
        fileManager = [[NSFileManager alloc] init];
    }
    return _instance;
}

+(MMTrashManager*) sharedInstance{
    if(!_instance){
        _instance = [[MMTrashManager alloc]init];
    }
    return _instance;
}


#pragma mark - Public Methods

-(void) deleteScrap:(NSString*)scrapUUID inPage:(MMUndoablePaperView*)page{
    [self deleteScrap:scrapUUID inPage:page shouldRespectUndoManager:YES];
}


-(void) deletePage:(MMExportablePaperView*)page{
    dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
    dispatch_async([self trashManagerQueue], ^{
        //
        // Step 1: ensure the page is in a stable saved state
        //         with no pending threads active
        while(page.hasEditsToSave){
            NSLog(@"deleting a page with active edits");
            dispatch_async(dispatch_get_main_queue(), ^{
                [page saveToDisk:^(BOOL didSaveEdits) {
                    dispatch_semaphore_signal(sema1);
                }];
            });
            dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
            [NSThread sleepForTimeInterval:5];
            NSLog(@"page was saved, still has edits? %d", page.hasEditsToSave);
        }
        // build some directories
        NSString* documentsPath = [NSFileManager documentsPath];
        NSString* allPagesPath = [documentsPath stringByAppendingPathComponent:@"Pages"];
        NSString* thisPagesPath = [allPagesPath stringByAppendingPathComponent:page.uuid];
        NSString* thisPagesScrapsPath = [thisPagesPath stringByAppendingPathComponent:@"Scraps"];

        //
        // Step 2: loop through all of the page's scraps and delete
        //         all that are not in the bezel.
        NSArray* thisPagesScrapsUUIDs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:thisPagesScrapsPath error:nil];
        for (NSString* scrapUUID in thisPagesScrapsUUIDs) {
            // delete the scrap, and do NOT respect the undo manager.
            // we can ignore the undo manager since we're just deleting
            // the page anyways.
            [self deleteScrap:scrapUUID inPage:page shouldRespectUndoManager:NO];
        }
        
        //
        // deleting scraps above will add blocks to the trashManagerQueue
        // for each scrap. So we need to add the rest of our logic
        // to run /after/ those scraps (if any) have been processed.
        dispatch_async([self trashManagerQueue], ^{
            //
            // Step 3: Transfer any remaining scraps to the bezel
            NSArray* thisPagesSavedScrapUUIDs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:thisPagesScrapsPath error:nil];
            NSLog(@"saved scraps for page %@ : %@", page.uuid, thisPagesSavedScrapUUIDs);
            
            id bcv = page.delegate.bezelContainerView;
            
            //
            // Step 4: Delete the rest of the page assets
            BOOL isDirectory = NO;
            if([[NSFileManager defaultManager] fileExistsAtPath:thisPagesPath isDirectory:&isDirectory] &&
               ![thisPagesPath isEqualToString:allPagesPath] && thisPagesPath.length > allPagesPath.length){
                if(isDirectory){
                    NSError* err = nil;
                    if([[NSFileManager defaultManager] removeItemAtPath:thisPagesPath error:&err]){
                        NSLog(@"deleted page at %@", thisPagesPath);
                    }
                    if(err){
                        NSLog(@"error deleting %@: %@", thisPagesPath, err);
                    }
                }else{
                    NSLog(@"found path, but it isn't a directory %@", thisPagesPath);
                }
            }else{
                NSLog(@"path to delete doesn't exist %@", thisPagesPath);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[MMPageCacheManager sharedInstance] pageWasDeleted:page];
            });
        });
    });
}



#pragma mark - Helper Methods

//
// @param scrapUUID attempt to delete the assets of this scrap in the input page, but only
//        if the scrap is unused in the bezel and the page's own undo manager (optionally)
// @param page the page who's scrap should be deleted
// @param respectUndoManager YES if we should keep scraps in the page's undoManager, NO if we should ignore the undo manager
//        (for instance, when deleting the page)
-(void) deleteScrap:(NSString*)scrapUUID inPage:(MMUndoablePaperView*)page shouldRespectUndoManager:(BOOL)respectUndoManager{

    if(!page || !scrapUUID){
        // sanity
        NSLog(@"can't delete scrap %@ from page %@", scrapUUID, page);
        return;
    }

    //
    // Step 1: check the bezel
    //
    // first check the bezel to see if the scrap exists outside the page
    if([page.delegate.bezelContainerView containsScrapUUID:scrapUUID]){
        NSLog(@"scrap %@ is in bezel, can't delete assets", scrapUUID);
        return;
    }
    
    // first, we need to check if we're even eligible to
    // delete the scrap or not.
    //
    // if the scrap is being held in the undo/redo manager
    // then we need to keep the scraps assets on disk.
    // otherwise we can delete them.
    BOOL(^checkScrapExistsInUndoRedoManager)() = ^{
        dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
        __block BOOL existsInUndoRedoManager = NO;
        dispatch_async([page serialBackgroundQueue], ^{
            BOOL needsLoad = ![page.undoRedoManager isLoaded];
            if(needsLoad){
                [page.undoRedoManager loadFrom:[page undoStatePath]];
            }
            existsInUndoRedoManager = [page.undoRedoManager containsItemForScrapUUID:scrapUUID];
            if(needsLoad){
                [page.undoRedoManager unloadState];
            }
            dispatch_semaphore_signal(sema1);
        });
        dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
        return existsInUndoRedoManager;
    };
    
    
    // we've been told to delete a scrap from disk.
    // so do this on our low priority background queue
    dispatch_async([self trashManagerQueue], ^{
        //
        // Step 2: check the undo manager for the page
        //         (optionally)
        if(respectUndoManager){
            // only check the undo manager if we were asked to.
            // we might ignore it if we're trying to delete
            // the page as well
            if(page && checkScrapExistsInUndoRedoManager()){
                // the scrap exists in the page's undo manager,
                // so don't bother deleting it
                NSLog(@"TrashManager found scrap in page's undo state. keeping files.");
                return;
            }
        }
        
        //
        // if we made it this far, then the scrap is not in the page's
        // undo manager, and it's not in the bezel, so it's safe to delete
        //
        // Step 3: delete from the page's state
        // now the scrap is off disk, so remove it from the page's state too
        // delete from the page's scrapsOnPaperState
        void(^removeFromScrapsOnPaperState)() = ^{
            [page.scrapsOnPaperState removeScrapWithUUID:scrapUUID];
            [[page.scrapsOnPaperState immutableStateForPath:page.scrapIDsPath] saveStateToDiskBlocking];
        };
        if([page.scrapsOnPaperState isStateLoaded]){
            removeFromScrapsOnPaperState();
        }else{
            [page performBlockForUnloadedScrapStateSynchronously:removeFromScrapsOnPaperState];
        }
        
        //
        // Step 4: delete the assets off disk
        // now that the scrap is out of the page's state, then
        // we can delete it off disk too
        NSString* documentsPath = [NSFileManager documentsPath];
        NSString* pagesPath = [[documentsPath stringByAppendingPathComponent:@"Pages"] stringByAppendingPathComponent:page.uuid];
        NSString* scrapPath = [[pagesPath stringByAppendingPathComponent:@"Scraps"] stringByAppendingPathComponent:scrapUUID];
        BOOL isDirectory = NO;
        if([[NSFileManager defaultManager] fileExistsAtPath:scrapPath isDirectory:&isDirectory]){
            if(isDirectory){
                NSError* err = nil;
                if([[NSFileManager defaultManager] removeItemAtPath:scrapPath error:&err]){
                    NSLog(@"deleted scrap at %@", scrapPath);
                }
                if(err){
                    NSLog(@"error deleting %@: %@", scrapPath, err);
                }
            }else{
                NSLog(@"found path, but it isn't a directory: %@", scrapPath);
            }
        }else{
            NSLog(@"path to delete doesn't exist %@", scrapPath);
        }
    });
}



@end
