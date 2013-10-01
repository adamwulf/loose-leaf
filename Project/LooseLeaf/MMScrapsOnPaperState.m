//
//  MMScrapsOnPaperState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapsOnPaperState.h"
#import "MMScrapView.h"
#import "MMImmutableScrapsOnPaperState.h"

/**
 * similar to the MMPaperState, this object will
 * track the state for all scraps within a single page
 */
@implementation MMScrapsOnPaperState{
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
            if(scrap){
                scrap.center = CGPointMake([[scrapProperties objectForKey:@"center.x"] floatValue], [[scrapProperties objectForKey:@"center.y"] floatValue]);
                scrap.rotation = [[scrapProperties objectForKey:@"rotation"] floatValue];
                scrap.scale = [[scrapProperties objectForKey:@"scale"] floatValue];
                [self.delegate didLoadScrap:scrap];
                
                [scrap loadStateAsynchronously:async];
            }
        }
        isLoaded = YES;
    }
}

-(void) unload{
    if([self isStateLoaded]){
        for(MMScrapView* scrap in self.delegate.scraps){
            [scrap unloadState];
        }
        isLoaded = NO;
    }
}

-(MMImmutableScrapsOnPaperState*) immutableState{
    if([self isStateLoaded]){
        return [[MMImmutableScrapsOnPaperState alloc] initWithScrapIDsPath:self.scrapIDsPath andScraps:self.delegate.scraps];
    }
    return nil;
}

@end
