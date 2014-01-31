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
#import <JotUI/AbstractBezierPathElement-Protected.h>
#import "NSThread+BlockAdditions.h"
#import "TestFlight.h"
#import <DrawKit-iOS/DrawKit-iOS.h>
#import "DKUIBezierPathClippedSegment+PathElement.h"

dispatch_queue_t importThumbnailQueue;


@implementation MMEditablePaperView{
    // cached static values
    NSString* pagesPath;
    NSString* inkPath;
    NSString* plistPath;
    NSString* thumbnailPath;
    UIBezierPath* boundsPath;
    BOOL isLoadingCachedImageFromDisk;
    
    JotViewStateProxy* paperState;
    
    // we want to be able to track extremely
    // efficiently 1) if we have a thumbnail loaded,
    // and 2) if we have (or don't) a thumbnail at all
    UIImage* cachedImgViewImage;
    // this defaults to NO, which means we'll try to
    // load a thumbnail. if an image does not exist
    // on disk, then we'll set this to YES which will
    // prevent any more thumbnail loads until this page
    // is saved
    BOOL definitelyDoesNotHaveAThumbnail;
}

@synthesize drawableView;
@synthesize paperState;

+(dispatch_queue_t) importThumbnailQueue{
    if(!importThumbnailQueue){
        importThumbnailQueue = dispatch_queue_create("com.milestonemade.looseleaf.importThumbnailQueue", DISPATCH_QUEUE_SERIAL);
    }
    return importThumbnailQueue;
}


- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid{
    self = [super initWithFrame:frame andUUID:_uuid];
    if (self) {
        // used for clipping strokes to our bounds so that we don't generate
        // vertex data for anything that'll never be visible
        boundsPath = [UIBezierPath bezierPathWithRect:self.bounds];
        
        // create the cache view
        cachedImgView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        cachedImgView.frame = self.contentView.bounds;
        cachedImgView.contentMode = UIViewContentModeScaleAspectFill;
        cachedImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cachedImgView.clipsToBounds = YES;
        cachedImgView.opaque = YES;
        cachedImgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:cachedImgView];
        
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
        
        // initialize our state manager
        paperState = [[JotViewStateProxy alloc] initWithInkPath:[self inkPath] andPlistPath:[self plistPath]];
        paperState.delegate = self;
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
        shapeBuilderView.hidden = NO;
    }else{
        cachedImgView.hidden = NO;
        drawableView.hidden = YES;
        shapeBuilderView.hidden = YES;
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

-(BOOL) isEditable{
    return drawableView.userInteractionEnabled;
}


    
-(void) generateDebugView:(BOOL)create{
    if(create){
        CGFloat scale = [[UIScreen mainScreen] scale];
        CGRect boundsForShapeBuilder = self.contentView.bounds;
        boundsForShapeBuilder = CGRectApplyAffineTransform(boundsForShapeBuilder, CGAffineTransformMakeScale(1/scale, 1/scale));
        shapeBuilderView = [[MMShapeBuilderView alloc] initWithFrame:boundsForShapeBuilder];
        shapeBuilderView.transform = CGAffineTransformMakeScale(scale, scale);
        //        polygonDebugView.layer.borderColor = [UIColor redColor].CGColor;
        //        polygonDebugView.layer.borderWidth = 10;
        shapeBuilderView.frame = self.contentView.bounds;
        shapeBuilderView.contentMode = UIViewContentModeScaleAspectFill;
        shapeBuilderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        shapeBuilderView.clipsToBounds = YES;
        shapeBuilderView.opaque = NO;
        shapeBuilderView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:shapeBuilderView];
    }else{
        [shapeBuilderView removeFromSuperview];
        shapeBuilderView = nil;
    }
}

-(void) setDrawableView:(JotView *)_drawableView{
    if(_drawableView && ![self hasStateLoaded]){
        NSLog(@"oh no");
    }
    if(drawableView != _drawableView){
        drawableView = _drawableView;
        if(drawableView){
            [self generateDebugView:YES];
            [self setFrame:self.frame];
            [NSThread performBlockOnMainThread:^{
                if([self.delegate isPageEditable:self] && [self hasStateLoaded]){
                    [drawableView loadState:paperState];
                    [self.contentView insertSubview:drawableView aboveSubview:cachedImgView];
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
        }else{
            [self generateDebugView:NO];
        }
    }else if(drawableView && [self hasStateLoaded]){
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
    return [paperState hasEditsToSave];
}

-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize)pagePixelSize andContext:(JotGLContext*)context{
    if([paperState isStateLoaded]){
        [self didLoadState:paperState];
        return;
    }
    [paperState loadStateAsynchronously:async withSize:pagePixelSize andContext:context andBufferManager:[JotBufferManager sharedInstace]];
}
-(void) unloadState{
    [paperState unload];
}

-(BOOL) hasStateLoaded{
    return [paperState isStateLoaded];
}


/**
 * subclass should override and call into saveToDisk:
 */
-(void) saveToDisk{
    @throw kAbstractMethodException;
}

/**
 * write the thumbnail, backing texture, and entire undo
 * state to disk, and notify our delegate when done
 */
-(void) saveToDisk:(void (^)(void))onComplete{
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
                           if(immutableState){
                               // sometimes, if we try to export multiple times
                               // very very quickly, the 3+ exports will fail
                               // with all arguments=nil because the first export
                               // is still going (and a 2nd export is already waiting
                               // in queue)
                               // so only trigger our save action if we did in fact
                               // save
                               definitelyDoesNotHaveAThumbnail = NO;
                               [paperState wasSavedAtImmutableState:immutableState];
                               onComplete();
                               [NSThread performBlockOnMainThread:^{
                                   cachedImgViewImage = thumbnail;
                                   cachedImgView.image = cachedImgViewImage;
                               }];
                           }else{
                               onComplete();
                           }
                       }];
    }else{
        // already saved, but don't need to write
        // anything new to disk
        debug_NSLog(@"no edits to save with hash %u", [drawableView undoHash]);
        onComplete();
    }
}

/**
 * this preview is used when the list view is scrolling.
 * the goal is to have possibly thousands of pages on disk,
 * and we load the preview for pages only when they become visible
 * in the scroll view or by gestures in page view.
 */

// static count to help debug how many times I'm actually
// going to disk trying to load a thumbnail
static int count = 0;
-(void) loadCachedPreview{
    // if we might have a thumbnail (!definitelyDoesNotHaveAThumbnail)
    // and we don't have one cached (!cachedImgViewImage) and
    // we're not already tryign to load it form disk (!isLoadingCachedImageFromDisk)
    // then try to load it and store the results.
    if(!definitelyDoesNotHaveAThumbnail && !cachedImgViewImage && !isLoadingCachedImageFromDisk){
        isLoadingCachedImageFromDisk = YES;
        count++;
        dispatch_async([MMEditablePaperView importThumbnailQueue], ^(void) {
            @autoreleasepool {
                //
                // load thumbnails into a cache for faster repeat loading
                // https://github.com/adamwulf/loose-leaf/issues/227
                UIImage* thumbnail = [UIImage imageWithContentsOfFile:[self thumbnailPath]];
                if(!thumbnail){
                    definitelyDoesNotHaveAThumbnail = YES;
                }
                isLoadingCachedImageFromDisk = NO;
                [NSThread performBlockOnMainThread:^{
                    cachedImgViewImage = thumbnail;
                    cachedImgView.image = cachedImgViewImage;
                }];
            }
        });
    }
}

/**
 * this page is no longer visible in either page view
 * (from gestures showing it behind a visible page
 * or on the bezel stack) or in the list view.
 */
-(void) unloadCachedPreview{
    // i have to do this on the dispatch queues, so
    // that this will execute after loading if the loading
    // hasn't executed yet
    //
    // i should probably make an nsoperationqueue or something
    // so that i can cancel operations if they havne't run yet... (?)
    if(cachedImgViewImage || isLoadingCachedImageFromDisk){
        // adding to these thread queues will make sure I unload
        // after any in progress load
        dispatch_async([MMEditablePaperView importThumbnailQueue], ^(void) {
            [NSThread performBlockOnMainThread:^{
                cachedImgViewImage = nil;
                cachedImgView.image = cachedImgViewImage;
            }];
        });
    }
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

-(void) willEndStrokeWithTouch:(JotTouch*)touch{
    [delegate willEndStrokeWithTouch:touch];
}

-(void) didEndStrokeWithTouch:(JotTouch*)touch{
    [delegate didEndStrokeWithTouch:touch];
    [self saveToDisk];
}

-(void) willCancelStrokeWithTouch:(JotTouch*)touch{
    [delegate willCancelStrokeWithTouch:touch];
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

-(NSArray*) willAddElementsToStroke:(NSArray *)elements fromPreviousElement:(AbstractBezierPathElement*)previousElement{
    
    NSArray* modifiedElements = [self.delegate willAddElementsToStroke:elements fromPreviousElement:previousElement];
    
    NSMutableArray* croppedElements = [NSMutableArray array];
    for(AbstractBezierPathElement* element in modifiedElements){
        if([element isKindOfClass:[CurveToPathElement class]]){
            UIBezierPath* bez = [element bezierPathSegment];
            
            NSArray* redAndBlueSegments = [UIBezierPath redAndGreenAndBlueSegmentsCreatedFrom:boundsPath bySlicingWithPath:bez andNumberOfBlueShellSegments:nil];
            NSArray* redSegments = [redAndBlueSegments firstObject];
            NSArray* greenSegments = [redAndBlueSegments objectAtIndex:1];

            if(![greenSegments count]){
                // if the difference is empty, then that means that the entire
                // element landed in the intersection. so just add the entire element
                // to our output
                [croppedElements addObject:element];
            }else{
                // if the element was chopped up somehow, then interate
                // through the intersection and build new element objects
                for(DKUIBezierPathClippedSegment* segment in redSegments){
                    [croppedElements addObjectsFromArray:[segment convertToPathElementsFromColor:previousElement.color
                                                                                         toColor:element.color
                                                                                       fromWidth:previousElement.width
                                                                                         toWidth:element.width]];
                    
                }
            }
            if([croppedElements count] && [[croppedElements firstObject] isKindOfClass:[MoveToPathElement class]]){
                [croppedElements removeObjectAtIndex:0];
            }
        }else{
            [croppedElements addObject:element];
        }
        previousElement = element;
    }
    return croppedElements;
}


-(void) jotSuggestsToDisableGestures{
    NSLog(@"disable gestures!");
}

-(void) jotSuggestsToEnableGestures{
    NSLog(@"enable gestures!");
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




#pragma mark - JotViewStateProxyDelegate

-(void) jotStrokeWasCancelled:(JotStroke *)stroke{
    NSLog(@"MMEditablePaperView jotStrokeWasCancelled:");
}

-(void) didLoadState:(JotViewStateProxy*)state{
    [NSThread performBlockOnMainThread:^{
        [self.delegate didLoadStateForPage:self];
    }];
}

-(void) didUnloadState:(JotViewStateProxy *)state{
    [NSThread performBlockOnMainThread:^{
        [self.delegate didUnloadStateForPage:self];
    }];
}

@end
