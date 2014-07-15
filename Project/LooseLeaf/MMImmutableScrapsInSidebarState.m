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
    NSArray* allScrapProperties;
    NSString* scrapIDsPath;
}

-(id) initWithScrapIDsPath:(NSString *)_scrapIDsPath andAllScrapProperties:(NSArray*)_allScrapProperties{
    if(self = [super init]){
        scrapIDsPath = _scrapIDsPath;
        allScrapProperties = [_allScrapProperties copy];
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
