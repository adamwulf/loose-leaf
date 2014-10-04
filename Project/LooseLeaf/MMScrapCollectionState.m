//
//  MMScrapCollectionState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/3/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapCollectionState.h"
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
    }
    return self;
}

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
    @throw kAbstractMethodException;
}


@end
