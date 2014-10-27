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
#import "MMScrapViewState+Trash.h"
#import "MMExportablePaperView+Trash.h"


@implementation MMTrashManager{
    dispatch_queue_t trashManagerQueue;
    NSFileManager* fileManager;
}

#pragma mark - Dispatch Queue

static const void *const kTrashQueueIdentifier = &kTrashQueueIdentifier;

-(dispatch_queue_t) trashManagerQueue{
    if(!trashManagerQueue){
        trashManagerQueue = dispatch_queue_create("com.milestonemade.looseleaf.trashManagerQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(trashManagerQueue, kTrashQueueIdentifier, (void *)kTrashQueueIdentifier, NULL);
    }
    return trashManagerQueue;
}
+(BOOL) isTrashManagerQueue{
    return dispatch_get_specific(kTrashQueueIdentifier) != NULL;
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

-(void) deleteScrap:(NSString*)scrapUUID inScrapCollectionState:(MMScrapCollectionState*)scrapCollectionState{
    [self deleteScrap:scrapUUID inScrapCollectionState:scrapCollectionState shouldRespectOthers:YES];
}

-(void) deletePage:(MMExportablePaperView*)page{
    DebugLog(@"asking to delete %@", page.uuid);
    NSObject<MMPaperViewDelegate>* pageOriginalDelegate = page.delegate;
    page.delegate = nil;
    [[MMPageCacheManager sharedInstance] forgetAboutPage:page];
    [page forgetAllPendingEdits];
    dispatch_async([self trashManagerQueue], ^{
        @autoreleasepool {
            //
            // Step 1: ensure the page is in a stable saved state
            //         with no pending threads active
            dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
            
            while(page.hasEditsToSave || page.isStateLoading || page.isCurrentlySaving){
                if(page.hasEditsToSave){
                    //                DebugLog(@"deleting a page with active edits");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @autoreleasepool {
                            if(page.hasEditsToSave){
                                [page saveToDisk:^(BOOL didSaveEdits) {
                                    dispatch_semaphore_signal(sema1);
                                }];
                            }
                        }
                    });
                    dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
                }else if(page.isStateLoading){
                    //                DebugLog(@"waiting for page to finish loading before deleting...");
                }else if(page.isCurrentlySaving){
                    //                DebugLog(@"waiting for page to finish saving before deleting...");
                }
                [NSThread sleepForTimeInterval:.3];
                if([page hasEditsToSave]){
                    //                DebugLog(@"page was saved, still has edits? %d", page.hasEditsToSave);
                }else if([page isStateLoading]){
                    //                DebugLog(@"page state is still loading");
                }
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
                @autoreleasepool {
                    // delete the scrap, and do NOT respect the undo manager.
                    // we can ignore the undo manager since we're just deleting
                    // the page anyways.
                    if(![pageOriginalDelegate.bezelContainerView containsScrapUUID:scrapUUID]){
                        [self deleteScrap:scrapUUID inScrapCollectionState:page.scrapsOnPaperState shouldRespectOthers:NO];
                    }else{
                        // synchronous, so that the files will be gone
                        // from our page by the time this returns
                        [pageOriginalDelegate.bezelContainerView.sidebarScrapState stealScrap:scrapUUID fromScrapCollectionState:page.scrapsOnPaperState];
                    }
                }
            }
            [pageOriginalDelegate.bezelContainerView saveScrapContainerToDisk];
            
            //
            // deleting scraps above will add blocks to the trashManagerQueue
            // for each scrap. So we need to add the rest of our logic
            // to run /after/ those scraps (if any) have been processed.
            dispatch_async([self trashManagerQueue], ^{
                @autoreleasepool {
                    
                    //            DebugLog(@"page still has %d scraps", (int)[page.scrapsOnPaper count]);
                    //            DebugLog(@"page state still has %d scraps", (int)[page.scrapsOnPaperState countOfAllLoadedScraps]);
                    
                    //            NSString* contentsOfBezel = [[NSFileManager documentsPath] stringByAppendingPathComponent:@"Bezel/Scraps"];
                    
                    //
                    // Step 3: Transfer any remaining scraps to the bezel
                    NSArray* thisPagesSavedScrapUUIDs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:thisPagesScrapsPath error:nil];
                    //            NSArray* scrapsInBezelUUIDs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:contentsOfBezel error:nil];
                    //            DebugLog(@"saved scraps for page %@ : %@", page.uuid, thisPagesSavedScrapUUIDs);
                    //            DebugLog(@"saved scraps in bezel: %@", scrapsInBezelUUIDs);
                    
                    if([thisPagesSavedScrapUUIDs count]){
                        //                DebugLog(@"page wasn't able to delete all scraps.");
                    }
                    
                    // TODO: check the bezel to see if we should keep any scraps,
                    // and then give them to a safe place before deleting
                    // all the page assets
                    //            id bcv = pageOriginalDelegate.bezelContainerView;
                    
                    //
                    // Step 4: Delete the rest of the page assets
                    BOOL isDirectory = NO;
                    if([[NSFileManager defaultManager] fileExistsAtPath:thisPagesPath isDirectory:&isDirectory] &&
                       ![thisPagesPath isEqualToString:allPagesPath] && thisPagesPath.length > allPagesPath.length){
                        if(isDirectory){
                            NSError* err = nil;
                            if([[NSFileManager defaultManager] removeItemAtPath:thisPagesPath error:&err]){
                                //                        DebugLog(@"deleted page at %@", thisPagesPath);
                                DebugLog(@"deleted page %@", page.uuid);
                            }
                            if(err){
                                //                        DebugLog(@"error deleting %@: %@", thisPagesPath, err);
                            }
                        }else{
                            //                    DebugLog(@"found path, but it isn't a directory %@", thisPagesPath);
                        }
                    }else{
                        //                DebugLog(@"path to delete doesn't exist %@", thisPagesPath);
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @autoreleasepool {
                            [page setDrawableView:nil];
                            [[MMPageCacheManager sharedInstance] pageWasDeleted:page];
                        }
                    });
                }
            });
        }
    });
}



#pragma mark - Helper Methods

//
// @param scrapUUID attempt to delete the assets of this scrap in the input page, but only
//        if the scrap is unused in the bezel and the page's own undo manager (optionally)
// @param page the page who's scrap should be deleted
// @param respectOthers YES if we should keep scraps in the page's undoManager and update the page's scrapsOnPaperState,
//                      NO if we should ignore any other object that might have a vested interested in this scrap.
//                      (for instance, when deleting the page)
-(void) deleteScrap:(NSString*)scrapUUID inScrapCollectionState:(MMScrapCollectionState*)scrapCollectionState shouldRespectOthers:(BOOL)respectOthers{

    if(!scrapCollectionState || !scrapUUID){
        // sanity
        DebugLog(@"can't delete scrap %@ from collection %@", scrapUUID, scrapCollectionState);
        return;
    }

    [scrapCollectionState deleteScrapWithUUID:scrapUUID shouldRespectOthers:respectOthers];

}



@end
