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
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMPageCacheManager.h"
#import "MMLoadImageCache.h"
#import "UIView+Animations.h"
#import "Mixpanel.h"

dispatch_queue_t importThumbnailQueue;


@implementation MMEditablePaperView{
    // cached static values
    NSString* pagesPath;
    NSString* inkPath;
    NSString* plistPath;
    NSString* thumbnailPath;
    UIBezierPath* boundsPath;
    
    // we want to be able to track extremely
    // efficiently 1) if we have a thumbnail loaded,
    // and 2) if we have (or don't) a thumbnail at all
    UIImage* cachedImgViewImage;
    // this defaults to NO, which means we'll try to
    // load a thumbnail. if an image does not exist
    // on disk, then we'll set this to YES which will
    // prevent any more thumbnail loads until this page
    // is saved
    BOOL definitelyDoesNotHaveAnInkThumbnail;
    BOOL isLoadingCachedInkThumbnailFromDisk;
    
    // YES if the file exists at the path, NO
    // if it *might* exist
    BOOL fileExistsAtInkPath;
    BOOL fileExistsAtPlistPath;
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
        
        //
        // This pan gesture is used to pan/scale the page itself.
        rulerGesture = [[MMRulerToolGestureRecognizer alloc] initWithTarget:self action:@selector(didMoveRuler:)];
        
        //
        // This gesture is only allowed to run if the user is not
        // acting on an object on the page. defer to the long press
        // and the tap gesture, and only allow page pan/scale if
        // these fail
        [rulerGesture requireGestureRecognizerToFail:longPress];
//        [rulerGesture requireGestureRecognizerToFail:tap];
        [self addGestureRecognizer:rulerGesture];

        
        // initialize our state manager
        paperState = [[JotViewStateProxy alloc] initWithDelegate:self];
        paperState.delegate = self;
    }
    return self;
}

-(int) fullByteSize{
    return [super fullByteSize] + paperState.fullByteSize;
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

-(void) updateThumbnailVisibility{
    @throw kAbstractMethodException;
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

-(void) addDrawableViewToContentView{
//    [self.contentView addSubview:drawableView];
    // add the drawableView to the contentView
    @throw kAbstractMethodException;
}

-(void) setDrawableView:(JotView *)_drawableView{
    CheckMainThread;
    if(_drawableView && ![self hasStateLoaded]){
        debug_NSLog(@"oh no");
    }
    if(drawableView != _drawableView){
        if(!_drawableView && drawableView){
            [drawableView removeFromSuperview];
        }
        drawableView = _drawableView;
        if(drawableView){
            [self generateDebugView:YES];
            [self setFrame:self.frame];
            if([self.delegate isPageEditable:self] && [self hasStateLoaded]){
                // drawableView might be animating from
                // it's old page, so remove that animation
                // if any
                [drawableView.layer removeAllAnimations];
                [drawableView loadState:paperState];
                [self addDrawableViewToContentView];
                // anchor the view to the top left,
                // so that when we scale down, the drawable view
                // stays in place
                drawableView.layer.anchorPoint = CGPointMake(0,0);
                drawableView.layer.position = CGPointMake(0,0);
                drawableView.delegate = self;
                [self setEditable:YES];
                [self updateThumbnailVisibility];
            }
        }else{
            [self generateDebugView:NO];
            [self updateThumbnailVisibility];
        }
    }else if(drawableView && [self hasStateLoaded]){
        [self setEditable:YES];
        [self updateThumbnailVisibility];
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

-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize)pagePtSize andScale:(CGFloat)scale andContext:(JotGLContext*)context{
    if([paperState isStateLoaded]){
        [self didLoadState:paperState];
        return;
    }
    [paperState loadStateAsynchronously:async withSize:pagePtSize andScale:scale andContext:context andBufferManager:[JotBufferManager sharedInstance]];
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
-(void) saveToDisk:(void (^)(BOOL didSaveEdits))onComplete{
    // Sanity checks to generate our directory structure if needed
    [self pagesPath];
    
    // find out what our current undo state looks like.
    if([self hasEditsToSave] && ![paperState hasEditsToSave]){
//        NSLog(@"saved excess");
    }
    if([paperState hasEditsToSave]){
        // something has changed since the last time we saved,
        // so ask the JotView to save out the png of its data
        if(drawableView){
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
                                     definitelyDoesNotHaveAnInkThumbnail = NO;
                                     [paperState wasSavedAtImmutableState:immutableState];
                                     [[MMLoadImageCache sharedInstance] updateCacheForPath:[self thumbnailPath] toImage:thumbnail];
                                     cachedImgViewImage = thumbnail;
                                     onComplete(YES);
//                                     NSLog(@"saved backing store for %@ at %lu", self.uuid, (unsigned long)immutableState.undoHash);
                                 }else{
                                     // NOTE!
                                     // https://github.com/adamwulf/loose-leaf/issues/658
                                     // it's important to anyone listening to us that they potentially
                                     // wait for a pending save
                                     onComplete(NO);
//                                     NSLog(@"duplicate saved backing store for %@ at %lu", self.uuid, (unsigned long)immutableState.undoHash);
                                 }
                             }];
        }else{
//            NSLog(@"don't have a drawable view, notifying that our save is complete b/c we didn't need one");
            onComplete(NO);
        }

    }else{
        // already saved, but don't need to write
        // anything new to disk
//        debug_NSLog(@"no edits to save with hash %u", [drawableView undoHash]);
        onComplete(NO);
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
    if(!definitelyDoesNotHaveAnInkThumbnail && !cachedImgViewImage && !isLoadingCachedInkThumbnailFromDisk){
        isLoadingCachedInkThumbnailFromDisk = YES;
        count++;
        dispatch_async([MMEditablePaperView importThumbnailQueue], ^(void) {
            @autoreleasepool {
                //
                // load thumbnails into a cache for faster repeat loading
                // https://github.com/adamwulf/loose-leaf/issues/227
                UIImage* thumbnail = [self synchronouslyLoadInkPreview];
                if(!thumbnail){
                    definitelyDoesNotHaveAnInkThumbnail = YES;
                }
                isLoadingCachedInkThumbnailFromDisk = NO;
                cachedImgViewImage = thumbnail;
            }
        });
    }
}

-(UIImage*) synchronouslyLoadInkPreview{
    if(cachedImgViewImage){
        return cachedImgViewImage;
    }
    UIImage* thumbnail = [[MMLoadImageCache sharedInstance] imageAtPath:[self thumbnailPath]];
    if(!thumbnail){
        // we might be loading a new-user-content provided page,
        // so load from the bundle as a backup
        NSString* bundleThumbPath = [[[self bundledPagesPath] stringByAppendingPathComponent:[@"ink" stringByAppendingString:@".thumb"]] stringByAppendingPathExtension:@"png"];
        thumbnail = [[MMLoadImageCache sharedInstance] imageAtPath:bundleThumbPath];
    }
    return thumbnail;
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
    if(cachedImgViewImage || isLoadingCachedInkThumbnailFromDisk){
        // adding to these thread queues will make sure I unload
        // after any in progress load
        dispatch_async([MMEditablePaperView importThumbnailQueue], ^(void) {
            @autoreleasepool {
                cachedImgViewImage = nil;
            }
        });
    }
}

-(UIImage*) cachedImgViewImage{
    return cachedImgViewImage;
}

-(void) cancelCurrentStrokeIfAny{
    CheckMainThread;
    if(paperState.currentStroke){
        if([[JotStrokeManager sharedInstance] cancelStroke:paperState.currentStroke]){
            return;
        }
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
            if([gesture.validTouches count] < 2){
                [self.delegate didStopRuler:gesture];
            }else{
                [self.delegate didMoveRuler:gesture];
            }
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

-(void) willCancelStroke:(JotStroke*)stroke withTouch:(JotTouch*)touch{
    [delegate willCancelStroke:stroke withTouch:touch];
}

-(void) didCancelStroke:(JotStroke*)stroke withTouch:(JotTouch*)touch{
    [delegate didCancelStroke:stroke withTouch:touch];
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
            
            NSArray* redAndBlueSegments = nil;
            @try{
                redAndBlueSegments = [UIBezierPath redAndGreenAndBlueSegmentsCreatedFrom:boundsPath bySlicingWithPath:bez andNumberOfBlueShellSegments:nil];
            }@catch(NSException* e){
                // we had an exception when trying to clip this path.
                // the solution for now is just to add the entire segment
                // which will hapepn since [greenSegments count] will == 0
                // below.
                //
                // true fix is filed in https://github.com/adamwulf/loose-leaf/issues/562
                NSLog(@"unable to generate red/green/blue segments");
                [[[Mixpanel sharedInstance] people] increment:kMPNumberOfClippingExceptions by:@(1)];
            }
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
    debug_NSLog(@"disable gestures!");
}

-(void) jotSuggestsToEnableGestures{
    debug_NSLog(@"enable gestures!");
}

#pragma mark - File Paths

-(NSString*) pagesPath{
    if(!pagesPath){
        NSString* documentsPath = [NSFileManager documentsPath];
        pagesPath = [[documentsPath stringByAppendingPathComponent:@"Pages"] stringByAppendingPathComponent:[self uuid]];
        [NSFileManager ensureDirectoryExistsAtPath:pagesPath];
    }
    return pagesPath;
}

-(NSString*) bundledPagesPath{
    NSString* documentsPath = [[NSBundle mainBundle] pathForResource:@"Documents" ofType:nil];
    return [[documentsPath stringByAppendingPathComponent:@"Pages"] stringByAppendingPathComponent:[self uuid]];
}

-(NSString*) inkPath{
    if(!inkPath){
        inkPath = [[[self pagesPath] stringByAppendingPathComponent:@"ink"] stringByAppendingPathExtension:@"png"];
    }
    return inkPath;
}

-(NSString*) plistPath{
    if(!plistPath){
        plistPath = [[[self pagesPath] stringByAppendingPathComponent:@"info"] stringByAppendingPathExtension:@"plist"];
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
    if(fileExistsAtInkPath || [[NSFileManager defaultManager] fileExistsAtPath:[self inkPath]]){
        // save that the file exists at the path. this will reduce
        // the number of filesystem calls that we make to check for
        // fileExistsAtPath
        fileExistsAtInkPath = YES;
        return [self inkPath];
    }else{
        return [[[self bundledPagesPath] stringByAppendingPathComponent:@"ink"] stringByAppendingPathExtension:@"png"];
    }
}

-(NSString*) jotViewStatePlistPath{
    if(fileExistsAtPlistPath || [[NSFileManager defaultManager] fileExistsAtPath:[self plistPath]]){
        fileExistsAtPlistPath = YES;
        return [self plistPath];
    }else{
        return [[[self bundledPagesPath] stringByAppendingPathComponent:@"info"] stringByAppendingPathExtension:@"plist"];
    }
}

-(void) didLoadState:(JotViewStateProxy*)state{
    @throw kAbstractMethodException;
}

-(void) didUnloadState:(JotViewStateProxy *)state{
    [NSThread performBlockOnMainThread:^{
        [[MMPageCacheManager sharedInstance] didUnloadStateForPage:self];
    }];
}

@end
