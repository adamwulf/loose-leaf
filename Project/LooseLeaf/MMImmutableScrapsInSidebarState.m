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

    NSDictionary* scrapsOnPaperInfo = [NSDictionary dictionaryWithObjectsAndKeys:allScrapProperties, @"allScrapProperties", nil];
    if([scrapsOnPaperInfo writeToFile:scrapIDsPath atomically:YES]){
        NSLog(@"saved bezel scrap state for %d scraps", [allScrapProperties count]);
        NSLog(@"saved to: %@", scrapIDsPath);
    }else{
        NSLog(@"couldn't save");
    }
    
    
    return hadAnyEditsToSaveAtAll;
}

-(void) unload{
    if([self isStateLoaded]){
        [self saveStateToDiskBlocking];
    }
    [super unload];
}

@end
