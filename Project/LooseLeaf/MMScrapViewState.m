//
//  MMScrapViewState.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/1/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapViewState.h"
#import "NSThread+BlockAdditions.h"
#import "MMLoadImageCache.h"
#import <JotUI/JotUI.h>
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMScrapBackgroundView.h"
#import "Constants.h"
#import "UIView+Debug.h"
#import "MMScrapViewState+Trash.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation MMScrapViewState{
    // scrap ID and UI
    NSString* uuid;
    NSString* scrapPath;
    UIView* contentView;
    UIImageView* thumbnailView;
    JotView* drawableView;
    
    // permanent state
    // this state is never unloaded and is
    // alive for the duration of this object
    UIBezierPath* bezierPath;
    
    // YES if our goal is to be loaded, NO otherwise
    BOOL targetIsLoadedState;
    // YES if we're currently loading our state, NO otherwise
    BOOL isLoadingState;
    
    // private vars
    NSString* scrapPropertiesPlistPath;
    NSString* scrapBezierPath;
    NSString* inkImageFile;
    NSString* thumbImageFile;
    NSString* drawableViewStateFile;
    NSString* backgroundFile;

    // helper vars
    CGSize originalSize;
    CGRect drawableBounds;
    
    // thumbnail
    MMDecompressImagePromise* activeThumbnailImage;
    
    // clipped background view
    UIView* clippedBackgroundView;
    
    // image background
    MMScrapBackgroundView* backingImageHolder;
    
    // lock to control threading
    NSLock* lock;
    
    // YES if the file exists at the path, NO
    // if it *might* exist
    BOOL fileExistsAtInkPath;
    BOOL fileExistsAtJotViewPlistPath;
    
    // the undoHash that our drawable view was
    // last saved at
    NSUInteger lastSavedUndoHash;
    
    BOOL targetIsLoadedThumbnail;
}

#pragma mark - Properties

@synthesize bezierPath;
@synthesize contentView;
@synthesize drawableBounds;
@synthesize delegate;
@synthesize uuid;
@synthesize scrapsOnPaperState;
@synthesize lastSavedUndoHash;

-(CGSize) originalSize{
    if(CGSizeEqualToSize(originalSize, CGSizeZero)){
        // performance optimization, only load it when asked for
        // and then cache it
        originalSize = self.bezierPath.bounds.size;
    }
    return originalSize;
}

#pragma mark - Dispatch Queue

// queue
static dispatch_queue_t importExportScrapStateQueue;

static const void *const kImportExportScrapStateQueueIdentifier = &kImportExportScrapStateQueueIdentifier;

+(dispatch_queue_t) importExportScrapStateQueue{
    @synchronized([MMScrapViewState class]){
        if(!importExportScrapStateQueue){
            importExportScrapStateQueue = dispatch_queue_create("com.milestonemade.looseleaf.importExportScrapStateQueue", DISPATCH_QUEUE_SERIAL);
            dispatch_queue_set_specific(importExportScrapStateQueue, kImportExportScrapStateQueueIdentifier, (void *)kImportExportScrapStateQueueIdentifier, NULL);
        }
        return importExportScrapStateQueue;
    }
}
+(BOOL) isImportExportScrapStateQueue{
    return dispatch_get_specific(kImportExportScrapStateQueueIdentifier) != NULL;
}

#pragma mark - Init

-(id) initWithUUID:(NSString*)_uuid andPaperState:(MMScrapCollectionState*)_scrapsOnPaperState{
    CheckMainThread;
    // save our UUID and scrapsOnPaperState, everything depends on these
    uuid = _uuid;
    scrapsOnPaperState = _scrapsOnPaperState;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:self.scrapPropertiesPlistPath] ||
       [[NSFileManager defaultManager] fileExistsAtPath:self.bundledScrapPropertiesPlistPath]){
        NSDictionary* properties = [NSDictionary dictionaryWithContentsOfFile:self.scrapPropertiesPlistPath];
        if(!properties){
            properties = [NSDictionary dictionaryWithContentsOfFile:self.bundledScrapPropertiesPlistPath];
        }
        if([properties objectForKey:@"bezierPath"]){
            bezierPath = [NSKeyedUnarchiver unarchiveObjectWithData:[properties objectForKey:@"bezierPath"]];
        }else{
            NSData* bezierData = [NSData dataWithContentsOfFile:[self scrapBezierPath]];
            if(!bezierData){
                bezierData = [NSData dataWithContentsOfFile:[self bundledScrapBezierPath]];
            }
            // bezier wasn't in the settings, so load it from
            // its own bezier file
            bezierPath = [NSKeyedUnarchiver unarchiveObjectWithData:bezierData];
        }
        
        NSUInteger lsuh = [[properties objectForKey:@"lastSavedUndoHash"] unsignedIntegerValue];
        
        MMScrapBackgroundView* backingView = [[MMScrapBackgroundView alloc] initWithImage:nil forScrapState:self];
        // now load the background image from disk, if any
        [backingView loadBackgroundFromDiskWithProperties:properties];
        
        return [self initWithUUID:uuid andBezierPath:bezierPath andBackgroundView:backingView andPaperState:_scrapsOnPaperState andLastSavedUndoHash:lsuh];
    }else{
        // we don't have a file that we should have, so don't load the scrap
        DebugLog(@"can't find file at %@ or %@", self.scrapPropertiesPlistPath, self.bundledScrapPropertiesPlistPath);
        return nil;
    }
    return self;
}

-(id) initWithUUID:(NSString*)_uuid andBezierPath:(UIBezierPath*)_path andPaperState:(MMScrapCollectionState*)_scrapsOnPaperState{
    return [self initWithUUID:_uuid andBezierPath:_path andBackgroundView:nil andPaperState:_scrapsOnPaperState andLastSavedUndoHash:0];
}

-(id) initWithUUID:(NSString*)_uuid andBezierPath:(UIBezierPath*)_path andBackgroundView:(MMScrapBackgroundView*)backingView andPaperState:(MMScrapCollectionState*)_scrapsOnPaperState andLastSavedUndoHash:(NSUInteger)lsuh{
    if(self = [super init]){
        
        // save our UUID, everything depends on this
        scrapsOnPaperState = _scrapsOnPaperState;
        uuid = _uuid;
        lock = [[NSLock alloc] init];
        lastSavedUndoHash = lsuh;

        if(!bezierPath){
            CGRect originalBounds = _path.bounds;
            [_path applyTransform:CGAffineTransformMakeTranslation(-originalBounds.origin.x + kScrapShadowBufferSize, -originalBounds.origin.y + kScrapShadowBufferSize)];
            bezierPath = _path;
            
            //save initial bezier path to disk
            // not the most elegant solution, but it works and is fast enough for now
            [[NSKeyedArchiver archivedDataWithRootObject:bezierPath] writeToFile:[self scrapBezierPath] atomically:YES];
        }
        if(!backingView){
            backingView = [[MMScrapBackgroundView alloc] initWithImage:nil forScrapState:self];
        }

        // find drawable view bounds
        drawableBounds = bezierPath.bounds;
        drawableBounds = CGRectInset(drawableBounds, -kScrapShadowBufferSize, -kScrapShadowBufferSize);
        drawableBounds.origin = CGPointMake(0, 0);
        
        // this content view will be used by the MMScrapView to show
        // the scrap's contents. we'll use this to swap between
        // a UIImageView that holds a cached image of the contents and
        // the editable JotView
        contentView = [[UIView alloc] initWithFrame:drawableBounds];
        contentView.opaque = YES;
        [contentView setClipsToBounds:YES];
        [contentView setBackgroundColor:[UIColor clearColor]];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // create our thumbnail view,
        // and load the actual thumbnail async
        thumbnailView = [[UIImageView alloc] initWithFrame:contentView.bounds];
        thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
        thumbnailView.clipsToBounds = YES;

        backingImageHolder = backingView;
        backingView.frame = contentView.bounds;
        backingImageHolder.frame = contentView.bounds;

        clippedBackgroundView = [[UIView alloc] initWithFrame:contentView.bounds];
        clippedBackgroundView.clipsToBounds = YES;
        clippedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        CAShapeLayer* backgroundColorLayer = [CAShapeLayer layer];
        [backgroundColorLayer setPath:bezierPath.CGPath];
        backgroundColorLayer.frame = backingImageHolder.bounds;
        clippedBackgroundView.layer.mask = backgroundColorLayer;
        [clippedBackgroundView addSubview:backingImageHolder];

        [contentView addSubview:clippedBackgroundView];
        [contentView addSubview:thumbnailView];

    }
    return self;
}

-(int) fullByteSize{
    return drawableViewState.fullByteSize + backingImageHolder.fullByteSize;
}

-(void) setScrapsOnPaperState:(MMScrapCollectionState *)_scrapsOnPaperState{
    [[MMLoadImageCache sharedInstance] clearCacheForPath:self.thumbImageFile];
    [[MMLoadImageCache sharedInstance] clearCacheForPath:self.bundledThumbImageFile];
    // reset all path caches
    scrapsOnPaperState = _scrapsOnPaperState;
    scrapPath = nil;
    scrapPropertiesPlistPath = nil;
    inkImageFile = nil;
    thumbImageFile = nil;
    drawableViewStateFile = nil;
    backgroundFile = nil;
}

#pragma mark - Preview

-(UIImage*) oneOffLoadedThumbnailImage{
    UIImage* cachedImage = [[MMLoadImageCache sharedInstance] imageAtPath:self.thumbImageFile];
    if(!cachedImage){
        cachedImage = [[MMLoadImageCache sharedInstance] imageAtPath:self.bundledThumbImageFile];
    }
    return cachedImage;
}

-(void) loadCachedScrapPreview{
    DebugLog(@"loading thumb for %@", self.uuid);
    [self loadCachedScrapPreviewAsynchronously:YES];
}

-(void) loadCachedScrapPreviewAsynchronously:(BOOL)async{
//    DebugLog(@"asking to load preview %@", self.uuid);
    @synchronized(thumbnailView){
        if(activeThumbnailImage){
            // already loading
            return;
        }
        targetIsLoadedThumbnail = YES;
    }
    if(!async){
        UIImage* cachedImage = [[MMLoadImageCache sharedInstance] imageAtPath:self.thumbImageFile];
        if(!cachedImage){
            cachedImage = [[MMLoadImageCache sharedInstance] imageAtPath:self.bundledThumbImageFile];
            if(cachedImage){
                // if we have a bundled image but not a non-bundled image,
                // then we need to set the non-bundled so that
                // loading next time w/ a primed cache will get
                // the bundled version on the non-bundled path
                // https://github.com/adamwulf/loose-leaf/issues/1100
                [[MMLoadImageCache sharedInstance] updateCacheForPath:self.thumbImageFile toImage:cachedImage];
            }
        }
        [self setActiveThumbnailImage:[[MMDecompressImagePromise alloc] initForDecompressedImage:cachedImage andDelegate:self]];
    }else if([[MMLoadImageCache sharedInstance] containsPathInCache:self.thumbImageFile]){
        // load if we can
        UIImage* cachedImage = [[MMLoadImageCache sharedInstance] imageAtPath:self.thumbImageFile];
        [self setActiveThumbnailImage:[[MMDecompressImagePromise alloc] initForDecompressedImage:cachedImage andDelegate:self]];
    }else{
        // don't load from disk on the main thread.
        dispatch_async([MMScrapViewState importExportScrapStateQueue], ^{
            [lock lock];
            @autoreleasepool {
                @synchronized(thumbnailView){
                    if(targetIsLoadedThumbnail){
                        UIImage* thumb = [[MMLoadImageCache sharedInstance] imageAtPath:self.thumbImageFile];
                        if(!thumb){
                            thumb = [[MMLoadImageCache sharedInstance] imageAtPath:self.bundledThumbImageFile];
                        }
                        [self setActiveThumbnailImage:[[MMDecompressImagePromise alloc] initForImage:thumb andDelegate:self]];
                    }else{
                        NSLog(@"target was unloaded afterall %@", self.uuid);
                    }
                }
            }
            [lock unlock];
        });
    }
}

-(void) didDecompressImage:(MMDecompressImagePromise*)promise{
    CheckMainThread;
    if(promise == activeThumbnailImage){
        @synchronized(thumbnailView){
            if(targetIsLoadedThumbnail){
                [self setActiveThumbnailImage:promise];
            }else{
                [self setActiveThumbnailImage:nil];
            }
        }
    }else{
        // we don't care if its not the current promise
    }
}

-(void) unloadCachedScrapPreview{
    @synchronized(thumbnailView){
        if(!targetIsLoadedThumbnail){
            // already unloaded
            return;
        }
        targetIsLoadedThumbnail = NO;
        if(activeThumbnailImage){
            DebugLog(@"unload thumb for %@", self.uuid);
            [activeThumbnailImage cancel];
            activeThumbnailImage = nil;
        }
    }
    [self setActiveThumbnailImage:nil];
    dispatch_async(dispatch_get_background_queue(), ^{
        @synchronized(thumbnailView){
            if(!targetIsLoadedThumbnail){
                [[MMLoadImageCache sharedInstance] clearCacheForPath:self.thumbImageFile];
                [[MMLoadImageCache sharedInstance] clearCacheForPath:self.bundledThumbImageFile];
            }
        }
    });
}

#pragma mark - Backing Image

-(MMScrapBackgroundView*) backgroundView{
    return backingImageHolder;
}
-(void) setBackgroundView:(MMScrapBackgroundView*)backgroundView{
    if(backingImageHolder){
        [backingImageHolder removeFromSuperview];
    }
    backingImageHolder = backgroundView;
    if(backingImageHolder){
        backingImageHolder.frame = contentView.bounds;
        [clippedBackgroundView addSubview:backingImageHolder];
    }
}


-(CGPoint) currentCenterOfScrapBackground{
    return backingImageHolder.backingContentView.center;
}

#pragma mark - State Saving and Loading

-(void) saveScrapStateToDisk:(void(^)(BOOL hadEditsToSave))doneSavingBlock{
    
    // block to help save properties to a plist file
    void(^savePropertiesToDisk)(NSUInteger, UIBezierPath*, MMScrapBackgroundView* backgroundInfo, NSString* pathToSave) = ^(NSUInteger lsuh, UIBezierPath* bezierPathToWriteToDisk, MMScrapBackgroundView* backgroundInfo, NSString* pathToSave){

        BOOL savedBezierOk = YES;
        if(![[NSFileManager defaultManager] fileExistsAtPath:[self scrapBezierPath]]){
            savedBezierOk = [[NSKeyedArchiver archivedDataWithRootObject:bezierPathToWriteToDisk] writeToFile:[self scrapBezierPath] atomically:YES];
        }
        
        // this will save the properties for the scrap
        // to disk, including the path and background information
        NSMutableDictionary* savedProperties = [NSMutableDictionary dictionary];
        // add in properties from background
        [savedProperties setObject:[NSNumber numberWithUnsignedInteger:lsuh] forKey:@"lastSavedUndoHash"];
        NSDictionary* backgroundProps = [backgroundInfo saveBackgroundToDisk];
        [savedProperties addEntriesFromDictionary:backgroundProps];
        // save properties to disk
        if(!savedBezierOk || ![savedProperties writeToFile:pathToSave atomically:YES]){
            if(!self.isForgetful){
                DebugLog(@"couldn't save properties/bezier! %p", self);
            }
        }
    };
    
    
//    DebugLog(@"asking to save scrap: %@", self.uuid);
    if(drawableViewState && ([drawableViewState hasEditsToSave] || backingImageHolder.backingViewHasChanged)){
        dispatch_async([MMScrapViewState importExportScrapStateQueue], ^{
            @autoreleasepool {
                if(self.isForgetful){
//                    DebugLog(@"forget: %@ skipping scrap state save1", self.uuid);
                    doneSavingBlock(NO);
                    return;
                }
                [lock lock];
                [JotViewStateProxy shouldPrintHasEdits:YES];
//                DebugLog(@"(%@) checking edits", uuid);
//                DebugLog(@"(%@) saving with edits: %d %d", uuid, [drawableViewState hasEditsToSave], backingImageHolder.backingViewHasChanged);
                [JotViewStateProxy shouldPrintHasEdits:NO];
                if(drawableViewState && ([drawableViewState hasEditsToSave] || backingImageHolder.backingViewHasChanged)){
                    __block BOOL doneSavingBlockResult = YES;
                    dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
                    [NSThread performBlockOnMainThread:^{
                        @autoreleasepool {
                            if(self.isForgetful){
                                DebugLog(@"forget: %@ skipping scrap state save2", self.uuid);
                                doneSavingBlockResult = NO;
                                dispatch_semaphore_signal(sema1);
                                return;
                            }
                            if(drawableView && ([drawableViewState hasEditsToSave] || backingImageHolder.backingViewHasChanged)){
//                                DebugLog(@"(%@) saving edits2: %d %d", uuid, [drawableViewState hasEditsToSave], backingImageHolder.backingViewHasChanged);

                                if([drawableViewState hasEditsToSave]){
//                                    DebugLog(@"(%@) saving strokes: %d", uuid, [drawableViewState hasEditsToSave]);
                                    // now export the drawn content. this will create an immutable state
                                    // object and export in the background. this means that everything at this
                                    // instant on the thread will be synced to the content in this drawable view
                                    [drawableView exportImageTo:self.inkImageFile andThumbnailTo:self.thumbImageFile andStateTo:self.drawableViewStateFile withThumbnailScale:.3
                                                     onComplete:^(UIImage* ink, UIImage* thumb, JotViewImmutableState* state){
//                                        DebugLog(@"saved scrap %@ ink to %@", self.uuid, self.inkImageFile);
//                                        DebugLog(@"saved scrap %@ thumb to %@", self.uuid, self.thumbImageFile);
                                        if(self.isForgetful){
//                                            DebugLog(@"forget: %@ scrap state skipping update after jotview save", self.uuid);
                                        }else if(state){
                                            [[MMLoadImageCache sharedInstance] updateCacheForPath:self.thumbImageFile toImage:thumb];
                                            [self setActiveThumbnailImage:[[MMDecompressImagePromise alloc] initForDecompressedImage:thumb andDelegate:self]];
                                            [drawableViewState wasSavedAtImmutableState:state];
                                            
                                            // save path
                                            // this needs to be saved at the exact same time as the drawable view
                                            // so that we can guarentee that there is no race condition
                                            // for saving state vs content
                                            lastSavedUndoHash = state.undoHash;
                                            savePropertiesToDisk(lastSavedUndoHash, bezierPath, backingImageHolder, self.scrapPropertiesPlistPath);

//                                            DebugLog(@"(%@) scrap saved at: %d with thumb: %d", uuid, (int)state.undoHash, (int)thumb);
                                        }
                                        dispatch_semaphore_signal(sema1);
                                    }];
                                }else if(backingImageHolder.backingViewHasChanged){
//                                    DebugLog(@"(%@) no stroke edits, only saving background view: %d", uuid, [drawableViewState hasEditsToSave]);
                                    // if we dont' have any pen edits in the drawableViewState,
                                    // but we do have background changes to save
                                    lastSavedUndoHash = drawableViewState.undoHash;
                                    savePropertiesToDisk(lastSavedUndoHash, bezierPath, backingImageHolder, self.scrapPropertiesPlistPath);
                                    dispatch_semaphore_signal(sema1);
                                }else{
                                    // nothing new to save
//                                    DebugLog(@"(%@) nothing new to save: %d %d", uuid, drawableViewState.hasEditsToSave, backingImageHolder.backingViewHasChanged);
                                    dispatch_semaphore_signal(sema1);
                                }
                            }else{
                                // nothing new to save
                                if(!drawableView && ![drawableViewState hasEditsToSave]){
//                                    DebugLog(@"(%@) no drawable view or edits", uuid);
                                }else if(!drawableView){
//                                    DebugLog(@"(%@) no drawable view", uuid);
                                }else if(![drawableViewState hasEditsToSave]){
//                                    DebugLog(@"(%@) no edits to save in state", uuid);
                                }
                                // was asked to save, but we were asked to save
                                // multiple times extremely quickly, so just signal
                                // that we're done
                                dispatch_semaphore_signal(sema1);
                            }
                        }
                    }];
                    dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
//                    dispatch_release(sema1); ARC handles this
//                    DebugLog(@"(%@) done saving scrap: %d", uuid, (int)drawableView);
                    if(doneSavingBlock) doneSavingBlock(doneSavingBlockResult);
                }else{
                    // sometimes, this method is called in very quick succession.
                    // that means that the first time it runs and saves, it'll
                    // finish all of the export and drawableViewState will be nil
                    // next time it runs. so we double check our save state to determine
                    // if in fact we still need to save or not
//                    DebugLog(@"(%@) no edits to save in state2", uuid);
                    if(doneSavingBlock) doneSavingBlock(NO);
                }
                [lock unlock];
            }
        });
    }else{
        if(doneSavingBlock) doneSavingBlock(NO);
//        DebugLog(@"(%@) no edits to save in state3", uuid);
    }
}


-(void) loadScrapStateAsynchronously:(BOOL)async{
    @synchronized(self){
        // if we're already loading our
        // state, then bail early
        // if we already have our state,
        // then bail early
        if((async && isLoadingState) || drawableViewState){
            // if we're already loading async, and asked to load
            // async again, then bail. or, if we're already
            // loaded, then bail
//            DebugLog(@"(%@) already loaded", uuid);
            return;
        }
        if(targetIsLoadedState){
            // this is allowed. it will load either
            // async or sync, and the second finishing
            // load will skip itself after seeing
            // an already loaded state
//            DebugLog(@"duplicate load");
        }
        
        targetIsLoadedState = YES;
        isLoadingState = YES;
    }
//    DebugLog(@"(%@) loading scrap state", uuid);

//    DebugLog(@"(%@) loading1: %d %d", uuid, targetIsLoadedState, isLoadingState);
    void (^loadBlock)() = ^(void) {
        [self loadCachedScrapPreviewAsynchronously:NO];
        @autoreleasepool {
            @synchronized(self){
                if(!targetIsLoadedState){
                    return;
                }
            }
            //#ifdef DEBUG
            //        DebugLog(@"sleeping for %@", self.uuid);
            //        [NSThread sleepForTimeInterval:5];
            //        DebugLog(@"woke up for %@", self.uuid);
            //#endif
            @autoreleasepool {
                //            DebugLog(@"(%@) loading2: %d %d", uuid, targetIsLoadedState, isLoadingState);
                // load state, if we have any.
                __block BOOL goalIsLoaded = NO;
                [NSThread performBlockOnMainThreadSync:^{
                    @synchronized(self){
                        goalIsLoaded = targetIsLoadedState;
                    }
                    if([self isScrapStateLoaded]){
                        // scrap state was loaded synchronously while
                        // this block was pending to finish a load
                        //                    DebugLog(@"bailed on async load, it finished sync ahead of us");
                        return;
                    }
                    @synchronized(self){
                        if(!goalIsLoaded){
                            // we don't need to load after all, so don't build
                            // any drawable view
                            DebugLog(@"saved building JotView we didn't need");
                        }else{
                            // add our drawable view to our contents
                            drawableView = [[JotView alloc] initWithFrame:drawableBounds];
                        }
                    }
                }];
                [lock lock];
                // can't lock before the call to main thread or any
                // synchronous loads from the main thread could
                // deadlock us
                if([self isScrapStateLoaded]){
                    // scrap state was loaded synchronously while
                    // this block was pending to finish a load
                    //                DebugLog(@"bailed on async load, it finished sync ahead of us");
                    [lock unlock];
                    return;
                }
                if(!goalIsLoaded){
                    DebugLog(@"saved building JotViewStateProxy we didn't need");
                }else{
                    // load drawable view information here
                    drawableViewState = [[JotViewStateProxy alloc] initWithDelegate:self];
                    [drawableViewState loadJotStateAsynchronously:async
                                                         withSize:drawableView.pagePtSize
                                                         andScale:drawableView.scale
                                                       andContext:drawableView.context
                                                 andBufferManager:[[JotBufferManager alloc] init]];
                }
                [lock unlock];
            }
        }
    };

    if(async){
        dispatch_async([MMScrapViewState importExportScrapStateQueue], loadBlock);
    }else{
        loadBlock();
    }
}

-(void) unloadStateButKeepThumbnailIfAny{
    [self unloadStateIncludingPreview:NO];
}

-(void) unloadState{
    [self unloadStateIncludingPreview:YES];
}

-(void) unloadStateIncludingPreview:(BOOL)unloadPreviewToo{
    @synchronized(self){
        targetIsLoadedState = NO;
    }
    if(unloadPreviewToo){
        [self unloadCachedScrapPreview];
    }
    dispatch_async([MMScrapViewState importExportScrapStateQueue], ^{
        @autoreleasepool {
            [lock lock];
            BOOL hasEdits = NO;
            @synchronized(self){
                // I don't want to synchronize this whole method, because
                // the dispatch_wait() in the else clause could deadlock
                // with the main thread, which could be waiting on our
                // @sync(self);
                hasEdits = drawableViewState && [drawableViewState isStateLoaded] && [drawableViewState hasEditsToSave];
            }
            if(hasEdits){
//                    DebugLog(@"(%@) unload failed, will retry", uuid);
                // we want to unload, but we're not saved.
                // save, then try to unload again
                dispatch_async([MMScrapViewState importExportScrapStateQueue], ^{
                    @autoreleasepool {
                        [self saveScrapStateToDisk:nil];
                    }
                });
                dispatch_async([MMScrapViewState importExportScrapStateQueue], ^{
                    @autoreleasepool {
                        [self unloadState];
                    }
                });
            }else{
//                    DebugLog(@"(%@) unload success", uuid);
                BOOL needsToRemoveDrawableView = NO;
                @synchronized(self){
                    targetIsLoadedState = NO;
                    needsToRemoveDrawableView = !isLoadingState && drawableViewState;
                }
                if(needsToRemoveDrawableView){
                    dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
                    [NSThread performBlockOnMainThread:^{
                        [drawableView removeFromSuperview];
                        [[JotTrashManager sharedInstance] addObjectToDealloc:drawableView];
                        [[JotTrashManager sharedInstance] addObjectToDealloc:drawableViewState];
                        drawableViewState = nil;
                        drawableView = nil;
                        thumbnailView.hidden = NO;
                        dispatch_semaphore_signal(sema1);
                    }];
                    dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
//                        dispatch_release(sema1); ARC handles this
                }
            }
            [lock unlock];
        }
    });
}

-(BOOL) isScrapStateLoaded{
    return drawableViewState != nil && [drawableViewState isStateLoaded];
}

-(BOOL) isScrapStateLoading{
    return isLoadingState;
}

-(BOOL) hasEditsToSave{
    return self.isScrapStateLoaded && drawableView && drawableViewState && drawableViewState.hasEditsToSave;
}

// returns the loaded thumbnail image,
// if any
-(UIImage*) activeThumbnailImage{
    @synchronized(self){
        return activeThumbnailImage.image;
    }
}

-(void) setActiveThumbnailImage:(MMDecompressImagePromise*)img{
    BOOL needsDispatch = NO;
    @synchronized(self){
        if(activeThumbnailImage != img || activeThumbnailImage.image != thumbnailView.image){
            activeThumbnailImage = img;
            if(!activeThumbnailImage || activeThumbnailImage.isDecompressed){
                needsDispatch = YES;
            }
        }
    }
    if(needsDispatch){
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!activeThumbnailImage || activeThumbnailImage.isDecompressed){
                thumbnailView.image = activeThumbnailImage.image;
            }
        });
    }
}


#pragma mark - Paths

#pragma mark Public

-(NSString*) pathForScrapAssets{
    if(!scrapPath){
        scrapPath = [scrapsOnPaperState directoryPathForScrapUUID:self.uuid];
        [NSFileManager ensureDirectoryExistsAtPath:scrapPath];
    }
    return scrapPath;
}

#pragma mark Private

-(NSString*)scrapPropertiesPlistPath{
    if(!scrapPropertiesPlistPath){
        scrapPropertiesPlistPath = [self.pathForScrapAssets stringByAppendingPathComponent:[@"info" stringByAppendingPathExtension:@"plist"]];
    }
    return scrapPropertiesPlistPath;
}

-(NSString*)scrapBezierPath{
    if(!scrapBezierPath){
        scrapBezierPath = [self.pathForScrapAssets stringByAppendingPathComponent:[@"bezier" stringByAppendingPathExtension:@"dat"]];
    }
    return scrapBezierPath;
}

-(NSString*)inkImageFile{
    if(!inkImageFile){
        inkImageFile = [self.pathForScrapAssets stringByAppendingPathComponent:[@"ink" stringByAppendingPathExtension:@"png"]];
    }
    return inkImageFile;
}

-(NSString*) thumbImageFile{
    if(!thumbImageFile){
        thumbImageFile = [self.pathForScrapAssets stringByAppendingPathComponent:[@"thumb" stringByAppendingPathExtension:@"png"]];
    }
    return thumbImageFile;
}

-(NSString*) drawableViewStateFile{
    if(!drawableViewStateFile){
        drawableViewStateFile = [self.pathForScrapAssets stringByAppendingPathComponent:[@"state" stringByAppendingPathExtension:@"plist"]];
    }
    return drawableViewStateFile;
}

-(NSString*) bundledScrapPropertiesPlistPath{
    return [[scrapsOnPaperState bundledDirectoryPathForScrapUUID:self.uuid] stringByAppendingPathComponent:[@"info" stringByAppendingPathExtension:@"plist"]];
}

-(NSString*)bundledScrapBezierPath{
    return [[scrapsOnPaperState bundledDirectoryPathForScrapUUID:self.uuid] stringByAppendingPathComponent:[@"bezier" stringByAppendingPathExtension:@"dat"]];
}

-(NSString*) bundledInkImageFile{
    return [[scrapsOnPaperState bundledDirectoryPathForScrapUUID:self.uuid] stringByAppendingPathComponent:[@"ink" stringByAppendingPathExtension:@"png"]];
}

-(NSString*) bundledThumbImageFile{
    return [[scrapsOnPaperState bundledDirectoryPathForScrapUUID:self.uuid] stringByAppendingPathComponent:[@"thumb" stringByAppendingPathExtension:@"png"]];
}

-(NSString*) bundledDrawableViewStateFile{
    return [[scrapsOnPaperState bundledDirectoryPathForScrapUUID:self.uuid] stringByAppendingPathComponent:[@"state" stringByAppendingPathExtension:@"plist"]];
}

#pragma mark - OpenGL

-(void) addElements:(NSArray*)elements{
    if(!drawableViewState){
        // https://github.com/adamwulf/loose-leaf/issues/258
        DebugLog(@"trying to draw on an unloaded scrap");
    }
    [drawableView addElements:elements];
}
-(void) addUndoLevelAndFinishStroke{
    [drawableView addUndoLevelAndFinishStroke];
}

-(JotView*) drawableView{
    return drawableView;
}

-(JotGLTexture*) generateTexture{
    return [drawableView generateTexture];
}

/**
 * this method allows us to stamp an arbitrary texture onto our drawable view, using the input
 * texture coordinates. the size of the stamp is always assumed to be our entire view.
 */
-(void) importTexture:(JotGLTexture*)texture atP1:(CGPoint)p1 andP2:(CGPoint)p2 andP3:(CGPoint)p3 andP4:(CGPoint)p4 withTextureSize:(CGSize)textureSize{
    CGSize roundedDrawableBounds = self.drawableBounds.size;
    roundedDrawableBounds.width = ceilf(roundedDrawableBounds.width);
    roundedDrawableBounds.height = ceilf(roundedDrawableBounds.height);
    [drawableView drawBackingTexture:texture atP1:(CGPoint)p1 andP2:(CGPoint)p2 andP3:(CGPoint)p3 andP4:(CGPoint)p4 clippingPath:self.bezierPath
                     andClippingSize:roundedDrawableBounds withTextureSize:textureSize];
    [drawableView forceAddEmptyStroke];
}

#pragma mark - JotViewStateProxyDelegate

// the state for the page and/or scrap might be a default
// new user tutorial page. if that's the case, we want to
// load the initial state from the bundle. pages will always
// save to the user's document's directory.
//
// this method will make sure that if the user loads a default
// page from the bundle, saves it, then reloads it -> then it
// will be loaded from the documents directory instead of
// reloaded from scratch from the bundle
-(NSString*) jotViewStateInkPath{
    if(fileExistsAtInkPath || [[NSFileManager defaultManager] fileExistsAtPath:self.inkImageFile]){
        fileExistsAtInkPath = YES;
        return self.inkImageFile;
    }else{
        return self.bundledInkImageFile;
    }
}

-(NSString*) jotViewStatePlistPath{
    if(fileExistsAtJotViewPlistPath || [[NSFileManager defaultManager] fileExistsAtPath:self.drawableViewStateFile]){
        fileExistsAtJotViewPlistPath = YES;
        return self.drawableViewStateFile;
    }else{
        return self.bundledDrawableViewStateFile;
    }
}

-(void) didLoadState:(JotViewStateProxy *)state{
    @synchronized(self){
        if(!targetIsLoadedState){
//            DebugLog(@"loaded state we didn't need");
            if(drawableViewState){
                [[JotTrashManager sharedInstance] addObjectToDealloc:drawableViewState];
            }
            if(drawableView){
                [[JotTrashManager sharedInstance] addObjectToDealloc:drawableView];
            }
            drawableViewState = nil;
            drawableView = nil;
            @synchronized(self){
                // signal that we're done loading state
                isLoadingState = NO;
            }
        }else{
            [NSThread performBlockOnMainThread:^{
                @synchronized(self){
                    isLoadingState = NO;
                    if(targetIsLoadedState){
                        [contentView addSubview:drawableView];
                        thumbnailView.hidden = YES;
                        if(drawableViewState){
                            [drawableView loadState:drawableViewState];
                        }
                        
                        // nothing changed in our goals since we started
                        // to load state, so notify our delegate
                        [self.delegate didLoadScrapViewState:self];
//                        DebugLog(@"(%@) loaded scrap state", uuid);
                    }else{
                        // when loading state, we were actually
                        // told that we didn't really need the
                        // state after all, so just throw it away :(
                        if(drawableViewState){
                            [[JotTrashManager sharedInstance] addObjectToDealloc:drawableViewState];
                        }
                        if(drawableView){
                            [[JotTrashManager sharedInstance] addObjectToDealloc:drawableView];
                        }
                        drawableViewState = nil;
                        drawableView = nil;
                    }
                }
            }];
        }
    }
}

-(void) didUnloadState:(JotViewStateProxy *)state{
//    DebugLog(@"(%@) unloaded scrap state", uuid);
    // noop
}

-(void) reloadBackgroundView{
    NSDictionary* properties = [NSDictionary dictionaryWithContentsOfFile:self.scrapPropertiesPlistPath];
    MMScrapBackgroundView* replacementBackgroundView = [[MMScrapBackgroundView alloc] initWithImage:nil forScrapState:self];
    // now load the background image from disk, if any
    [replacementBackgroundView loadBackgroundFromDiskWithProperties:properties];
    [self setBackgroundView:replacementBackgroundView];
    
    UIImage* thumb = [[MMLoadImageCache sharedInstance] imageAtPath:self.thumbImageFile];
    [self setActiveThumbnailImage:[[MMDecompressImagePromise alloc] initForDecompressedImage:thumb andDelegate:self]];
}

#pragma mark - dealloc

-(void) dealloc{
    if(self.isScrapStateLoaded){
        if(drawableView){
            [[JotTrashManager sharedInstance] addObjectToDealloc:drawableView];
        }
        if(drawableViewState){
            [[JotTrashManager sharedInstance] addObjectToDealloc:drawableViewState];
        }
    }
//    DebugLog(@"scrap state (%@) dealloc", uuid);
    [[MMLoadImageCache sharedInstance] clearCacheForPath:self.thumbImageFile];
//    dispatch_release(importExportScrapStateQueue); ARC handles this
//    importExportScrapStateQueue = nil;
}

@end
