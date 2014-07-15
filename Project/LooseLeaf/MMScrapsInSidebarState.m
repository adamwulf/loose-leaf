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
    NSMutableArray* allScrapsForPage;
    BOOL hasEditsToSave;
}

@synthesize hasEditsToSave;
@synthesize delegate;

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
        allScrapsForPage = [NSMutableArray array];
    }
    return self;
}

-(int) fullByteSize{
    int totalBytes = 0;
    for(MMScrapView* scrap in self.delegate.scrapsOnPaper){
        totalBytes += scrap.fullByteSize;
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
                    MMScrapsOnPaperState* pageStateForScrap = [self.delegate paperStateForPageUUID:nil];
                    MMScrapViewState* state = [[MMScrapViewState alloc] initWithUUID:[scrapProperties objectForKey:@"uuid"] andPaperState:pageStateForScrap];
                    if(state){
                        NSMutableDictionary* props = [NSMutableDictionary dictionaryWithDictionary:scrapProperties];
                        [props setObject:state forKey:@"state"];
                        [scrapPropsWithState addObject:props];
                    }
                }
                
                [NSThread performBlockOnMainThread:^{
                    for(NSDictionary* scrapProperties in scrapPropsWithState){
                        MMScrapViewState* scrapState = [scrapProperties objectForKey:@"state"];
                        MMScrapView* scrap = [[MMScrapView alloc] initWithScrapViewState:scrapState andPaperState:scrapState.scrapsOnPaperState];
                        if(scrap){
                            [scrap setPropertiesDictionary:scrapProperties];
                            [allScrapsForPage addObject:scrap];
                            
                            [self.delegate didLoadScrapInSidebar:scrap];
                            
                            if(makeEditable){
                                [scrap loadScrapStateAsynchronously:async];
                            }
                            [scrap setShouldShowShadow:NO];
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
                for(MMScrapView* scrap in self.delegate.scrapsOnPaper){
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
                    NSArray* scraps = [self.delegate.scrapsOnPaper copy];
                    for(MMScrapView* scrap in scraps){
                        [scrap unloadState];
                    }
                    [allScrapsForPage removeAllObjects];
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
        return [[MMImmutableScrapsInSidebarState alloc] initWithScrapIDsPath:scrapIDsPath andAllScraps:allScrapsForPage];
    }
    return nil;
}

#pragma mark - Manage Scraps

-(MMScrapView*) scrapForUUID:(NSString*)uuid{
    @synchronized(allScrapsForPage){
        for(MMScrapView*scrap in allScrapsForPage){
            if([scrap.uuid isEqualToString:uuid]){
                return scrap;
            }
        }
    }
    return nil;
}

@end
