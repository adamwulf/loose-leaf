//
//  MMScrapsOnPaperState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapsOnPaperState.h"
#import "MMScrapView.h"
#import "MMScrapViewState.h"
#import "MMImmutableScrapsOnPaperState.h"
#import "NSThread+BlockAdditions.h"

/**
 * similar to the MMPaperState, this object will
 * track the state for all scraps within a single page
 */
@implementation MMScrapsOnPaperState{
    NSString* scrapIDsPath;
    BOOL isLoaded;
    BOOL isLoading;
}

@synthesize delegate;
@synthesize scrapIDsPath;
@synthesize shouldShowShadows;

static dispatch_queue_t importExportStateQueue;

+(dispatch_queue_t) importExportStateQueue{
    if(!importExportStateQueue){
//        importExportStateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        importExportStateQueue = dispatch_queue_create("com.milestonemade.looseleaf.scraps.importExportStateQueue", DISPATCH_QUEUE_SERIAL);
    }
    return importExportStateQueue;
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

-(void) setShouldShowShadows:(BOOL)_shouldShowShadows{
    shouldShowShadows = _shouldShowShadows;
    for(MMScrapView* scrap in self.delegate.scraps){
        [scrap setShouldShowShadow:shouldShowShadows];
    }
}


-(void) loadStateAsynchronously:(BOOL)async andMakeEditable:(BOOL)makeEditable{
    if(![self isStateLoaded] && !isLoading){
        __block NSArray* scrapProps;
        @synchronized(self){
            isLoading = YES;
        }
        
        void (^block2)() = ^(void) {
            @autoreleasepool {
                dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
                scrapProps = [NSArray arrayWithContentsOfFile:scrapIDsPath];
                
                NSMutableArray* scrapPropsWithState = [NSMutableArray array];
                
                // load all the states async
                for(NSDictionary* scrapProperties in scrapProps){
                    MMScrapViewState* state = [[MMScrapViewState alloc] initWithUUID:[scrapProperties objectForKey:@"uuid"]];
                    if(state){
                        NSMutableDictionary* props = [NSMutableDictionary dictionaryWithDictionary:scrapProperties];
                        [props setObject:state forKey:@"state"];
                        [scrapPropsWithState addObject:props];
                    }
                }
                
                
                [NSThread performBlockOnMainThread:^{
                    for(NSDictionary* scrapProperties in scrapPropsWithState){
                        MMScrapViewState* scrapState = [scrapProperties objectForKey:@"state"];
                        MMScrapView* scrap = [[MMScrapView alloc] initWithScrapViewState:scrapState];
                        if(scrap){
                            scrap.center = CGPointMake([[scrapProperties objectForKey:@"center.x"] floatValue], [[scrapProperties objectForKey:@"center.y"] floatValue]);
                            scrap.rotation = [[scrapProperties objectForKey:@"rotation"] floatValue];
                            scrap.scale = [[scrapProperties objectForKey:@"scale"] floatValue];
                            [self.delegate didLoadScrap:scrap];
                            
                            if(makeEditable){
                                [scrap loadScrapStateAsynchronously:async];
                            }
                            [scrap setShouldShowShadow:shouldShowShadows];
                        }
                    }
                    @synchronized(self){
                        isLoaded = YES;
                        isLoading = NO;
                    }
                    [self.delegate didLoadAllScrapsFor:self];
                    dispatch_semaphore_signal(sema1);
                }];
                dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
                dispatch_release(sema1);
            }
        };

        if(async){
            dispatch_async([MMScrapsOnPaperState importExportStateQueue], block2);
        }else{
            block2();
        }
    }else if([self isStateLoaded] && makeEditable){
        void (^block2)() = ^(void) {
            if([self isStateLoaded]){
                for(MMScrapView* scrap in self.delegate.scraps){
                    [scrap loadScrapStateAsynchronously:async];
                }
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
    if([self isStateLoaded] || isLoading){
        dispatch_async([MMScrapsOnPaperState importExportStateQueue], ^(void) {
            @autoreleasepool {
                if([self isStateLoaded]){
                    NSArray* scraps = [self.delegate.scraps copy];
                    for(MMScrapView* scrap in scraps){
                        [scrap unloadState];
                    }
                    [NSThread performBlockOnMainThread:^{
                        [scraps makeObjectsPerformSelector:@selector(removeFromSuperview)];
                    }];
                    @synchronized(self){
                        isLoaded = NO;
                    }
                }
            }
        });
    }
}

-(MMImmutableScrapsOnPaperState*) immutableState{
    if([self isStateLoaded]){
        return [[MMImmutableScrapsOnPaperState alloc] initWithScrapIDsPath:self.scrapIDsPath andScraps:self.delegate.scraps];
    }
    return nil;
}

@end
