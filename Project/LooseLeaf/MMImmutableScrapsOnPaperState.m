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

@implementation MMImmutableScrapsOnPaperState{
    NSArray* allScrapsForPage;
    NSArray* scrapsOnPageIDs;
    NSString* scrapIDsPath;
}

-(id) initWithScrapIDsPath:(NSString *)_scrapIDsPath andAllScraps:(NSArray*)_allScraps andScrapsOnPage:(NSArray*)_scrapsOnPage{
    if(self = [super init]){
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
    __block BOOL hadAnyEditsToSaveAtAll = NO;
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

    return hadAnyEditsToSaveAtAll;
}

-(void) unload{
    if([self isStateLoaded]){
        [self saveStateToDiskBlocking];
    }
    [super unload];
}

@end
