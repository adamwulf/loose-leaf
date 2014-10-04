//
//  MMImmutableScrapsInSidebarState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/15/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMImmutableScrapsInSidebarState.h"
#import "MMScrapCollectionState+Private.h"
#import "MMScrapView.h"
#import "NSArray+Map.h"

@implementation MMImmutableScrapsInSidebarState{
    MMScrapCollectionState* ownerState;
    NSArray* allScrapProperties;
    NSString* scrapIDsPath;
    NSUInteger cachedUndoHash;
}

-(id) initWithScrapIDsPath:(NSString *)_scrapIDsPath andAllScrapProperties:(NSArray*)_allScrapProperties andOwnerState:(MMScrapCollectionState *)_ownerState{
    if(self = [super init]){
        ownerState = _ownerState;
        scrapIDsPath = _scrapIDsPath;
        allScrapProperties = [_allScrapProperties mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            NSMutableDictionary* props = [NSMutableDictionary dictionaryWithDictionary:obj];
            [props removeObjectForKey:@"state"]; // don't allow state object in the list
            [props removeObjectForKey:@"scrap"]; // don't allow scrap object in the list
            return props;
        }];
    }
    return self;
}

-(BOOL) isStateLoaded{
    return YES;
}

-(NSArray*) allScrapProperties{
    return [allScrapProperties copy];
}

-(BOOL) saveStateToDiskBlocking{
    __block BOOL hadAnyEditsToSaveAtAll = NO;
    if(ownerState.lastSavedUndoHash != self.undoHash){
        NSDictionary* scrapsOnPaperInfo = [NSDictionary dictionaryWithObjectsAndKeys:allScrapProperties, @"allScrapProperties", nil];
        if([scrapsOnPaperInfo writeToFile:scrapIDsPath atomically:YES]){
    //        NSLog(@"saved bezel scrap state for %d scraps", [allScrapProperties count]);
    //        NSLog(@"saved to: %@", scrapIDsPath);
        }else{
            NSLog(@"couldn't save");
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
        for(NSDictionary* scrapDict in allScrapProperties){
            hashVal = prime * hashVal + [[scrapDict objectForKey:@"uuid"] hash];
            hashVal = prime * hashVal + [[scrapDict objectForKey:@"pageUUID"] hash];
            hashVal = prime * hashVal + [[scrapDict objectForKey:@"subviewIndex"] hash];
            hashVal = prime * hashVal + [[scrapDict objectForKey:@"center.x"] hash];
            hashVal = prime * hashVal + [[scrapDict objectForKey:@"center.y"] hash];
            hashVal = prime * hashVal + [[scrapDict objectForKey:@"rotation"] hash];
            hashVal = prime * hashVal + [[scrapDict objectForKey:@"scale"] hash];
        }
        cachedUndoHash = hashVal;
    }
    return cachedUndoHash;
}



@end
