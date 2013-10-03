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
#import "DrawKit-iOS.h"
#import "MMPaperState.h"

dispatch_queue_t loadUnloadStateQueue;
dispatch_queue_t importThumbnailQueue;


@implementation MMEditablePaperView{
    // cached static values
    NSString* pagesPath;
    NSString* inkPath;
    NSString* plistPath;
    NSString* thumbnailPath;
    UIBezierPath* boundsPath;
    BOOL isLoadingCachedImageFromDisk;
    
    MMPaperState* paperState;
}

@synthesize drawableView;
@synthesize paperState;

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
        // used for clipping strokes to our bounds so that we don't generate
        // vertex data for anything that'll never be visible
        boundsPath = [UIBezierPath bezierPathWithRect:self.bounds];
        
        // create the cache view
        cachedImgView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        cachedImgView.frame = self.contentView.bounds;
        cachedImgView.contentMode = UIViewContentModeScaleAspectFill;
        cachedImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cachedImgView.clipsToBounds = YES;
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
        paperState = [[MMPaperState alloc] initWithInkPath:[self inkPath] andPlistPath:[self plistPath]];
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


-(void) generateDebugView:(BOOL)create{
    if(create){
        shapeBuilderView = [[MMShapeBuilderView alloc] initWithFrame:self.contentView.bounds];
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
                    [drawableView loadState:paperState.jotViewState];
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
    [paperState loadStateAsynchronously:async withSize:pagePixelSize andContext:context];
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
                           [paperState wasSavedAtImmutableState:immutableState];
                           onComplete();
                           [NSThread performBlockOnMainThread:^{
                               cachedImgView.image = thumbnail;
                           }];
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

-(CGFloat) rotationForSegment:(AbstractBezierPathElement *)segment fromPreviousSegment:(AbstractBezierPathElement *)previousSegment{
    return [delegate rotationForSegment:segment fromPreviousSegment:previousSegment];;
}

-(NSArray*) willAddElementsToStroke:(NSArray *)elements fromPreviousElement:(AbstractBezierPathElement*)previousElement{
    
    NSArray* modifiedElements = [self.delegate willAddElementsToStroke:elements fromPreviousElement:previousElement];
    
    NSMutableArray* croppedElements = [NSMutableArray array];
    for(AbstractBezierPathElement* element in modifiedElements){
        
        if([element isKindOfClass:[CurveToPathElement class]]){
            CurveToPathElement* curveElement = (CurveToPathElement*) element;
            UIBezierPath* bez = [UIBezierPath bezierPath];
            [bez moveToPoint:[element startPoint]];
            [bez addCurveToPoint:curveElement.endPoint controlPoint1:curveElement.ctrl1 controlPoint2:curveElement.ctrl2];
            
            NSArray* output = [bez clipUnclosedPathToClosedPath:boundsPath];
//            UIBezierPath* cropped = [bez unclosedPathFromIntersectionWithPath:bounds];
            UIBezierPath* cropped = [output firstObject];

            __block CGPoint previousEndpoint = curveElement.startPoint;
            [cropped iteratePathWithBlock:^(CGPathElement pathEle){
                AbstractBezierPathElement* newElement = nil;
                if(pathEle.type == kCGPathElementAddCurveToPoint){
                    // curve
                    newElement = [CurveToPathElement elementWithStart:previousEndpoint
                                                           andCurveTo:pathEle.points[2]
                                                          andControl1:pathEle.points[0]
                                                          andControl2:pathEle.points[1]];
                    previousEndpoint = pathEle.points[2];
                }else if(pathEle.type == kCGPathElementMoveToPoint){
                    newElement = [MoveToPathElement elementWithMoveTo:pathEle.points[0]];
                    previousEndpoint = pathEle.points[0];
                }else if(pathEle.type == kCGPathElementAddLineToPoint){
                    newElement = [CurveToPathElement elementWithStart:previousEndpoint andLineTo:pathEle.points[0]];
                    previousEndpoint = pathEle.points[0];
                }
                if(newElement){
                    // be sure to set color/width/etc
                    newElement.color = element.color;
                    newElement.width = element.width;
                    newElement.rotation = element.rotation;
                    [croppedElements addObject:newElement];
                }
            }];
            if([croppedElements count] && [[croppedElements firstObject] isKindOfClass:[MoveToPathElement class]]){
                [croppedElements removeObjectAtIndex:0];
            }
        }else{
            [croppedElements addObject:element];
        }
    }

    return croppedElements;
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




#pragma mark - MMPaperStateDelegate

-(void) didLoadState:(MMPaperState*)state{
    [NSThread performBlockOnMainThread:^{
        [self.delegate didLoadStateForPage:self];
    }];
}

-(void) didUnloadState:(MMPaperState *)state{
    [NSThread performBlockOnMainThread:^{
        [self.delegate didUnloadStateForPage:self];
    }];
}

@end
