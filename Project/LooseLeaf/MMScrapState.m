//
//  MMScrapState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapState.h"
#import "MMScrapView.h"
#import "MMImmutableScrapState.h"

/**
 * similar to the MMPaperState, this object will
 * track the state for all scraps within a single page
 */
@implementation MMScrapState{
    NSString* scrapIDsPath;
    BOOL isLoaded;
}

@synthesize delegate;
@synthesize scrapIDsPath;

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
        isLoaded = NO;
    }
}

-(MMImmutableScrapState*) immutableState{
    if([self isStateLoaded]){
        return [[MMImmutableScrapState alloc] initWithScrapIDsPath:self.scrapIDsPath andScraps:self.delegate.scraps];
    }
    return nil;
}

@end
