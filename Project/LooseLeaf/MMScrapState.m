//
//  MMScrapState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapState.h"
#import "MMScrapView.h"

/**
 * similar to the MMPaperState, this object will
 * track the state for all scraps within a single page
 */
@implementation MMScrapState{
    NSString* scrapIDsPath;
    BOOL isLoaded;
}

@synthesize delegate;

-(id) initWithScrapIDsPath:(NSString*)_scrapIDsPath{
    if(self = [super init]){
        scrapIDsPath = _scrapIDsPath;
    }
    return self;
}

-(BOOL) isStateLoaded{
    return isLoaded;
}

-(void) loadStateAsynchronously:(BOOL)async{
    if(![self isStateLoaded]){
        NSArray* scrapProps = [NSArray arrayWithContentsOfFile:scrapIDsPath];
        for(NSDictionary* scrapProperties in scrapProps){
            MMScrapView* scrap = [[MMScrapView alloc] initWithUUID:[scrapProperties objectForKey:@"uuid"]];
            scrap.center = CGPointMake([[scrapProperties objectForKey:@"center.x"] floatValue], [[scrapProperties objectForKey:@"center.y"] floatValue]);
            scrap.rotation = [[scrapProperties objectForKey:@"rotation"] floatValue];
            scrap.scale = [[scrapProperties objectForKey:@"scale"] floatValue];
            [self.delegate didLoadScrap:scrap];
        }
        isLoaded = YES;
    }
}

-(void) unload{
    if([self isStateLoaded]){
        [self saveToDisk];
        isLoaded = NO;
    }
}

-(void) saveToDisk{
    if([self isStateLoaded]){
        if([self.delegate.scraps count]){
            NSMutableArray* scrapUUIDs = [NSMutableArray array];
            for(MMScrapView* scrap in self.delegate.scraps){
                NSMutableDictionary* properties = [NSMutableDictionary dictionary];
                [properties setObject:scrap.uuid forKey:@"uuid"];
                [properties setObject:[NSNumber numberWithFloat:scrap.center.x] forKey:@"center.x"];
                [properties setObject:[NSNumber numberWithFloat:scrap.center.y] forKey:@"center.y"];
                [properties setObject:[NSNumber numberWithFloat:scrap.rotation] forKey:@"rotation"];
                [properties setObject:[NSNumber numberWithFloat:scrap.scale] forKey:@"scale"];
                
                [scrap saveToDisk];
                
                // save scraps
                [scrapUUIDs addObject:properties];
            }
            [scrapUUIDs writeToFile:scrapIDsPath atomically:YES];
        }else{
            [[NSFileManager defaultManager] removeItemAtPath:scrapIDsPath error:nil];
        }
    }
}

@end
