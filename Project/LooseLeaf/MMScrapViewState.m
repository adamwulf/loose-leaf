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

#define kScrapShadowBufferSize 4

@implementation MMScrapViewState{
    // scrap ID and UI
    NSString* uuid;
    NSString* scrapPath;
    UIView* contentView;
    UIImageView* thumbnailView;
    JotView* drawableView;
    
    // state
    JotViewStateProxy* drawableViewState;
    BOOL shouldKeepStateLoaded;
    BOOL isLoadingState;
    UIBezierPath* bezierPath;
    
    // private vars
    NSString* plistPath;
    NSString* inkImageFile;
    NSString* thumbImageFile;
    NSString* stateFile;

    // helper vars
    CGSize originalSize;
    CGRect drawableBounds;
    
    // queue
    dispatch_queue_t importExportScrapStateQueue;
}

@synthesize bezierPath;
@synthesize contentView;
@synthesize drawableBounds;
@synthesize delegate;
@synthesize uuid;

-(dispatch_queue_t) importExportScrapStateQueue{
    if(!importExportScrapStateQueue){
        importExportScrapStateQueue = dispatch_queue_create("com.milestonemade.looseleaf.importExportScrapStateQueue", DISPATCH_QUEUE_SERIAL);
    }
    return importExportScrapStateQueue;
}


-(id) initWithUUID:(NSString*)_uuid{
    if(self = [super init]){
        
        // save our UUID, everything depends on this
        uuid = _uuid;
        
        if([[NSFileManager defaultManager] fileExistsAtPath:self.plistPath]){
            NSDictionary* properties = [NSDictionary dictionaryWithContentsOfFile:self.plistPath];
            bezierPath = [NSKeyedUnarchiver unarchiveObjectWithData:[properties objectForKey:@"bezierPath"]];
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
        [contentView addSubview:thumbnailView];
        thumbnailView.frame = contentView.bounds;

        
        if([[MMLoadImageCache sharedInstace] containsPathInCache:self.thumbImageFile]){
            // load if we can
            thumbnailView.image = [[MMLoadImageCache sharedInstace] imageAtPath:self.thumbImageFile];
        }else{
            // don't load from disk on the main thread.
            dispatch_async([self importExportScrapStateQueue], ^{
                @autoreleasepool {
                    UIImage* thumb = [[MMLoadImageCache sharedInstace] imageAtPath:self.thumbImageFile];
                    [NSThread performBlockOnMainThread:^{
                        thumbnailView.image = thumb;
                    }];
                }
            });
        }
    }
    return self;
}

-(CGSize) originalSize{
    if(CGSizeEqualToSize(originalSize, CGSizeZero)){
        originalSize = self.bezierPath.bounds.size;
    }
    return originalSize;
}

-(void) saveToDisk{
    if(drawableViewState && [drawableViewState hasEditsToSave]){
        dispatch_async([self importExportScrapStateQueue], ^{
            @autoreleasepool {
                NSLog(@"saving: %@ %d", uuid, (int)drawableView);
                if(drawableViewState && [drawableViewState hasEditsToSave]){
                    dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
                    [NSThread performBlockOnMainThread:^{
                        @autoreleasepool {
                            if(drawableView && [drawableViewState hasEditsToSave]){
                                // save path
                                // this needs to be saved at the exact same time as the drawable view
                                // so that we can guarentee that there is no race condition
                                // for saving state vs content
                                NSMutableDictionary* savedProperties = [NSMutableDictionary dictionary];
                                [savedProperties setObject:[NSKeyedArchiver archivedDataWithRootObject:bezierPath] forKey:@"bezierPath"];
                                [savedProperties writeToFile:self.plistPath atomically:YES];
                                
                                // now export the drawn content
                                [drawableView exportImageTo:self.inkImageFile andThumbnailTo:self.thumbImageFile andStateTo:self.stateFile onComplete:^(UIImage* ink, UIImage* thumb, JotViewImmutableState* state){
                                    if(state){
                                        [[MMLoadImageCache sharedInstace] updateCacheForPath:self.thumbImageFile toImage:thumb];
                                        [NSThread performBlockOnMainThread:^{
                                            thumbnailView.image = thumb;
                                        }];
                                        [drawableViewState wasSavedAtImmutableState:state];
                                        NSLog(@"scrap saved at: %d with thumb: %d", state.undoHash, (int)thumb);
                                    }
                                    dispatch_semaphore_signal(sema1);
                                }];
                            }else{
                                if(!drawableView && ![drawableViewState hasEditsToSave]){
                                    NSLog(@"no drawable view or edits");
                                }else if(!drawableView){
                                    NSLog(@"no drawable view");
                                }else if(![drawableViewState hasEditsToSave]){
                                    NSLog(@"no edits to save in state");
                                }
                                // was asked to save, but we were asked to save
                                // multiple times extremely quickly, so just signal
                                // that we're done
                                dispatch_semaphore_signal(sema1);
                            }
                        }
                    }];
                    dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
                    dispatch_release(sema1);
                    NSLog(@"done saving: %@ %d", uuid, (int)drawableView);
                }else{
                    // sometimes, this method is called in very quick succession.
                    // that means that the first time it runs and saves, it'll
                    // finish all of the export and drawableViewState will be nil
                    // next time it runs. so we double check our save state to determine
                    // if in fact we still need to save or not
                    NSLog(@"no edits to save in state2");
                }
            }
        });
    }
}


-(void) loadStateAsynchronously:(BOOL)async{
    @synchronized(self){
        // if we're already loading our
        // state, then bail early
        if(isLoadingState) return;
        // if we already have our state,
        // then bail early
        if(drawableViewState) return;
        
        shouldKeepStateLoaded = YES;
        isLoadingState = YES;
    }

    void (^loadBlock)() = ^(void) {
        @autoreleasepool {
            NSLog(@"loading: %@ %d", uuid, (int) drawableView);
            dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
            [NSThread performBlockOnMainThread:^{
                // add our drawable view to our contents
                drawableView = [[JotView alloc] initWithFrame:drawableBounds];
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
                    if(shouldKeepStateLoaded){
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
            @synchronized(self){
                if(drawableViewState && [drawableViewState hasEditsToSave]){
                    // we want to unload, but we're not saved.
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
                    if([drawableViewState hasEditsToSave]){
                        NSLog(@"how did we get here?");
                    }
                    shouldKeepStateLoaded = NO;
                    if(!isLoadingState && drawableViewState){
                        drawableViewState = nil;
                        [drawableView removeFromSuperview];
                        drawableView = nil;
                        thumbnailView.hidden = NO;
                    }
                }
            }
        }
    });
}

-(BOOL) isStateLoaded{
    return drawableViewState != nil;
}


#pragma mark - TODO

-(void) addElements:(NSArray*)elements{
    if(!drawableViewState){
        // https://github.com/adamwulf/loose-leaf/issues/258
        NSLog(@"tryign to draw on an unloaded scrap");
    }
    [drawableView addElements:elements];
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


#pragma mark - Private

+(NSString*) scrapDirectoryPathForUUID:(NSString*)uuid{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsPath = [paths objectAtIndex:0];
    NSString* scrapPath = [[documentsPath stringByAppendingPathComponent:@"Scraps"] stringByAppendingPathComponent:uuid];
    return scrapPath;
}

-(NSString*) scrapPath{
    if(!scrapPath){
        scrapPath = [MMScrapViewState scrapDirectoryPathForUUID:uuid];
        if(![[NSFileManager defaultManager] fileExistsAtPath:scrapPath]){
            [[NSFileManager defaultManager] createDirectoryAtPath:scrapPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return scrapPath;
}



@end
