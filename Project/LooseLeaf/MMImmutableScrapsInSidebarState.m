//
//  MMImmutableScrapsInSidebarState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/15/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMImmutableScrapsInSidebarState.h"
#import "MMScrapView.h"
#import "NSArray+Map.h"

@implementation MMImmutableScrapsInSidebarState{
    NSArray* allScrapsForPage;
    NSString* scrapIDsPath;
}

-(id) initWithScrapIDsPath:(NSString *)_scrapIDsPath andAllScraps:(NSArray*)_allScraps{
    if(self = [super init]){
        scrapIDsPath = _scrapIDsPath;
        allScrapsForPage = [_allScraps copy];
    }
    return self;
}

-(BOOL) isStateLoaded{
    return YES;
}

-(NSArray*) scraps{
    return [allScrapsForPage copy];
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
    
    NSDictionary* scrapsOnPaperInfo = [NSDictionary dictionaryWithObjectsAndKeys:allScrapProperties, @"allScrapProperties", nil];
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
