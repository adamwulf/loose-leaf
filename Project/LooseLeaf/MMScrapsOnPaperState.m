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
#import "UIView+Debug.h"

/**
 * similar to the MMPaperState, this object will
 * track the state for all scraps within a single page
 */
@implementation MMScrapsOnPaperState{
    BOOL isLoaded;
    BOOL isLoading;
}

@synthesize delegate;
@synthesize shouldShowShadows;

static dispatch_queue_t importExportStateQueue;

+(dispatch_queue_t) importExportStateQueue{
    if(!importExportStateQueue){
//        importExportStateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);
        importExportStateQueue = dispatch_queue_create("com.milestonemade.looseleaf.scraps.importExportStateQueue", DISPATCH_QUEUE_SERIAL);
    }
    return importExportStateQueue;
}

-(id) initWithDelegate:(NSObject<MMScrapsOnPaperStateDelegate>*)_delegate{
    if(self = [super init]){
        delegate = _delegate;
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

-(void) setShouldShowShadows:(BOOL)_shouldShowShadows{
    shouldShowShadows = _shouldShowShadows;
    for(MMScrapView* scrap in self.delegate.scrapsOnPaper){
        [scrap setShouldShowShadow:shouldShowShadows];
    }
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
                scrapProps = [NSArray arrayWithContentsOfFile:scrapIDsPath];
                
                NSMutableArray* scrapPropsWithState = [NSMutableArray array];
                
                // load all the states async
                for(NSDictionary* scrapProperties in scrapProps){
                    MMScrapViewState* state = [[MMScrapViewState alloc] initWithUUID:[scrapProperties objectForKey:@"uuid"] andPaperState:self];
                    if(state){
                        NSMutableDictionary* props = [NSMutableDictionary dictionaryWithDictionary:scrapProperties];
                        [props setObject:state forKey:@"state"];
                        [scrapPropsWithState addObject:props];
                    }
                }
                
                [NSThread performBlockOnMainThread:^{
                    for(NSDictionary* scrapProperties in scrapPropsWithState){
                        MMScrapViewState* scrapState = [scrapProperties objectForKey:@"state"];
                        MMScrapView* scrap = [[MMScrapView alloc] initWithScrapViewState:scrapState andPaperState:self];
                        if(scrap){
                            [scrap setPropertiesDictionary:scrapProperties];
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
                    [NSThread performBlockOnMainThread:^{
                        [scraps makeObjectsPerformSelector:@selector(removeFromSuperview)];
                        [self.delegate didUnloadAllScrapsFor:self];
                    }];
                    @synchronized(self){
                        isLoaded = NO;
                    }
                }
            }
        });
    }
}

-(MMImmutableScrapsOnPaperState*) immutableStateForPath:(NSString*)scrapIDsPath{
    if([self isStateLoaded]){
        return [[MMImmutableScrapsOnPaperState alloc] initWithScrapIDsPath:scrapIDsPath andScraps:self.delegate.scrapsOnPaper];
    }
    return nil;
}

#pragma mark - Add Scraps

-(MMScrapView*) addScrapWithPath:(UIBezierPath*)path andRotation:(CGFloat)rotation andScale:(CGFloat)scale{
    MMScrapView* newScrap = [[MMScrapView alloc] initWithBezierPath:path andScale:scale andRotation:rotation andPaperState:self];
    return newScrap;
}

@end
