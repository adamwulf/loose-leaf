//
//  MMImmutableScrapState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/30/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMImmutableScrapsOnPaperState.h"
#import "MMScrapCollectionState+Private.h"
#import "MMScrapView.h"
#import "NSArray+Map.h"
#import "Constants.h"


@implementation MMImmutableScrapsOnPaperState {
    NSMutableDictionary* scrapIdToProperties;
    MMScrapCollectionState* ownerState;
    NSArray* allScrapsForPage;
    NSArray* scrapsOnPageIDs;
    NSString* scrapIDsPath;
    NSUInteger cachedUndoHash;
}

- (id)initWithScrapIDsPath:(NSString*)_scrapIDsPath andAllScraps:(NSArray*)_allScraps andScrapsOnPage:(NSArray*)_scrapsOnPage andOwnerState:(MMScrapCollectionState*)_ownerState {
    CheckMainThread;
    if (self = [super init]) {
        scrapIdToProperties = [NSMutableDictionary dictionary];
        ownerState = _ownerState;
        scrapIDsPath = _scrapIDsPath;
        scrapsOnPageIDs = [_scrapsOnPage mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            return [obj uuid];
        }];
        allScrapsForPage = [_allScraps copy];

        for (MMScrapView* scrap in _allScraps) {
            scrapIdToProperties[scrap.uuid] = [scrap propertiesDictionary];
        }
    }
    return self;
}

- (BOOL)isStateLoaded {
    return YES;
}

- (NSArray*)scraps {
    return [[allScrapsForPage filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bindings) {
        // only return scraps that are physically on the page
        // we'll save all scraps, but this method is used
        // to help generate the thumbnail later on, so we only
        // care about scraps on the page
        return [scrapsOnPageIDs containsObject:[evaluatedObject uuid]];
    }]] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        // sort the scraps, so that they are added to the thumbnail
        // in the correct order
        return [scrapsOnPageIDs indexOfObject:[obj1 uuid]] < [scrapsOnPageIDs indexOfObject:[obj2 uuid]] ? NSOrderedAscending : NSOrderedDescending;
    }];
}

- (BOOL)saveStateToDiskBlocking {
    CheckThreadMatches([MMScrapCollectionState isImportExportStateQueue]);
    __block BOOL hadAnyEditsToSaveAtAll = NO;
    if (ownerState.lastSavedUndoHash != self.undoHash) {
        hadAnyEditsToSaveAtAll = YES;
        //        DebugLog(@"scrapsOnPaperState needs saving last: %lu !=  now:%lu", (unsigned long) ownerState.lastSavedUndoHash, (unsigned long) self.undoHash);
        NSMutableArray* allScrapProperties = [NSMutableArray array];
        if ([allScrapsForPage count]) {
            dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);

            __block NSInteger savedScraps = 0;
            void (^doneSavingScrapBlock)(BOOL) = ^(BOOL hadEditsToSave) {
                savedScraps++;
                //                hadAnyEditsToSaveAtAll = hadAnyEditsToSaveAtAll || hadEditsToSave;
                if (savedScraps == [allScrapsForPage count]) {
                    // just saved the last scrap, signal
                    dispatch_semaphore_signal(sema1);
                }
            };

            for (MMScrapView* scrap in allScrapsForPage) {
                NSDictionary* properties = scrapIdToProperties[scrap.uuid];
                [scrap saveScrapToDisk:doneSavingScrapBlock];
                // save scraps
                [allScrapProperties addObject:properties];
            }
            dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
        }

        //        DebugLog(@"saving %lu scraps on %@", (unsigned long)[scrapsOnPageIDs count], ownerState.delegate);

        CGSize screenSize = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds].size;

        NSDictionary* scrapsOnPaperInfo = [NSDictionary dictionaryWithObjectsAndKeys:allScrapProperties, @"allScrapProperties", scrapsOnPageIDs, @"scrapsOnPageIDs", @(screenSize.width), @"screenSize.width", @(screenSize.height), @"screenSize.height", nil];
        if ([scrapsOnPaperInfo writeToFile:scrapIDsPath atomically:YES]) {
            //            DebugLog(@"saved to %@", scrapIDsPath);
        } else {
            DebugLog(@"failed saved to %@", scrapIDsPath);
        }
        [ownerState wasSavedAtUndoHash:self.undoHash];
    } else {
        // we've already saved an immutable state with this hash
        //        DebugLog(@"scrapsOnPaperState doesn't need saving %lu == %lu", (unsigned long) ownerState.lastSavedUndoHash, (unsigned long) self.undoHash);
    }

    return hadAnyEditsToSaveAtAll;
}

- (NSUInteger)undoHash {
    if (!cachedUndoHash) {
        NSUInteger prime = 31;
        NSUInteger hashVal = 1;
        for (MMScrapView* scrap in allScrapsForPage) {
            hashVal = prime * hashVal + [[scrap uuid] hash];
            if ([scrap.state isScrapStateLoaded]) {
                // if we're loaded, use the current hash
                hashVal = prime * hashVal + [scrap.state.drawableView.state undoHash];
            } else {
                // otherwise, use our most recently saved hash
                hashVal = prime * hashVal + [scrap.state lastSavedUndoHash];
            }
            NSDictionary* properties = scrapIdToProperties[scrap.uuid];
            hashVal = prime * hashVal + [[properties objectForKey:@"center.x"] hash];
            hashVal = prime * hashVal + [[properties objectForKey:@"center.y"] hash];
            hashVal = prime * hashVal + [[properties objectForKey:@"rotation"] hash];
            hashVal = prime * hashVal + [[properties objectForKey:@"scale"] hash];
        }
        hashVal = prime * hashVal + 4409; // a prime from http://www.bigprimes.net/archive/prime/6/
        for (NSString* stroke in scrapsOnPageIDs) {
            hashVal = prime * hashVal + [stroke hash];
        }
        cachedUndoHash = hashVal;
    }
    return cachedUndoHash;
}


@end
