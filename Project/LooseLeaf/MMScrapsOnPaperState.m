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
#import "MMScrapContainerView.h"
#import "NSThread+BlockAdditions.h"
#import "UIView+Debug.h"
#import "Constants.h"

/**
 * similar to the MMPaperState, this object will
 * track the state for all scraps within a single page
 */
@implementation MMScrapsOnPaperState{
    BOOL isLoaded;
    BOOL isLoading;
    NSMutableArray* allScrapsForPage;
    BOOL hasEditsToSave;
}

@synthesize delegate;
@synthesize shouldShowShadows;
@synthesize hasEditsToSave;

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
                NSDictionary* allScrapStateInfo = [NSDictionary dictionaryWithContentsOfFile:scrapIDsPath];

                NSArray* scrapIDsOnPage = [allScrapStateInfo objectForKey:@"scrapsOnPageIDs"];
                scrapProps = [allScrapStateInfo objectForKey:@"allScrapProperties"];

                NSMutableArray* scrapPropsWithState = [NSMutableArray array];
                
                // load all the states async
                for(NSDictionary* scrapProperties in scrapProps){
                    NSString* scrapUUID = [scrapProperties objectForKey:@"uuid"];
                    NSLog(@"loading scrap %@ for page %@", scrapUUID, delegate.uuid);
                    MMScrapViewState* state = [[MMScrapViewState alloc] initWithUUID:scrapUUID andPaperState:self];
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
                            [allScrapsForPage addObject:scrap];
                            
                            if([scrapIDsOnPage containsObject:scrap.uuid]){
                                [self.delegate didLoadScrapOnPage:scrap];
                                [self showScrap:scrap];
                            }else{
                                [self.delegate didLoadScrapOffPage:scrap];
                            }
                            
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
                    [allScrapsForPage removeAllObjects];
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
        hasEditsToSave = NO;
        return [[MMImmutableScrapsOnPaperState alloc] initWithScrapIDsPath:scrapIDsPath andAllScraps:allScrapsForPage andScrapsOnPage:self.delegate.scrapsOnPaper];
    }
    return nil;
}

#pragma mark - Create Scraps

-(MMScrapView*) addScrapWithPath:(UIBezierPath*)path andRotation:(CGFloat)rotation andScale:(CGFloat)scale{
    if(![self isStateLoaded]){
        @throw [NSException exceptionWithName:@"ModifyingUnloadedScrapsOnPaperStateException" reason:@"cannot add scrap to unloaded ScrapsOnPaperState" userInfo:nil];
    }
    MMScrapView* newScrap = [[MMScrapView alloc] initWithBezierPath:path andScale:scale andRotation:rotation andPaperState:self];
    [allScrapsForPage addObject:newScrap];
    return newScrap;
}

#pragma mark - Manage Scraps

-(void) showScrap:(MMScrapView*)scrap atIndex:(NSUInteger)subviewIndex{
    [self showScrap:scrap];
    [scrap.superview insertSubview:scrap atIndex:subviewIndex];
}

-(void) showScrap:(MMScrapView*)scrap{
    CheckMainThread;
    if(scrap.state.scrapsOnPaperState != self){
        @throw [NSException exceptionWithName:@"ScrapAddedToWrongPageException" reason:@"This scrap was added to a page that doesn't own it" userInfo:nil];
    }
    @synchronized(delegate.scrapContainerView){
        [delegate.scrapContainerView addSubview:scrap];
    }
    [scrap setShouldShowShadow:delegate.isEditable];
    if(isLoaded){
        [scrap loadScrapStateAsynchronously:YES];
    }else{
        [scrap unloadState];
    }
}

-(void) hideScrap:(MMScrapView*)scrap{
    @synchronized(delegate.scrapContainerView){
        if(delegate.scrapContainerView == scrap.superview){
            [scrap setShouldShowShadow:NO];
            [scrap removeFromSuperview];
        }else{
            @throw [NSException exceptionWithName:@"MMScrapContainerException" reason:@"Removing scrap from a container that doesn't own it" userInfo:nil];
        }
    }
}

-(BOOL) isScrapVisible:(MMScrapView*)scrap{
    return [[delegate scrapsOnPaper] containsObject:scrap];
}

-(void) scrapVisibilityWasUpdated:(MMScrapView*)scrap{
    if(scrap.superview != delegate.scrapContainerView){
        debug_NSLog(@"scrap %@ is invisible, state loaded: %d", scrap.uuid, [self isStateLoaded] || isLoading);
    }else{
        debug_NSLog(@"scrap %@ is visible, state loaded: %d", scrap.uuid, [self isStateLoaded] || isLoading);
    }
    if([self isStateLoaded] || isLoaded){
        // something changed w/ scrap visibility
        hasEditsToSave = YES;
    }
}

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

-(MMScrapView*) mostRecentScrap{
    return [allScrapsForPage lastObject];
}

@end
