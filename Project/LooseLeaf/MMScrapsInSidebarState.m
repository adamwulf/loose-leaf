//
//  MMScrapsInSidebarState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/14/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapsInSidebarState.h"
#import "MMScrapView.h"
#import "NSThread+BlockAdditions.h"
#import "MMImmutableScrapsOnPaperState.h"
#import "MMScrapContainerView.h"
#import "MMImmutableScrapsInSidebarState.h"
#import "Constants.h"

@implementation MMScrapsInSidebarState{
    BOOL isLoaded;
    BOOL isLoading;
    NSMutableArray* allScrapsInSidebar;
    NSMutableArray* allPropertiesForScraps;
    BOOL hasEditsToSave;
}

@synthesize hasEditsToSave;
@synthesize delegate;
@synthesize allScrapsInSidebar;

static dispatch_queue_t importExportStateQueue;

+(dispatch_queue_t) importExportStateQueue{
    if(!importExportStateQueue){
        //        importExportStateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        importExportStateQueue = dispatch_queue_create("com.milestonemade.looseleaf.scraps.importExportStateQueue", DISPATCH_QUEUE_SERIAL);
    }
    return importExportStateQueue;
}

-(id) initWithDelegate:(NSObject<MMScrapsInSidebarStateDelegate>*)_delegate{
    if(self = [super init]){
        delegate = _delegate;
        allScrapsInSidebar = [NSMutableArray array];
        allPropertiesForScraps = [NSMutableArray array];
    }
    return self;
}

-(int) fullByteSize{
    int totalBytes = 0;
    @synchronized(allScrapsInSidebar){
        for(MMScrapView* scrap in allScrapsInSidebar){
            totalBytes += scrap.fullByteSize;
        }
    }
    return totalBytes;
}

#pragma mark - Save and Load

-(BOOL) isStateLoaded{
    return isLoaded;
}

-(void) loadStateAsynchronously:(BOOL)async atPath:(NSString*)scrapIDsPath andMakeEditable:(BOOL)makeEditable{
    if(![self isStateLoaded] && !isLoading){
        __block NSArray* scrapProps;
        @synchronized(self){
            isLoading = YES;
        }
        
        void (^block2)() = ^(void) {
            @autoreleasepool {
                dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
                NSDictionary* allScrapStateInfo = [NSDictionary dictionaryWithContentsOfFile:scrapIDsPath];
                
                scrapProps = [allScrapStateInfo objectForKey:@"allScrapProperties"];
                
                NSMutableArray* scrapPropsWithState = [NSMutableArray array];
                
                // load all the states async
                for(NSDictionary* scrapProperties in scrapProps){
                    // TODO: https://github.com/adamwulf/loose-leaf/issues/604
                    NSString* pageUUID = [scrapProperties objectForKey:@"pageUUID"];
                    NSString* scrapUUID = [scrapProperties objectForKey:@"uuid"];
                    MMScrapsOnPaperState* paperStateForScrap = [self.delegate paperStateForPageUUID:pageUUID];
                    
                    MMScrapView* scrapFromPaperState = [paperStateForScrap scrapForUUID:scrapUUID];
                    if(scrapFromPaperState){
//                        NSLog(@"sidebar found scrap from page %@", scrapFromPaperState.uuid);
                        NSMutableDictionary* props = [NSMutableDictionary dictionaryWithDictionary:scrapProperties];
                        [props setObject:scrapFromPaperState forKey:@"scrap"];
                        [scrapPropsWithState addObject:props];
                    }else{
                        // couldn't find already built scrap, so load a state and
                        // we'll build a scrap
                        if(paperStateForScrap){
                            MMScrapViewState* state = [[MMScrapViewState alloc] initWithUUID:scrapUUID andPaperState:paperStateForScrap];
                            if(state){
                                NSMutableDictionary* props = [NSMutableDictionary dictionaryWithDictionary:scrapProperties];
                                [props setObject:state forKey:@"state"];
                                [scrapPropsWithState addObject:props];
                            }else{
                                NSLog(@"couldn't find state for %@", scrapUUID);
                            }
                        }else{
                            NSLog(@"couldn't find scrap's page state for %@ in page %@", scrapUUID, pageUUID);
                        }
                    }
                }
                
                [NSThread performBlockOnMainThread:^{
                    for(NSDictionary* scrapProperties in scrapPropsWithState){
                        MMScrapView* scrap = nil;
                        if([scrapProperties objectForKey:@"scrap"]){
                            scrap = [scrapProperties objectForKey:@"scrap"];
//                            NSLog(@"sidebar reused scrap %@", scrap.uuid);
                        }else{
                            MMScrapViewState* scrapState = [scrapProperties objectForKey:@"state"];
                            scrap = [[MMScrapView alloc] initWithScrapViewState:scrapState];
//                            NSLog(@"sidebar built scrap %@", scrap.uuid);
                        }
                        if(scrap){
                            [scrap setPropertiesDictionary:scrapProperties];
                            @synchronized(allScrapsInSidebar){
                                [allScrapsInSidebar addObject:scrap];
                                [allPropertiesForScraps addObject:scrapProperties];
                            }
                            
                            [self.delegate didLoadScrapInSidebar:scrap];
                            
                            if(makeEditable){
                                [scrap loadScrapStateAsynchronously:async];
                            }
                            [scrap setShouldShowShadow:NO];
                        }else{
                            NSLog(@"couldn't load scrap for %@", scrapProperties);
                        }
                    }
                    @synchronized(self){
                        isLoaded = YES;
                        isLoading = NO;
                    }
                    [self.delegate didLoadAllScrapsInSidebar:self];
                    dispatch_semaphore_signal(sema1);
                }];
                dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
                //                dispatch_release(sema1); ARC handles this
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
                @synchronized(allScrapsInSidebar){
                    for(MMScrapView* scrap in allScrapsInSidebar){
                        [scrap loadScrapStateAsynchronously:async];
                    }
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
                    NSArray* scraps = nil;
                    @synchronized(allScrapsInSidebar){
                        scraps = [allScrapsInSidebar copy];
                    }
                    for(MMScrapView* scrap in scraps){
                        [scrap unloadState];
                    }
                    @synchronized(allScrapsInSidebar){
                        [allScrapsInSidebar removeAllObjects];
                    }
                    [NSThread performBlockOnMainThread:^{
                        [scraps makeObjectsPerformSelector:@selector(removeFromSuperview)];
                        [self.delegate didUnloadAllScrapsInSidebar:self];
                    }];
                    @synchronized(self){
                        isLoaded = NO;
                    }
                }
            }
        });
    }
}

-(MMImmutableScrapsInSidebarState*) immutableStateForPath:(NSString*)scrapIDsPath{
    if([self isStateLoaded]){
        hasEditsToSave = NO;
        return [[MMImmutableScrapsInSidebarState alloc] initWithScrapIDsPath:scrapIDsPath andAllScrapProperties:allPropertiesForScraps];
    }
    return nil;
}

#pragma mark - Manage Scraps

-(MMScrapView*) scrapForUUID:(NSString*)uuid{
    @synchronized(allScrapsInSidebar){
        for(MMScrapView*scrap in allScrapsInSidebar){
            if([scrap.uuid isEqualToString:uuid]){
                return scrap;
            }
        }
    }
    return nil;
}


-(void) scrapIsAddedToSidebar:(MMScrapView *)scrap{
    @synchronized(allScrapsInSidebar){
        NSMutableDictionary* props = [NSMutableDictionary dictionaryWithDictionary:[scrap propertiesDictionary]];
        [props setObject:[scrap owningPageUUID] forKey:@"pageUUID"];
        [allPropertiesForScraps insertObject:props atIndex:0];
        [allScrapsInSidebar insertObject:scrap atIndex:0];
    }
}

-(void) scrapIsRemovedFromSidebar:(MMScrapView *)scrap{
    @synchronized(allScrapsInSidebar){
        NSUInteger index = [allScrapsInSidebar indexOfObject:scrap];
        if(index != NSNotFound){
            [allPropertiesForScraps removeObjectAtIndex:index];
            [allScrapsInSidebar removeObjectAtIndex:index];
        }
    }
}

@end
