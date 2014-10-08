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
#import <DrawKit-iOS/DrawKit-iOS.h>
#import <JotUI/JotUI.h>
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMScrapBackgroundView.h"
#import "Constants.h"
#import "UIView+Debug.h"
#import "MMScrapViewState+Trash.h"

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
    NSString* inkImageFile;
    NSString* thumbImageFile;
    NSString* drawableViewStateFile;
    NSString* backgroundFile;

    // helper vars
    CGSize originalSize;
    CGRect drawableBounds;
    
    // thumbnail
    UIImage* activeThumbnailImage;
    
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

+(dispatch_queue_t) importExportScrapStateQueue{
    @synchronized([MMScrapViewState class]){
        if(!importExportScrapStateQueue){
            importExportScrapStateQueue = dispatch_queue_create("com.milestonemade.looseleaf.importExportScrapStateQueue", DISPATCH_QUEUE_SERIAL);
        }
        return importExportScrapStateQueue;
    }
}

#pragma mark - Init

-(id) initWithUUID:(NSString*)_uuid andPaperState:(MMScrapCollectionState*)_scrapsOnPaperState{
    // save our UUID and scrapsOnPaperState, everything depends on these
    uuid = _uuid;
    scrapsOnPaperState = _scrapsOnPaperState;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:self.scrapPropertiesPlistPath] ||
       [[NSFileManager defaultManager] fileExistsAtPath:self.bundledScrapPropertiesPlistPath]){
        NSDictionary* properties = [NSDictionary dictionaryWithContentsOfFile:self.scrapPropertiesPlistPath];
        if(!properties){
            properties = [NSDictionary dictionaryWithContentsOfFile:self.bundledScrapPropertiesPlistPath];
        }
        bezierPath = [NSKeyedUnarchiver unarchiveObjectWithData:[properties objectForKey:@"bezierPath"]];
        NSUInteger lsuh = [[properties objectForKey:@"lastSavedUndoHash"] unsignedIntegerValue];
        
        MMScrapBackgroundView* backingView = [[MMScrapBackgroundView alloc] initWithImage:nil forScrapState:self];
        // now load the background image from disk, if any
        [backingView loadBackgroundFromDiskWithProperties:properties];
        
        return [self initWithUUID:uuid andBezierPath:bezierPath andBackgroundView:backingView andPaperState:_scrapsOnPaperState andLastSavedUndoHash:lsuh];
    }else{
        // we don't have a file that we should have, so don't load the scrap
        NSLog(@"can't find file at %@ or %@", self.scrapPropertiesPlistPath, self.bundledScrapPropertiesPlistPath);
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
            NSMutableDictionary* savedProperties = [NSMutableDictionary dictionary];
            [savedProperties setObject:[NSKeyedArchiver archivedDataWithRootObject:bezierPath] forKey:@"bezierPath"];
            [savedProperties writeToFile:self.scrapPropertiesPlistPath atomically:YES];
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
        [contentView setClipsToBounds:YES];
        [contentView setBackgroundColor:[UIColor clearColor]];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // create our thumbnail view,
        // and load the actual thumbnail async
        thumbnailView = [[UIImageView alloc] initWithFrame:contentView.bounds];
        thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
        thumbnailView.clipsToBounds = YES;
        thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        thumbnailView.frame = contentView.bounds;

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

        if([[MMLoadImageCache sharedInstance] containsPathInCache:self.thumbImageFile]){
            // load if we can
            [self setActiveThumbnailImage:[[MMLoadImageCache sharedInstance] imageAtPath:self.thumbImageFile]];
        }else{
            // don't load from disk on the main thread.
            dispatch_async([MMScrapViewState importExportScrapStateQueue], ^{
                [lock lock];
                @autoreleasepool {
                    UIImage* thumb = [[MMLoadImageCache sharedInstance] imageAtPath:self.thumbImageFile];
                    if(!thumb){
                        thumb = [[MMLoadImageCache sharedInstance] imageAtPath:self.bundledThumbImageFile];
                    }
                    [self setActiveThumbnailImage:thumb];
                }
                [lock unlock];
            });
        }
    }
    return self;
}

-(int) fullByteSize{
    return drawableViewState.fullByteSize + backingImageHolder.fullByteSize;
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
    void(^savePropertiesToDisk)(NSUInteger, UIBezierPath*, MMScrapBackgroundView* backgroundInfo, NSString* pathToSave) = ^(NSUInteger lsuh, UIBezierPath* bezierPathForProperties, MMScrapBackgroundView* backgroundInfo, NSString* pathToSave){
        // this will save the properties for the scrap
        // to disk, including the path and background information
        NSMutableDictionary* savedProperties = [NSMutableDictionary dictionary];
        [savedProperties setObject:[NSKeyedArchiver archivedDataWithRootObject:bezierPathForProperties] forKey:@"bezierPath"];
        // add in properties from background
        [savedProperties setObject:[NSNumber numberWithUnsignedInteger:lsuh] forKey:@"lastSavedUndoHash"];
        NSDictionary* backgroundProps = [backgroundInfo saveBackgroundToDisk];
        [savedProperties addEntriesFromDictionary:backgroundProps];
        // save properties to disk
        if(![savedProperties writeToFile:pathToSave atomically:YES]){
            if(!self.isForgetful){
                NSLog(@"couldn't save properties! %p", self);
            }
        }
    };
    
    
    if(drawableViewState && ([drawableViewState hasEditsToSave] || backingImageHolder.backingViewHasChanged)){
        dispatch_async([MMScrapViewState importExportScrapStateQueue], ^{
            if(self.isForgetful){
                NSLog(@"forget: skipping scrap state save1");
                return;
            }
            @autoreleasepool {
                [lock lock];
//                NSLog(@"(%@) saving with background: %d %d", uuid, (int)drawableView, backingViewHasChanged);
                if(drawableViewState && ([drawableViewState hasEditsToSave] || backingImageHolder.backingViewHasChanged)){
                    dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
                    [NSThread performBlockOnMainThread:^{
                        @autoreleasepool {
                            if(self.isForgetful){
                                NSLog(@"forget: skipping scrap state save2");
                                return;
                            }
                            if(drawableView && ([drawableViewState hasEditsToSave] || backingImageHolder.backingViewHasChanged)){
//                                NSLog(@"(%@) saving background: %d", uuid, backingViewHasChanged);

                                if([drawableViewState hasEditsToSave]){
//                                    NSLog(@"(%@) saving strokes: %d", uuid, backingViewHasChanged);
                                    // now export the drawn content. this will create an immutable state
                                    // object and export in the background. this means that everything at this
                                    // instant on the thread will be synced to the content in this drawable view
                                    [drawableView exportImageTo:self.inkImageFile andThumbnailTo:self.thumbImageFile andStateTo:self.drawableViewStateFile onComplete:^(UIImage* ink, UIImage* thumb, JotViewImmutableState* state){
                                        if(self.isForgetful){
                                            NSLog(@"forget: scrap state skipping update after jotview save");
                                        }else if(state){
                                            [[MMLoadImageCache sharedInstance] updateCacheForPath:self.thumbImageFile toImage:thumb];
                                            [self setActiveThumbnailImage:thumb];
                                            [drawableViewState wasSavedAtImmutableState:state];
                                            
                                            // save path
                                            // this needs to be saved at the exact same time as the drawable view
                                            // so that we can guarentee that there is no race condition
                                            // for saving state vs content
                                            lastSavedUndoHash = state.undoHash;
                                            savePropertiesToDisk(lastSavedUndoHash, bezierPath, backingImageHolder, self.scrapPropertiesPlistPath);

//                                            NSLog(@"(%@) scrap saved at: %d with thumb: %d", uuid, (int)state.undoHash, (int)thumb);
                                        }
                                        dispatch_semaphore_signal(sema1);
                                    }];
                                }else if(backingImageHolder.backingViewHasChanged){
                                    // if we dont' have any pen edits in the drawableViewState,
                                    // but we do have background changes to save
                                    lastSavedUndoHash = drawableViewState.undoHash;
                                    savePropertiesToDisk(lastSavedUndoHash, bezierPath, backingImageHolder, self.scrapPropertiesPlistPath);
                                    dispatch_semaphore_signal(sema1);
                                }else{
                                    // nothing new to save
//                                    NSLog(@"(%@) skipped saving strokes: %d", uuid, backingViewHasChanged);
                                    dispatch_semaphore_signal(sema1);
                                }
                            }else{
                                // nothing new to save
//                                if(!drawableView && ![drawableViewState hasEditsToSave]){
//                                    NSLog(@"(%@) no drawable view or edits", uuid);
//                                }else if(!drawableView){
//                                    NSLog(@"(%@) no drawable view", uuid);
//                                }else if(![drawableViewState hasEditsToSave]){
//                                    NSLog(@"(%@) no edits to save in state", uuid);
//                                }
                                // was asked to save, but we were asked to save
                                // multiple times extremely quickly, so just signal
                                // that we're done
                                dispatch_semaphore_signal(sema1);
                            }
                        }
                    }];
                    dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
//                    dispatch_release(sema1); ARC handles this
//                    NSLog(@"(%@) done saving scrap: %d", uuid, (int)drawableView);
                    if(doneSavingBlock) doneSavingBlock(YES);
                }else{
                    // sometimes, this method is called in very quick succession.
                    // that means that the first time it runs and saves, it'll
                    // finish all of the export and drawableViewState will be nil
                    // next time it runs. so we double check our save state to determine
                    // if in fact we still need to save or not
//                    NSLog(@"(%@) no edits to save in state2", uuid);
                    if(doneSavingBlock) doneSavingBlock(NO);
                }
                [lock unlock];
            }
        });
    }else{
        if(doneSavingBlock) doneSavingBlock(NO);
//        NSLog(@"(%@) no edits to save in state3", uuid);
    }
}


-(void) loadScrapStateAsynchronously:(BOOL)async{
    @synchronized(self){
        // if we're already loading our
        // state, then bail early
        // if we already have our state,
        // then bail early
        if(isLoadingState || drawableViewState){
//            NSLog(@"(%@) already loaded", uuid);
            return;
        }
        if(targetIsLoadedState){
            NSLog(@"duplicate load");
        }
        
        targetIsLoadedState = YES;
        isLoadingState = YES;
    }
//    NSLog(@"(%@) loading scrap state", uuid);

//    NSLog(@"(%@) loading1: %d %d", uuid, targetIsLoadedState, isLoadingState);
    void (^loadBlock)() = ^(void) {
        @synchronized(self){
            targetIsLoadedState = YES;
        }
        @autoreleasepool {
            [lock lock];
            
//            NSLog(@"(%@) loading2: %d %d", uuid, targetIsLoadedState, isLoadingState);
            dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
            [NSThread performBlockOnMainThread:^{
                @synchronized(self){
                    if(!targetIsLoadedState){
                        NSLog(@"saved building JotView we didn't need");
                    }else{
                        // add our drawable view to our contents
                        drawableView = [[JotView alloc] initWithFrame:drawableBounds];
                    }
                }
                dispatch_semaphore_signal(sema1);
            }];

            // load state, if we have any.
            dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
            BOOL goalIsLoaded = NO;
            @synchronized(self){
                goalIsLoaded = targetIsLoadedState;
            }
            if(!goalIsLoaded){
                NSLog(@"saved building JotViewStateProxy we didn't need");
            }else{
                // load drawable view information here
                drawableViewState = [[JotViewStateProxy alloc] initWithDelegate:self];
                [drawableViewState loadStateAsynchronously:async
                                                  withSize:drawableView.pagePtSize
                                                  andScale:drawableView.scale
                                                andContext:[drawableView context]
                                          andBufferManager:[[JotBufferManager alloc] init]];
            }
            [lock unlock];
        }
    };

    if(async){
        dispatch_async([MMScrapViewState importExportScrapStateQueue], loadBlock);
    }else{
        loadBlock();
    }
}

-(void) unloadState{
    @synchronized(self){
        targetIsLoadedState = NO;
    }
    dispatch_async([MMScrapViewState importExportScrapStateQueue], ^{
        @autoreleasepool {
            [lock lock];
            @synchronized(self){
                if(drawableViewState && [drawableViewState isStateLoaded] && [drawableViewState hasEditsToSave]){
//                    NSLog(@"(%@) unload failed, will retry", uuid);
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
//                    NSLog(@"(%@) unload success", uuid);
                    targetIsLoadedState = NO;
                    if(!isLoadingState && drawableViewState){
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
    return activeThumbnailImage;
}

-(void) setActiveThumbnailImage:(UIImage*)img{
    activeThumbnailImage = img;
    [NSThread performBlockOnMainThread:^{
        thumbnailView.image = activeThumbnailImage;
    }];
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
        debug_NSLog(@"trying to draw on an unloaded scrap");
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
-(void) importTexture:(JotGLTexture*)texture atP1:(CGPoint)p1 andP2:(CGPoint)p2 andP3:(CGPoint)p3 andP4:(CGPoint)p4{
    CGSize roundedDrawableBounds = self.drawableBounds.size;
    roundedDrawableBounds.width = ceilf(roundedDrawableBounds.width);
    roundedDrawableBounds.height = ceilf(roundedDrawableBounds.height);
    [drawableView drawBackingTexture:texture atP1:(CGPoint)p1 andP2:(CGPoint)p2 andP3:(CGPoint)p3 andP4:(CGPoint)p4 clippingPath:self.bezierPath
                     andClippingSize:roundedDrawableBounds];
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
            NSLog(@"loaded state we didn't need");
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
//                        NSLog(@"(%@) loaded scrap state", uuid);
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
//    NSLog(@"(%@) unloaded scrap state", uuid);
    // noop
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
//    NSLog(@"scrap state (%@) dealloc", uuid);
    [[MMLoadImageCache sharedInstance] clearCacheForPath:self.thumbImageFile];
//    dispatch_release(importExportScrapStateQueue); ARC handles this
//    importExportScrapStateQueue = nil;
}

@end
