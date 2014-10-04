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

@implementation MMScrapCollectionState

@synthesize allLoadedScraps;
@synthesize lastSavedUndoHash;

static dispatch_queue_t importExportStateQueue;

+(dispatch_queue_t) importExportStateQueue{
    if(!importExportStateQueue){
        importExportStateQueue = dispatch_queue_create("com.milestonemade.looseleaf.scraps.importExportStateQueue", DISPATCH_QUEUE_SERIAL);
    }
    return importExportStateQueue;
}

-(id) init{
    if(self = [super init]){
        expectedUndoHash = 0;
        lastSavedUndoHash = 0;
        allLoadedScraps = [NSMutableArray array];
        allPropertiesForScraps = [NSMutableArray array];
    }
    return self;
}

@synthesize delegate;

#pragma mark - Properties

-(BOOL) hasEditsToSave{
    return hasEditsToSave || expectedUndoHash != lastSavedUndoHash;
}

-(NSUInteger) lastSavedUndoHash{
    @synchronized(self){
        return lastSavedUndoHash;
    }
}

#pragma mark - Save and Load

-(MMImmutableScrapCollectionState*) immutableStateForPath:(NSString *)scrapIDsPath{
    @throw kAbstractMethodException;
}

-(BOOL) isStateLoaded{
    return isLoaded;
}

-(void) wasSavedAtUndoHash:(NSUInteger)savedUndoHash{
    @synchronized(self){
        lastSavedUndoHash = savedUndoHash;
    }
}

-(void) loadStateAsynchronously:(BOOL)async atPath:(NSString*)scrapIDsPath andMakeEditable:(BOOL)makeEditable{
    @throw kAbstractMethodException;
}

-(void) unload{
    if([self hasEditsToSave]){
        @throw [NSException exceptionWithName:@"StateInconsistentException" reason:@"Unloading ScrapCollectionState with edits pending save." userInfo:nil];
    }
    if([self isStateLoaded] || isLoading){
        @synchronized(self){
            isUnloading = YES;
        }
        dispatch_async([MMScrapCollectionState importExportStateQueue], ^(void) {
            @autoreleasepool {
                if(isLoading){
                    @throw [NSException exceptionWithName:@"StateInconsistentException" reason:@"unloading during loading" userInfo:nil];
                }
                if([self isStateLoaded]){
                    @synchronized(allLoadedScraps){
                        for(MMScrapView* scrap in allLoadedScraps){
                            if([delegate scrapForUUIDIfAlreadyExistsInOtherContainer:scrap.uuid]){
                                // if this is true, then the scrap is being held
                                // by the sidebar, so we shouldn't manage its
                                // state
                            }else{
                                [scrap unloadState];
                            }
                        }
                        NSArray* visibleScraps = [allLoadedScraps copy];
                        [NSThread performBlockOnMainThread:^{
                            [visibleScraps makeObjectsPerformSelector:@selector(removeFromSuperview)];
                            [self.delegate didUnloadAllScrapsFor:self];
                        }];
                        [allLoadedScraps removeAllObjects];
                    }
                    @synchronized(self){
                        isLoaded = NO;
                        isUnloading = NO;
                        expectedUndoHash = 0;
                        lastSavedUndoHash = 0;
                    }
                }
            }
        });
    }
}


@end
