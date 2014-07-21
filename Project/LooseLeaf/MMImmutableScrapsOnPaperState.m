//
//  MMImmutableScrapState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/30/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMImmutableScrapsOnPaperState.h"
#import "MMScrapView.h"
#import "NSArray+Map.h"


@interface MMScrapsOnPaperState (Private)

#pragma mark - Saving Helpers

-(NSUInteger) lastSavedUndoHash;
-(void) wasSavedAtUndoHash:(NSUInteger)savedUndoHash;

@end



@implementation MMImmutableScrapsOnPaperState{
    MMScrapsOnPaperState* ownerState;
    NSArray* allScrapsForPage;
    NSArray* scrapsOnPageIDs;
    NSString* scrapIDsPath;
    NSUInteger cachedUndoHash;
}

-(id) initWithScrapIDsPath:(NSString *)_scrapIDsPath andAllScraps:(NSArray*)_allScraps andScrapsOnPage:(NSArray*)_scrapsOnPage andScrapsOnPaperState:(MMScrapsOnPaperState*)_ownerState{
    if(self = [super init]){
        ownerState = _ownerState;
        scrapIDsPath = _scrapIDsPath;
        scrapsOnPageIDs = [_scrapsOnPage mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            return [obj uuid];
        }];
        allScrapsForPage = [_allScraps copy];
    }
    return self;
}

-(BOOL) isStateLoaded{
    return YES;
}

-(NSArray*) scraps{
    return [allScrapsForPage filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [scrapsOnPageIDs containsObject:[evaluatedObject uuid]];
    }]];
}

-(BOOL) saveStateToDiskBlocking{
    if([NSThread isMainThread]){
        NSLog(@"saving state for %@ on main thread", scrapIDsPath);
    }else{
        NSLog(@"saving state for %@ on background thread", scrapIDsPath);
    }
    __block BOOL hadAnyEditsToSaveAtAll = NO;
    if(ownerState.lastSavedUndoHash != self.undoHash){
        NSMutableArray* allScrapProperties = [NSMutableArray array];
        if([allScrapsForPage count]){
            dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
            
            __block NSInteger savedScraps = 0;
            void(^doneSavingScrapBlock)(BOOL) = ^(BOOL hadEditsToSave){
                savedScraps ++;
                hadAnyEditsToSaveAtAll = hadAnyEditsToSaveAtAll || hadEditsToSave;
                if(savedScraps == [allScrapsForPage count]){
                    // just saved the last scrap, signal
                    dispatch_semaphore_signal(sema1);
                }
            };
            
            for(MMScrapView* scrap in allScrapsForPage){
                NSDictionary* properties = [scrap propertiesDictionary];
                [scrap saveScrapToDisk:doneSavingScrapBlock];
                // save scraps
                [allScrapProperties addObject:properties];
            }
            dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
        }
        
        NSDictionary* scrapsOnPaperInfo = [NSDictionary dictionaryWithObjectsAndKeys:allScrapProperties, @"allScrapProperties", scrapsOnPageIDs, @"scrapsOnPageIDs", nil];
        [scrapsOnPaperInfo writeToFile:scrapIDsPath atomically:YES];
        if([NSThread isMainThread]){
            NSLog(@"done saving state for %@ on main thread", scrapIDsPath);
        }else{
            NSLog(@"done saving state for %@ on background thread", scrapIDsPath);
        }
        [ownerState wasSavedAtUndoHash:self.undoHash];
    }

    return hadAnyEditsToSaveAtAll;
}

-(void) unload{
    if([self isStateLoaded]){
        [self saveStateToDiskBlocking];
    }
    [super unload];
}


-(NSUInteger) undoHash{
    if(!cachedUndoHash){
        NSUInteger prime = 31;
        NSUInteger hashVal = 1;
        for(MMScrapView* scrap in allScrapsForPage){
            hashVal = prime * hashVal + [[scrap uuid] hash];
            NSDictionary* properties = [scrap propertiesDictionary];
            hashVal = prime * hashVal + [[properties objectForKey:@"center.x"] floatValue];
            hashVal = prime * hashVal + [[properties objectForKey:@"center.y"] floatValue];
            hashVal = prime * hashVal + [[properties objectForKey:@"rotation"] floatValue];
            hashVal = prime * hashVal + [[properties objectForKey:@"scale"] floatValue];
        }
        hashVal = prime * hashVal + 4409; // a prime from http://www.bigprimes.net/archive/prime/6/
        for(NSString* stroke in scrapsOnPageIDs){
            hashVal = prime * hashVal + [stroke hash];
        }
        cachedUndoHash = hashVal;
    }
    return cachedUndoHash;
    
}


@end
