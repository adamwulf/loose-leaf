//
//  MMEditablePaperView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/24/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMEditablePaperView.h"
#import <QuartzCore/QuartzCore.h>
#import <JotUI/JotUI.h>
#import "NSThread+BlockAdditions.h"
#import "TestFlight.h"

dispatch_queue_t loadUnloadStateQueue;
dispatch_queue_t importThumbnailQueue;


@implementation MMEditablePaperView{
    NSUInteger lastSavedUndoHash;
    
    JotViewState* state;
    // cached static values
    NSString* pagesPath;
    NSString* inkPath;
    NSString* plistPath;
    NSString* thumbnailPath;
    
    BOOL isLoadingCachedImageFromDisk;
}

@synthesize drawableView;

+(dispatch_queue_t) loadUnloadStateQueue{
    if(!loadUnloadStateQueue){
        loadUnloadStateQueue = dispatch_queue_create("com.milestonemade.looseleaf.loadUnloadStateQueue", DISPATCH_QUEUE_SERIAL);
    }
    return loadUnloadStateQueue;
}

+(dispatch_queue_t) importThumbnailQueue{
    if(!importThumbnailQueue){
        importThumbnailQueue = dispatch_queue_create("com.milestonemade.looseleaf.importThumbnailQueue", DISPATCH_QUEUE_SERIAL);
    }
    return importThumbnailQueue;
}


- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid{
    self = [super initWithFrame:frame andUUID:_uuid];
    if (self) {
        // create the cache view
        cachedImgView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        cachedImgView.frame = self.contentView.bounds;
        cachedImgView.contentMode = UIViewContentModeScaleAspectFill;
        cachedImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cachedImgView.clipsToBounds = YES;
        cachedImgView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:.3];
        [self.contentView addSubview:cachedImgView];
        
        lastSavedUndoHash = [drawableView undoHash];
    }
    return self;
}

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    CGFloat _scale = frame.size.width / self.superview.frame.size.width;
    drawableView.transform = CGAffineTransformMakeScale(_scale, _scale);
}

#pragma mark - Public Methods

-(void) undo{
    if([drawableView canUndo]){
        [drawableView undo];
        [self saveToDisk];
    }
}

-(void) redo{
    if([drawableView canRedo]){
        [drawableView redo];
        [self saveToDisk];
    }
}

-(void) setCanvasVisible:(BOOL)isCanvasVisible{
    if(isCanvasVisible){
        cachedImgView.hidden = YES;
        drawableView.hidden = NO;
    }else{
        cachedImgView.hidden = NO;
        drawableView.hidden = YES;
    }
}

-(void) setEditable:(BOOL)isEditable{
    if(isEditable && (!drawableView || drawableView.hidden)){
        debug_NSLog(@"setting editable w/o canvas");
    }
    if(isEditable){
        drawableView.userInteractionEnabled = YES;
    }else{
        drawableView.userInteractionEnabled = NO;
    }
}

-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize) pagePixelSize andContext:(EAGLContext*)context andThen:(void (^)())block{
    if(state){
        if(block) block();
        return;
    }
    
    void (^block2)() = ^(void) {
        if(!state){
            state = [[JotViewState alloc] initWithImageFile:[self inkPath]
                                               andStateFile:[self plistPath]
                                                andPageSize:pagePixelSize
                                               andGLContext:context];
        }
        if(block) block();
    };
    
    if(async){
        dispatch_async([MMEditablePaperView loadUnloadStateQueue], block2);
    }else{
        block2();
    }
}
-(void) unloadState{
    dispatch_async([MMEditablePaperView loadUnloadStateQueue], ^(void) {
        state = nil;
    });
}

-(void) setDrawableView:(JotView *)_drawableView{
    if(drawableView != _drawableView){
        drawableView = _drawableView;
        if(drawableView){
            [self setFrame:self.frame];
            [self loadStateAsynchronously:YES
                                 withSize:[drawableView pagePixelSize]
                               andContext:[drawableView context]
                                  andThen:^{
                                      [NSThread performBlockOnMainThread:^{
                                          if([self.delegate isPageEditable:self]){
                                              [drawableView loadState:state];
                                              lastSavedUndoHash = [drawableView undoHash];
                                              [self.contentView addSubview:drawableView];
                                              // anchor the view to the top left,
                                              // so that when we scale down, the drawable view
                                              // stays in place
                                              drawableView.layer.anchorPoint = CGPointMake(0,0);
                                              drawableView.layer.position = CGPointMake(0,0);
                                              drawableView.delegate = self;
                                              [self setCanvasVisible:YES];
                                              [self setEditable:YES];
                                          }
                                      }];
                                  }];
        }
    }else if(drawableView && state){
        [self setCanvasVisible:YES];
        [self setEditable:YES];
    }
}

/**
 * we have more information to save, if our
 * drawable view's hash does not equal to our
 * currently saved hash
 */
-(BOOL) hasEditsToSave{
//    debug_NSLog(@"checking if edits to save %u vs %u", [drawableView undoHash], lastSavedUndoHash);
    return [drawableView undoHash] != lastSavedUndoHash;
}

/**
 * write the thumbnail, backing texture, and entire undo
 * state to disk, and notify our delegate when done
 */
-(void) saveToDisk{
    // Sanity checks to generate our directory structure if needed
    [self pagesPath];
    
    // find out what our current undo state looks like.
    if([self hasEditsToSave]){
        // something has changed since the last time we saved,
        // so ask the JotView to save out the png of its data
        [drawableView exportImageTo:[self inkPath]
                   andThumbnailTo:[self thumbnailPath]
                       andStateTo:[self plistPath]
                       onComplete:^(UIImage* ink, UIImage* thumbnail, JotViewImmutableState* immutableState){
                           [NSThread performBlockOnMainThread:^{
                               lastSavedUndoHash = [immutableState undoHash];
                               debug_NSLog(@"saving page %@ with hash %u", self.uuid, lastSavedUndoHash);
                               cachedImgView.image = thumbnail;
                               [self.delegate didSavePage:self];
                           }];
                       }];
    }else{
        // already saved, but don't need to write
        // anything new to disk
        debug_NSLog(@"no edits to save with hash %u", [drawableView undoHash]);
        [self.delegate didSavePage:self];
    }
}

-(void) loadCachedPreview{
    if(!cachedImgView.image && !isLoadingCachedImageFromDisk){
        isLoadingCachedImageFromDisk = YES;
        dispatch_async([MMEditablePaperView importThumbnailQueue], ^(void) {
            UIImage* img = [UIImage imageWithContentsOfFile:[self thumbnailPath]];
            [NSThread performBlockOnMainThread:^{
                cachedImgView.image = img;
                isLoadingCachedImageFromDisk = NO;
            }];
        });
    }
}

-(void) unloadCachedPreview{
    // i have to do this on the dispatch queues, so
    // that this will execute after loading if the loading
    // hasn't executed yet
    //
    // i should probably make an nsoperationqueue or something
    // so that i can cancel operations if they havne't run yet... (?)
    dispatch_async([MMEditablePaperView importThumbnailQueue], ^(void) {
        [NSThread performBlockOnMainThread:^{
            cachedImgView.image = nil;
        }];
    });
}



#pragma mark - JotViewDelegate

-(BOOL) willBeginStrokeWithTouch:(JotTouch*)touch{
    if(panGesture.state == UIGestureRecognizerStateBegan ||
       panGesture.state == UIGestureRecognizerStateChanged){
        if([panGesture containsTouch:touch.touch]){
            return NO;
        }
    }
    return [delegate willBeginStrokeWithTouch:touch];
}

-(void) willMoveStrokeWithTouch:(JotTouch*)touch{
    [delegate willMoveStrokeWithTouch:touch];
}

-(void) didEndStrokeWithTouch:(JotTouch*)touch{
    [delegate didEndStrokeWithTouch:touch];
    [self saveToDisk];
}

-(void) didCancelStrokeWithTouch:(JotTouch*)touch{
    [delegate didCancelStrokeWithTouch:touch];
}

-(UIColor*) colorForTouch:(JotTouch *)touch{
    return [delegate colorForTouch:touch];
}

-(CGFloat) widthForTouch:(JotTouch*)touch{
    //
    // we divide by scale so that when the user is zoomed in,
    // their pen is always writing at the same visible scale
    //
    // this lets them write smaller text / detail when zoomed in
    return [delegate widthForTouch:touch] / self.scale;
}

-(CGFloat) smoothnessForTouch:(JotTouch *)touch{
    return [delegate smoothnessForTouch:touch];
}

-(CGFloat) rotationForSegment:(AbstractBezierPathElement *)segment fromPreviousSegment:(AbstractBezierPathElement *)previousSegment{
    return [delegate rotationForSegment:segment fromPreviousSegment:previousSegment];;
}




#pragma mark - File Paths

-(NSString*) pagesPath{
    if(!pagesPath){
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsPath = [paths objectAtIndex:0];
        pagesPath = [[documentsPath stringByAppendingPathComponent:@"Pages"] stringByAppendingPathComponent:[self uuid]];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:pagesPath]){
            [[NSFileManager defaultManager] createDirectoryAtPath:pagesPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return pagesPath;
}

-(NSString*) inkPath{
    if(!inkPath){
        inkPath = [[[self pagesPath] stringByAppendingPathComponent:@"ink"] stringByAppendingPathExtension:@"png"];;
    }
    return inkPath;
}

-(NSString*) plistPath{
    if(!plistPath){
        plistPath = [[[self pagesPath] stringByAppendingPathComponent:@"info"] stringByAppendingPathExtension:@"plist"];;
    }
    return plistPath;
}

-(NSString*) thumbnailPath{
    if(!thumbnailPath){
        thumbnailPath = [[[self pagesPath] stringByAppendingPathComponent:[@"ink" stringByAppendingString:@".thumb"]] stringByAppendingPathExtension:@"png"];
    }
    return thumbnailPath;
}


@end
