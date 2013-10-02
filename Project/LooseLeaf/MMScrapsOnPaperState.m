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
#import "NSThread+BlockAdditions.h"

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

static dispatch_queue_t importExportStateQueue;
static dispatch_queue_t concurrentBackgroundQueue;

+(dispatch_queue_t) importExportStateQueue{
    if(!importExportStateQueue){
        importExportStateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        //        dispatch_queue_create("com.milestonemade.looseleaf.importExportStateQueue", DISPATCH_QUEUE_SERIAL);
    }
    return importExportStateQueue;
}

+(dispatch_queue_t) concurrentBackgroundQueue{
    if(!concurrentBackgroundQueue){
        concurrentBackgroundQueue = dispatch_queue_create("com.milestonemade.looseleaf.concurrentBackgroundQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return concurrentBackgroundQueue;
}

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
        __block NSArray* scrapProps;
        
        void (^block2)() = ^(void) {
            @autoreleasepool {
                scrapProps = [NSArray arrayWithContentsOfFile:scrapIDsPath];
                [NSThread performBlockOnMainThread:^{
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
                }];
                isLoaded = YES;
            }
        };

        if(async){
            dispatch_async([MMScrapsOnPaperState importExportStateQueue], block2);
        }else{
            block2();
        }
    }
}

-(void) unload{
    dispatch_async([MMScrapsOnPaperState importExportStateQueue], ^(void) {
        if([self isStateLoaded]){
            for(MMScrapView* scrap in self.delegate.scraps){
                [scrap unloadState];
            }
            isLoaded = NO;
        }
    });
}

-(MMImmutableScrapsOnPaperState*) immutableState{
    if([self isStateLoaded]){
        return [[MMImmutableScrapsOnPaperState alloc] initWithScrapIDsPath:self.scrapIDsPath andScraps:self.delegate.scraps];
    }
    return nil;
}

@end
