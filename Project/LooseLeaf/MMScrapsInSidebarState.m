//
//  MMScrapsInSidebarState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/14/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapsInSidebarState.h"
#import "MMScrapView.h"
#import "NSThread+BlockAdditions.h"
#import "MMImmutableScrapsOnPaperState.h"
#import "MMScrapContainerView.h"
#import "MMImmutableScrapsInSidebarState.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "Constants.h"

@implementation MMScrapsInSidebarState{
    // all of the loaded properties for all this state's scraps
    NSMutableArray* allPropertiesForScraps;
}

@dynamic delegate;

-(id) initWithDelegate:(NSObject<MMScrapsInSidebarStateDelegate>*)_delegate{
    if(self = [super init]){
        delegate = _delegate;
        allPropertiesForScraps = [NSMutableArray array];
    }
    return self;
}

-(int) fullByteSize{
    int totalBytes = 0;
    @synchronized(allLoadedScraps){
        for(MMScrapView* scrap in allLoadedScraps){
            totalBytes += scrap.fullByteSize;
        }
    }
    return totalBytes;
}

#pragma mark - Save and Load

-(void) loadStateAsynchronously:(BOOL)async atPath:(NSString*)scrapIDsPath andMakeEditable:(BOOL)makeEditable{
    if(![self isStateLoaded] && !isLoading){
        __block NSArray* scrapProps;
        @synchronized(self){
            isLoading = YES;
        }
        
        void (^block2)() = ^(void) {
            @autoreleasepool {
                dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
                NSDictionary* allScrapStateInfo = [NSDictionary dictionaryWithContentsOfFile:scrapIDsPath];
                
                scrapProps = [allScrapStateInfo objectForKey:@"allScrapProperties"];
                
                NSMutableArray* scrapPropsWithState = [NSMutableArray array];
                
                // load all the states async
                for(NSDictionary* scrapProperties in scrapProps){
                    // TODO: https://github.com/adamwulf/loose-leaf/issues/604
                    NSString* pageUUID = [scrapProperties objectForKey:@"pageUUID"];
                    NSString* scrapUUID = [scrapProperties objectForKey:@"uuid"];
                    MMScrapsOnPaperState* paperStateForScrap = [self.delegate paperStateForPageUUID:pageUUID];
                    
                    MMScrapView* scrapFromPaperState = [paperStateForScrap scrapForUUID:scrapUUID];
                    if(scrapFromPaperState){
//                        NSLog(@"sidebar found scrap from page %@", scrapFromPaperState.uuid);
                        NSMutableDictionary* props = [NSMutableDictionary dictionaryWithDictionary:scrapProperties];
                        [props setObject:scrapFromPaperState forKey:@"scrap"];
                        [scrapPropsWithState addObject:props];
                    }else{
                        // couldn't find already built scrap, so load a state and
                        // we'll build a scrap
                        if(paperStateForScrap){
                            __block MMScrapViewState* state = nil;
                            [NSThread performBlockOnMainThreadSync:^{
                                state = [[MMScrapViewState alloc] initWithUUID:scrapUUID andPaperState:paperStateForScrap];
                            }];
                            if(state){
                                NSMutableDictionary* props = [NSMutableDictionary dictionaryWithDictionary:scrapProperties];
                                [props setObject:state forKey:@"state"];
                                [scrapPropsWithState addObject:props];
                            }else{
                                NSLog(@"couldn't find state for %@", scrapUUID);
                            }
                        }else{
                            NSLog(@"couldn't find scrap's page state for %@ in page %@", scrapUUID, pageUUID);
                        }
                    }
                }
                
                [NSThread performBlockOnMainThread:^{
                    for(NSDictionary* scrapProperties in scrapPropsWithState){
                        @synchronized(self){
                            if(isUnloading){
                                @throw [NSException exceptionWithName:@"StateInconsistentException" reason:@"loading during unloading" userInfo:nil];
                            }
                        }
                        MMScrapView* scrap = nil;
                        if([scrapProperties objectForKey:@"scrap"]){
                            scrap = [scrapProperties objectForKey:@"scrap"];
//                            NSLog(@"reused scrap %@", scrap.uuid);
                        }else{
                            MMScrapViewState* scrapState = [scrapProperties objectForKey:@"state"];
                            scrap = [[MMScrapView alloc] initWithScrapViewState:scrapState];
//                            NSLog(@"built scrap %@", scrap.uuid);
                            [scrap setPropertiesDictionary:scrapProperties];
                        }
                        if(scrap){
                            @synchronized(allLoadedScraps){
                                [allLoadedScraps addObject:scrap];
                                [allPropertiesForScraps addObject:scrapProperties];
                            }
                            
                            [self.delegate didLoadScrapInContainer:scrap];
                            
                            if(makeEditable){
                                [scrap loadScrapStateAsynchronously:async];
                            }
                        }else{
                            NSLog(@"couldn't load scrap for %@", scrapProperties);
                        }
                    }
                    @synchronized(self){
                        MMImmutableScrapCollectionState* immutableState = [self immutableStateForPath:nil];
                        expectedUndoHash = [immutableState undoHash];
                        lastSavedUndoHash = [immutableState undoHash];
                        isLoaded = YES;
                        isLoading = NO;
                    }
                    [self.delegate didLoadAllScrapsFor:self];
                    dispatch_semaphore_signal(sema1);
                }];
                dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
            }
        };
        
        if(async){
            dispatch_async([MMScrapCollectionState importExportStateQueue], block2);
        }else{
            block2();
        }
    }else if([self isStateLoaded] && makeEditable){
        void (^block2)() = ^(void) {
            if([self isStateLoaded]){
                @synchronized(allLoadedScraps){
                    for(MMScrapView* scrap in allLoadedScraps){
                        [scrap loadScrapStateAsynchronously:async];
                        @synchronized(self){
                            if(isUnloading){
                                @throw [NSException exceptionWithName:@"StateInconsistentException" reason:@"loading during unloading" userInfo:nil];
                            }
                        }
                    }
                }
            }
        };
        if(async){
            dispatch_async([MMScrapCollectionState importExportStateQueue], block2);
        }else{
            block2();
        }
    }
}

-(MMImmutableScrapsInSidebarState*) immutableStateForPath:(NSString*)scrapIDsPath{
    if(!isLoading && ![MMScrapCollectionState isImportExportStateQueue]){
        @throw [NSException exceptionWithName:@"InconsistentQueueException" reason:@"Creating immutable ScrapsInSidebarState in wrong queue" userInfo:nil];
    }
    if([self isStateLoaded] || isLoading){
        hasEditsToSave = NO;
        MMImmutableScrapsInSidebarState* immutable = [[MMImmutableScrapsInSidebarState alloc] initWithScrapIDsPath:scrapIDsPath andAllScrapProperties:allPropertiesForScraps andOwnerState:self];
        expectedUndoHash = [immutable undoHash];
        return immutable;
    }
    return nil;
}

#pragma mark - Saving Helpers

-(void) wasSavedAtUndoHash:(NSUInteger)savedUndoHash{
    @synchronized(self){
        lastSavedUndoHash = savedUndoHash;
    }
}


#pragma mark - Manage Scraps

-(void) scrapVisibilityWasUpdated:(MMScrapView*)scrap{
    // noop
}

-(MMScrapView*) scrapForUUID:(NSString*)uuid{
    @synchronized(allLoadedScraps){
        for(MMScrapView*scrap in allLoadedScraps){
            if([scrap.uuid isEqualToString:uuid]){
                return scrap;
            }
        }
    }
    return nil;
}

-(void) scrapIsAddedToSidebar:(MMScrapView *)scrap{
    @synchronized(allLoadedScraps){
        NSMutableDictionary* props = [NSMutableDictionary dictionaryWithDictionary:[scrap propertiesDictionary]];
        [props setObject:[scrap owningPageUUID] forKey:@"pageUUID"];
        [allPropertiesForScraps insertObject:props atIndex:0];
        [allLoadedScraps insertObject:scrap atIndex:0];
        hasEditsToSave = YES;
    }
}

-(void) scrapIsRemovedFromSidebar:(MMScrapView *)scrap{
    @synchronized(allLoadedScraps){
        NSUInteger index = [allLoadedScraps indexOfObject:scrap];
        if(index != NSNotFound){
            [allPropertiesForScraps removeObjectAtIndex:index];
            [allLoadedScraps removeObjectAtIndex:index];
            hasEditsToSave = YES;
        }
    }
}

#pragma mark - Paths

-(NSString*) directoryPathForScrapUUID:(NSString*)uuid{
    NSString* documentsPath = [NSFileManager documentsPath];
    NSString* bezelStateDirectory = [documentsPath stringByAppendingPathComponent:@"Bezel"];
    NSString* scrapPath = [[bezelStateDirectory stringByAppendingPathComponent:@"Scraps"] stringByAppendingPathComponent:uuid];
    return scrapPath;
}

-(NSString*) bundledDirectoryPathForScrapUUID:(NSString*)uuid{
    NSString* documentsPath = [[NSBundle mainBundle] pathForResource:@"Documents" ofType:nil];
    NSString* bezelStateDirectory = [documentsPath stringByAppendingPathComponent:@"Bezel"];
    NSString* scrapPath = [[bezelStateDirectory stringByAppendingPathComponent:@"Scraps"] stringByAppendingPathComponent:uuid];
    return scrapPath;
}

@end
