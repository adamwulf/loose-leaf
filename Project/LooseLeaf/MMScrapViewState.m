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
#import "NSFileManager+DirectoryOptimizations.h"

#define kScrapShadowBufferSize 4

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
    
    // unloadable state
    // this state can be loaded and unloaded
    // to conserve memeory as needed
    JotViewStateProxy* drawableViewState;
    // YES if our goal is to be loaded, NO otherwise
    BOOL targetIsLoadedState;
    // YES if we're currently loading our state, NO otherwise
    BOOL isLoadingState;
    
    // private vars
    NSString* plistPath;
    NSString* inkImageFile;
    NSString* thumbImageFile;
    NSString* stateFile;
    NSString* backgroundFile;

    // helper vars
    CGSize originalSize;
    CGRect drawableBounds;
    
    // queue
    dispatch_queue_t importExportScrapStateQueue;
    
    // thumbnail
    UIImage* activeThumbnailImage;
    
    // image background
    BOOL backingViewHasChanged;
    UIImageView* backingContentView;
    CGFloat backgroundRotation;
    CGFloat backgroundScale;
    CGPoint backgroundOffset;
    
    // lock to control threading
    NSLock* lock;
}

#pragma mark - Properties

@synthesize bezierPath;
@synthesize contentView;
@synthesize drawableBounds;
@synthesize delegate;
@synthesize uuid;

-(CGSize) originalSize{
    if(CGSizeEqualToSize(originalSize, CGSizeZero)){
        // performance optimization, only load it when asked for
        // and then cache it
        originalSize = self.bezierPath.bounds.size;
    }
    return originalSize;
}

#pragma mark - Dispatch Queue

-(dispatch_queue_t) importExportScrapStateQueue{
    if(!importExportScrapStateQueue){
        importExportScrapStateQueue = dispatch_queue_create("com.milestonemade.looseleaf.importExportScrapStateQueue", DISPATCH_QUEUE_SERIAL);
    }
    return importExportScrapStateQueue;
}

#pragma mark - Init

-(id) initWithUUID:(NSString*)_uuid{
    if(self = [super init]){
        
        // save our UUID, everything depends on this
        uuid = _uuid;
        
        if([[NSFileManager defaultManager] fileExistsAtPath:self.plistPath]){
            NSDictionary* properties = [NSDictionary dictionaryWithContentsOfFile:self.plistPath];
            bezierPath = [NSKeyedUnarchiver unarchiveObjectWithData:[properties objectForKey:@"bezierPath"]];
            backgroundRotation = [[properties objectForKey:@"backgroundRotation"] floatValue];
            backgroundScale = [[properties objectForKey:@"backgroundScale"] floatValue];
            backgroundOffset.x = [[properties objectForKey:@"backgroundOffset.x"] floatValue];
            backgroundOffset.y = [[properties objectForKey:@"backgroundOffset.y"] floatValue];
            return [self initWithUUID:uuid andBezierPath:bezierPath];
        }else{
            // we don't have a file that we should have, so don't load the scrap
            return nil;
        }
    }
    return self;
}


-(id) initWithUUID:(NSString*)_uuid andBezierPath:(UIBezierPath*)_path{
    if(self = [super init]){
        
        // save our UUID, everything depends on this
        uuid = _uuid;
        lock = [[NSLock alloc] init];
        backingViewHasChanged = NO;

        if(!bezierPath){
            CGRect originalBounds = _path.bounds;
            [_path applyTransform:CGAffineTransformMakeTranslation(-originalBounds.origin.x + kScrapShadowBufferSize, -originalBounds.origin.y + kScrapShadowBufferSize)];
            bezierPath = _path;
            
            //save initial bezier path to disk
            // not the most elegant solution, but it works and is fast enough for now
            NSMutableDictionary* savedProperties = [NSMutableDictionary dictionary];
            [savedProperties setObject:[NSKeyedArchiver archivedDataWithRootObject:bezierPath] forKey:@"bezierPath"];
            [savedProperties writeToFile:self.plistPath atomically:YES];
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

        
        backingContentView = [[UIImageView alloc] initWithFrame:contentView.bounds];
        backingContentView.contentMode = UIViewContentModeScaleAspectFit;
        backingContentView.clipsToBounds = YES;
        backingContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        backingContentView.frame = contentView.bounds;

        UIView* clippedBackgroundView = [[UIView alloc] initWithFrame:contentView.bounds];
        clippedBackgroundView.clipsToBounds = YES;
        clippedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        CAShapeLayer* backgroundColorLayer = [CAShapeLayer layer];
        [backgroundColorLayer setPath:bezierPath.CGPath];
        backgroundColorLayer.frame = backingContentView.bounds;
        clippedBackgroundView.layer.mask = backgroundColorLayer;
        [clippedBackgroundView addSubview:backingContentView];

        [contentView addSubview:clippedBackgroundView];
        [contentView addSubview:thumbnailView];

        if([[MMLoadImageCache sharedInstace] containsPathInCache:self.thumbImageFile]){
            // load if we can
            [self setActiveThumbnailImage:[[MMLoadImageCache sharedInstace] imageAtPath:self.thumbImageFile]];
        }else{
            // don't load from disk on the main thread.
            dispatch_async([self importExportScrapStateQueue], ^{
                [lock lock];
                @autoreleasepool {
                    UIImage* thumb = [[MMLoadImageCache sharedInstace] imageAtPath:self.thumbImageFile];
                    [self setActiveThumbnailImage:thumb];
                }
                [lock unlock];
            });
        }
        
        if([[NSFileManager defaultManager] fileExistsAtPath:[self backgroundJPGFile]]){
//            NSLog(@"should be loading background");
            UIImage* image = [UIImage imageWithContentsOfFile:[self backgroundJPGFile]];
            [NSThread performBlockOnMainThread:^{
                [self setBackingImage:image];
            }];
        }
    }
    return self;
}

#pragma mark - Backing Image

-(void) updateBackingImageLocation{
    backingContentView.center = CGPointMake(contentView.bounds.size.width/2 + backgroundOffset.x,
                                            contentView.bounds.size.height/2 + backgroundOffset.y);
    backingContentView.transform = CGAffineTransformConcat(CGAffineTransformMakeRotation(backgroundRotation),CGAffineTransformMakeScale(backgroundScale, backgroundScale));
    backingViewHasChanged = YES;
//    NSLog(@"(%@) updating background properties", self.uuid);
}

-(void) setBackingImage:(UIImage*)img{
    backingContentView.image = img;
    CGRect r = backingContentView.frame;
    r.size = CGSizeMake(img.size.width, img.size.height);
    backingContentView.frame = r;
    [self updateBackingImageLocation];
}

-(UIImage*) backingImage{
    return backingContentView.image;
}

-(void) setBackgroundRotation:(CGFloat)_backgroundRotation{
    backgroundRotation = _backgroundRotation;
    [self updateBackingImageLocation];
}

-(CGFloat) backgroundRotation{
    return backgroundRotation;
}

-(void) setBackgroundScale:(CGFloat)_backgroundScale{
    backgroundScale = _backgroundScale;
    [self updateBackingImageLocation];
}

-(CGFloat) backgroundScale{
    return backgroundScale;
}

-(void) setBackgroundOffset:(CGPoint)bgOffset{
    backgroundOffset = bgOffset;
    [self updateBackingImageLocation];
}

-(CGPoint) backgroundOffset{
    return backgroundOffset;
}

-(UIView*) backingContentView{
    return backingContentView;
}

#pragma mark - State Saving and Loading

-(void) saveToDisk{
    if(drawableViewState && ([drawableViewState hasEditsToSave] || backingViewHasChanged)){
        dispatch_async([self importExportScrapStateQueue], ^{
            @autoreleasepool {
                [lock lock];
//                NSLog(@"(%@) saving with background: %d %d", uuid, (int)drawableView, backingViewHasChanged);
                if(drawableViewState && ([drawableViewState hasEditsToSave] || backingViewHasChanged)){
                    dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
                    [NSThread performBlockOnMainThread:^{
                        @autoreleasepool {
                            if(drawableView && ([drawableViewState hasEditsToSave] || backingViewHasChanged)){
//                                NSLog(@"(%@) saving background: %d", uuid, backingViewHasChanged);
                                // save path
                                // this needs to be saved at the exact same time as the drawable view
                                // so that we can guarentee that there is no race condition
                                // for saving state vs content
                                NSMutableDictionary* savedProperties = [NSMutableDictionary dictionary];
                                [savedProperties setObject:[NSKeyedArchiver archivedDataWithRootObject:bezierPath] forKey:@"bezierPath"];
                                [savedProperties setObject:[NSNumber numberWithFloat:backgroundRotation] forKey:@"backgroundRotation"];
                                [savedProperties setObject:[NSNumber numberWithFloat:backgroundScale] forKey:@"backgroundScale"];
                                [savedProperties setObject:[NSNumber numberWithFloat:backgroundOffset.x] forKey:@"backgroundOffset.x"];
                                [savedProperties setObject:[NSNumber numberWithFloat:backgroundOffset.y] forKey:@"backgroundOffset.y"];
                                [savedProperties writeToFile:self.plistPath atomically:YES];

                                if(backingViewHasChanged && ![[NSFileManager defaultManager] fileExistsAtPath:[self backgroundJPGFile]]){
                                    if(backingContentView.image){
                                        NSLog(@"orientation: %d", backingContentView.image.imageOrientation);
                                        [UIImageJPEGRepresentation(backingContentView.image, .9) writeToFile:[self backgroundJPGFile] atomically:YES];
                                    }
                                    backingViewHasChanged = NO;
                                }
                                

                                if([drawableViewState hasEditsToSave]){
//                                    NSLog(@"(%@) saving strokes: %d", uuid, backingViewHasChanged);
                                    // now export the drawn content. this will create an immutable state
                                    // object and export in the background. this means that everything at this
                                    // instant on the thread will be synced to the content in this drawable view
                                    [drawableView exportImageTo:self.inkImageFile andThumbnailTo:self.thumbImageFile andStateTo:self.stateFile onComplete:^(UIImage* ink, UIImage* thumb, JotViewImmutableState* state){
                                        if(state){
                                            [[MMLoadImageCache sharedInstace] updateCacheForPath:self.thumbImageFile toImage:thumb];
                                            [self setActiveThumbnailImage:thumb];
                                            [drawableViewState wasSavedAtImmutableState:state];
//                                            NSLog(@"(%@) scrap saved at: %d with thumb: %d", uuid, state.undoHash, (int)thumb);
                                        }
                                        dispatch_semaphore_signal(sema1);
                                    }];
                                }else{
//                                    NSLog(@"(%@) skipped saving strokes: %d", uuid, backingViewHasChanged);
                                    dispatch_semaphore_signal(sema1);
                                }
                            }else{
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
                    dispatch_release(sema1);
//                    NSLog(@"(%@) done saving: %d", uuid, (int)drawableView);
                }else{
                    // sometimes, this method is called in very quick succession.
                    // that means that the first time it runs and saves, it'll
                    // finish all of the export and drawableViewState will be nil
                    // next time it runs. so we double check our save state to determine
                    // if in fact we still need to save or not
//                    NSLog(@"(%@) no edits to save in state2", uuid);
                }
                [lock unlock];
            }
        });
    }else{
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
        
        targetIsLoadedState = YES;
        isLoadingState = YES;
    }

//    NSLog(@"(%@) loading1: %d %d", uuid, targetIsLoadedState, isLoadingState);
    void (^loadBlock)() = ^(void) {
        @autoreleasepool {
            [lock lock];
//            NSLog(@"(%@) loading2: %d %d", uuid, targetIsLoadedState, isLoadingState);
            dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
            [NSThread performBlockOnMainThread:^{
                @synchronized(self){
                    // add our drawable view to our contents
                    drawableView = [[JotView alloc] initWithFrame:drawableBounds];
                }
                dispatch_semaphore_signal(sema1);
            }];

            // load state, if we have any.
            dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
            // load drawable view information here
            drawableViewState = [[JotViewStateProxy alloc] initWithInkPath:self.inkImageFile andPlistPath:self.stateFile];
            [drawableViewState loadStateAsynchronously:NO
                                              withSize:[drawableView pagePixelSize]
                                            andContext:[drawableView context]
                                      andBufferManager:[[JotBufferManager alloc] init]];
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
                    }else{
                        // when loading state, we were actually
                        // told that we didn't really need the
                        // state after all, so just throw it away :(
                        drawableViewState = nil;
                        drawableView = nil;
                    }
                }
                dispatch_semaphore_signal(sema1);
            }];
            dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
            dispatch_release(sema1);
            [lock unlock];
        }
    };

    if(async){
        dispatch_async([self importExportScrapStateQueue], loadBlock);
    }else{
        loadBlock();
    }
}

-(void) unloadState{
    dispatch_async([self importExportScrapStateQueue], ^{
        @autoreleasepool {
            [lock lock];
            @synchronized(self){
                if(drawableViewState && [drawableViewState hasEditsToSave]){
//                    NSLog(@"(%@) unload failed, will retry", uuid);
                    // we want to unload, but we're not saved.
                    // save, then try to unload again
                    dispatch_async([self importExportScrapStateQueue], ^{
                        @autoreleasepool {
                            [self saveToDisk];
                        }
                    });
                    dispatch_async([self importExportScrapStateQueue], ^{
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
                            drawableViewState = nil;
                            [drawableView removeFromSuperview];
                            drawableView = nil;
                            thumbnailView.hidden = NO;
                            dispatch_semaphore_signal(sema1);
                        }];
                        dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
                        dispatch_release(sema1);
                    }
                }
            }
            [lock unlock];
        }
    });
}

-(BOOL) isStateLoaded{
    return drawableViewState != nil;
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

-(NSString*)plistPath{
    if(!plistPath){
        plistPath = [self.scrapPath stringByAppendingPathComponent:[@"info" stringByAppendingPathExtension:@"plist"]];
    }
    return plistPath;
}

-(NSString*)inkImageFile{
    if(!inkImageFile){
        inkImageFile = [self.scrapPath stringByAppendingPathComponent:[@"ink" stringByAppendingPathExtension:@"png"]];
    }
    return inkImageFile;
}

-(NSString*) thumbImageFile{
    if(!thumbImageFile){
        thumbImageFile = [self.scrapPath stringByAppendingPathComponent:[@"thumb" stringByAppendingPathExtension:@"png"]];
    }
    return thumbImageFile;
}

-(NSString*) stateFile{
    if(!stateFile){
        stateFile = [self.scrapPath stringByAppendingPathComponent:[@"state" stringByAppendingPathExtension:@"plist"]];
    }
    return stateFile;
}

-(NSString*) backgroundJPGFile{
    if(!backgroundFile){
        backgroundFile = [self.scrapPath stringByAppendingPathComponent:[@"background" stringByAppendingPathExtension:@"jpg"]];
    }
    return backgroundFile;
}

#pragma mark - Private

+(NSString*) scrapDirectoryPathForUUID:(NSString*)uuid{
    NSString* documentsPath = [NSFileManager documentsPath];
    NSString* scrapPath = [[documentsPath stringByAppendingPathComponent:@"Scraps"] stringByAppendingPathComponent:uuid];
    return scrapPath;
}

-(NSString*) scrapPath{
    if(!scrapPath){
        scrapPath = [MMScrapViewState scrapDirectoryPathForUUID:uuid];
        [NSFileManager ensureDirectoryExistsAtPath:scrapPath];
    }
    return scrapPath;
}

#pragma mark - OpenGL

-(void) addElements:(NSArray*)elements{
    if(!drawableViewState){
        // https://github.com/adamwulf/loose-leaf/issues/258
        NSLog(@"trying to draw on an unloaded scrap");
    }
    [drawableView addElements:elements];
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
    [drawableView drawBackingTexture:texture atP1:(CGPoint)p1 andP2:(CGPoint)p2 andP3:(CGPoint)p3 andP4:(CGPoint)p4 clippingPath:self.bezierPath];
    [drawableView forceAddEmptyStroke];
}

#pragma mark - dealloc

-(void) dealloc{
//    NSLog(@"scrap state (%@) dealloc", uuid);
    [[MMLoadImageCache sharedInstace] clearCacheForPath:self.thumbImageFile];
    dispatch_release(importExportScrapStateQueue);
    importExportScrapStateQueue = nil;
}

@end
