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
        [self.contentView addSubview:cachedImgView];
        
        lastSavedUndoHash = [drawableView undoHash];
        
        //
        // This pan gesture is used to pan/scale the page itself.
        rulerGesture = [[MMRulerToolGestureRecognizer alloc] initWithTarget:self action:@selector(didMoveRuler:)];
        //
        // This gesture is only allowed to run if the user is not
        // acting on an object on the page. defer to the long press
        // and the tap gesture, and only allow page pan/scale if
        // these fail
        [rulerGesture requireGestureRecognizerToFail:longPress];
        [rulerGesture requireGestureRecognizerToFail:tap];
        [self addGestureRecognizer:rulerGesture];
    }
    return self;
}

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    CGFloat _scale = frame.size.width / self.superview.frame.size.width;
    drawableView.transform = CGAffineTransformMakeScale(_scale, _scale);
}

#pragma mark - Public Methods

-(void) disableAllGestures{
    [super disableAllGestures];
    drawableView.userInteractionEnabled = NO;
}

-(void) enableAllGestures{
    [super enableAllGestures];
    drawableView.userInteractionEnabled = YES;
}

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
        @autoreleasepool {
            if(!state){
                state = [[JotViewState alloc] initWithImageFile:[self inkPath]
                                                   andStateFile:[self plistPath]
                                                    andPageSize:pagePixelSize
                                                   andGLContext:context];
            }
            if(block) block();
        }
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

-(void) setBackgroundTextureToStartPage{
    UIGraphicsBeginImageContext(state.backgroundTexture.pixelSize);
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    CGFloat textStartX = 110;

    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 18), CGAffineTransformMakeScale(scale, scale))
                            withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"New Blank Page" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 25), CGAffineTransformMakeScale(scale, scale))
                          withFont:[UIFont systemFontOfSize:16 * scale]];
    
    
    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 18 + 60), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"Jot Touch Settings" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 25 + 60), CGAffineTransformMakeScale(scale, scale))
                          withFont:[UIFont systemFontOfSize:16 * scale]];
    

    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 18 + 60*2), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"Send Adam your Alpha Feedback!" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 25 + 60*2), CGAffineTransformMakeScale(scale, scale))
                              withFont:[UIFont systemFontOfSize:16 * scale]];
    

    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 298), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"Pen" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 310), CGAffineTransformMakeScale(scale, scale))
                                          withFont:[UIFont systemFontOfSize:16 * scale]];
    

    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 298 + 60), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"Eraser" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 310 + 60), CGAffineTransformMakeScale(scale, scale))
                                          withFont:[UIFont systemFontOfSize:16 * scale]];
    
    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 330 + 60 * 5), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"Grab" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 342 + 60 * 5), CGAffineTransformMakeScale(scale, scale))
                  withFont:[UIFont systemFontOfSize:16 * scale]];

    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 330 + 60 * 6), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"Ruler" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 342 + 60 * 6), CGAffineTransformMakeScale(scale, scale))
                     withFont:[UIFont systemFontOfSize:16 * scale]];


    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 902), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"Undo" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 914), CGAffineTransformMakeScale(scale, scale))
                  withFont:[UIFont systemFontOfSize:16 * scale]];
    
    [@"←" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(70, 902 + 60), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont systemFontOfSize:32 * scale]];
    [@"Redo" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(textStartX, 914 + 60), CGAffineTransformMakeScale(scale, scale))
                withFont:[UIFont systemFontOfSize:16 * scale]];
    
    
    

    [@"Thanks for helping test Loose Leaf!" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 342), CGAffineTransformMakeScale(scale, scale))
                                withFont:[UIFont boldSystemFontOfSize:20 * scale]];
    
    
    [@"New this build:" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 402), CGAffineTransformMakeScale(scale, scale))
             withFont:[UIFont boldSystemFontOfSize:20 * scale]];
    
    [@"• New Ruler mode lets you draw super straight lines" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 442), CGAffineTransformMakeScale(scale, scale))
                  withFont:[UIFont systemFontOfSize:20 * scale]];
    [@"  or curves. Similar to Adobe's Napolean ruler." drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 468), CGAffineTransformMakeScale(scale, scale))
                                                  withFont:[UIFont systemFontOfSize:20 * scale]];
    
    [@"• Two fingers from left bezel will move pages off the stack." drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 508), CGAffineTransformMakeScale(scale, scale))
                                        withFont:[UIFont systemFontOfSize:20 * scale]];
    
    [@"• two fingers from either bezel works in ruler mode." drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 548), CGAffineTransformMakeScale(scale, scale))
                                                  withFont:[UIFont systemFontOfSize:20 * scale]];
    
    [@"• Can move pages in list view with 1 finger long press." drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 588), CGAffineTransformMakeScale(scale, scale))
                                                                 withFont:[UIFont systemFontOfSize:20 * scale]];

    [@"• lots of memory optimizations" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 628), CGAffineTransformMakeScale(scale, scale))
                                                          withFont:[UIFont systemFontOfSize:20 * scale]];
    
    [@"• changed perspective a bit when zooming to list" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 668), CGAffineTransformMakeScale(scale, scale))
                                          withFont:[UIFont systemFontOfSize:20 * scale]];

    [@"• thinner less smeared-looking pen" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 708), CGAffineTransformMakeScale(scale, scale))
                                                            withFont:[UIFont systemFontOfSize:20 * scale]];

    
    [@"Not yet built:" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 760), CGAffineTransformMakeScale(scale, scale))
                           withFont:[UIFont boldSystemFontOfSize:20 * scale]];

    [@"• New undo/redo UIUX" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 800), CGAffineTransformMakeScale(scale, scale))
                          withFont:[UIFont systemFontOfSize:20 * scale]];
    [@"• Can't delete pages yet" drawAtPoint:CGPointApplyAffineTransform(CGPointMake(250, 840), CGAffineTransformMakeScale(scale, scale))
                                withFont:[UIFont systemFontOfSize:20 * scale]];

    /**
     
     Thanks for helping to test Loose Leaf!
     
     • one finger will draw
     
     • two fingers will pinch/grab a page
     
     • you can pinch and draw at the same time
     
     
     */

    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    state.backgroundTexture = [[JotGLTexture alloc] initForImage:image withSize:state.backgroundTexture.pixelSize];
    lastSavedUndoHash = 0;
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
-(void) forceSaveToDisk{
    lastSavedUndoHash = 0;
    [self saveToDisk];
}
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
            @autoreleasepool {
                UIImage* img = [UIImage imageWithContentsOfFile:[self thumbnailPath]];
                [NSThread performBlockOnMainThread:^{
                    cachedImgView.image = img;
                    isLoadingCachedImageFromDisk = NO;
                }];
            }
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



#pragma mark - Ruler Tool

/**
 * the ruler gesture is firing
 */
-(void) didMoveRuler:(MMRulerToolGestureRecognizer*)gesture{
    if(![delegate shouldAllowPan:self]){
        if(gesture.state == UIGestureRecognizerStateFailed ||
           gesture.state == UIGestureRecognizerStateCancelled ||
           gesture.state == UIGestureRecognizerStateEnded){
            [self.delegate didStopRuler:gesture];
        }else if(gesture.state == UIGestureRecognizerStateBegan ||
               gesture.state == UIGestureRecognizerStateChanged){
            [self.delegate didMoveRuler:gesture];
        }
    }
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

-(NSArray*) willAddElementsToStroke:(NSArray *)elements fromPreviousElement:(AbstractBezierPathElement*)previousElement{
    return [delegate willAddElementsToStroke:elements fromPreviousElement:previousElement];
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
