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
#import "MMScrapSidebarContainerView.h"

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


#pragma mark - Delete Methods

-(void) deleteScrap:(NSString*)scrapUUID inPage:(MMUndoablePaperView*)page{
    //
    // first check the bezel to see if the scrap exists outside the page
    if([page.delegate.bezelContainerView containsScrapUUID:scrapUUID]){
        NSLog(@"scrap %@ is in bezel, can't delete assets", scrapUUID);
        return;
    }

    MMUndoablePaperView* undoablePage = nil;
    if([page isKindOfClass:[MMUndoablePaperView class]]){
        undoablePage = (MMUndoablePaperView*)page;
    }
    
    dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);

    // first, we need to check if we're even eligible to
    // delete the scrap or not.
    //
    // if the scrap is being held in the undo/redo manager
    // then we need to keep the scraps assets on disk.
    // otherwise we can delete them.
    BOOL(^checkScrapExistsInUndoRedoManager)() = ^{
        __block BOOL existsInUndoRedoManager = NO;
        dispatch_async([page serialBackgroundQueue], ^{
            BOOL needsLoad = ![undoablePage.undoRedoManager isLoaded];
            if(needsLoad){
                [undoablePage.undoRedoManager loadFrom:[undoablePage undoStatePath]];
            }
            existsInUndoRedoManager = [undoablePage.undoRedoManager containsItemForScrapUUID:scrapUUID];
            if(needsLoad){
                [undoablePage.undoRedoManager unloadState];
            }
            dispatch_semaphore_signal(sema1);
        });
        dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
        return existsInUndoRedoManager;
    };
    
    
    // we've been told to delete a scrap from disk.
    // so do this on our low priority background queue
    dispatch_async([self trashManagerQueue], ^{
        if(undoablePage && checkScrapExistsInUndoRedoManager()){
            // the scrap exists in the page's undo manager,
            // so don't bother deleting it
            NSLog(@"TrashManager found scrap in page's undo state. keeping files.");
            return;
        }
        
        // delete from the page's scrapsOnPaperState
        void(^removeFromScrapsOnPaperState)() = ^{
            [page.scrapsOnPaperState removeScrapWithUUID:scrapUUID];
            [[page.scrapsOnPaperState immutableStateForPath:page.scrapIDsPath] saveStateToDiskBlocking];
        };
        
        // now the scrap is off disk, so remove it from the page's state too
        if([page.scrapsOnPaperState isStateLoaded]){
            removeFromScrapsOnPaperState();
        }else{
            [page performBlockForUnloadedScrapStateSynchronously:removeFromScrapsOnPaperState];
        }

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
                    NSLog(@"deleted1 %@", scrapPath);
                }
                if(err){
                    NSLog(@"error deleting %@: %@", scrapPath, err);
                }
            }else{
//                NSLog(@"found path, but it isn't a directory");
            }
        }else{
//            NSLog(@"path to delete doesn't exist %@", scrapPath);
        }
    });
}


-(void) deletePage:(MMExportablePaperView*)page{
    dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
    dispatch_async([self trashManagerQueue], ^{
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

        // now that the scrap is out of the page's state, then
        // we can delete it off disk too
        NSString* documentsPath = [NSFileManager documentsPath];
        NSString* pagesDirectory = [documentsPath stringByAppendingPathComponent:@"Pages"];
        NSString* pagesPath = [pagesDirectory stringByAppendingPathComponent:page.uuid];
        BOOL isDirectory = NO;
        if([[NSFileManager defaultManager] fileExistsAtPath:pagesPath isDirectory:&isDirectory] &&
           ![pagesPath isEqualToString:pagesDirectory] && pagesPath.length > pagesDirectory.length){
            if(isDirectory){
                NSError* err = nil;
                if([[NSFileManager defaultManager] removeItemAtPath:pagesPath error:&err]){
                    NSLog(@"deleted2 %@", pagesPath);
                }
                if(err){
                    NSLog(@"error deleting %@: %@", pagesPath, err);
                }
            }else{
                //                NSLog(@"found path, but it isn't a directory");
            }
        }else{
            //            NSLog(@"path to delete doesn't exist %@", scrapPath);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MMPageCacheManager sharedInstance] pageWasDeleted:page];
        });
    });
}

@end
