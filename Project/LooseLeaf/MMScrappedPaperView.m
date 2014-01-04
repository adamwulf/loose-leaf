//
//  MMScrappedPaperView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrappedPaperView.h"
#import "PolygonToolDelegate.h"
#import "MMScrapView.h"
#import "MMScrapContainerView.h"
#import "NSThread+BlockAdditions.h"
#import "NSArray+Extras.h"
#import <JotUI/JotUI.h>
#import <JotUI/AbstractBezierPathElement-Protected.h>
#import "MMDebugDrawView.h"
#import "MMScrapsOnPaperState.h"
#import "MMImmutableScrapsOnPaperState.h"
#import <JotUI/UIColor+JotHelper.h>
#import <DrawKit-iOS/DrawKit-iOS.h>
#import "DKUIBezierPathClippedSegment+PathElement.h"


@implementation MMScrappedPaperView{
    UIView* scrapContainerView;
    NSString* scrapIDsPath;
    MMScrapsOnPaperState* scrapState;
}


static dispatch_queue_t concurrentBackgroundQueue;
+(dispatch_queue_t) concurrentBackgroundQueue{
    if(!concurrentBackgroundQueue){
        concurrentBackgroundQueue = dispatch_queue_create("com.milestonemade.looseleaf.scraps.concurrentBackgroundQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return concurrentBackgroundQueue;
}

- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid{
    self = [super initWithFrame:frame andUUID:_uuid];
    if (self) {
        // Initialization code
        scrapContainerView = [[MMScrapContainerView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:scrapContainerView];
        // anchor the view to the top left,
        // so that when we scale down, the drawable view
        // stays in place
        scrapContainerView.layer.anchorPoint = CGPointMake(0,0);
        scrapContainerView.layer.position = CGPointMake(0,0);

        panGesture.scrapDelegate = self;
        
        scrapState = [[MMScrapsOnPaperState alloc] initWithScrapIDsPath:self.scrapIDsPath];
        scrapState.delegate = self;
    }
    return self;
}


#pragma mark - Scraps

/**
 * the input path contains the offset
 * and size of the new scrap from its
 * bounds
 */
-(void) addScrapWithPath:(UIBezierPath*)path{

    // find our current "best" of an unrotated path
    CGRect pathBounds = path.bounds;
    CGFloat initialSize = pathBounds.size.width * pathBounds.size.height;
    CGFloat lastBestSize = initialSize;
    CGFloat lastBestRotation = 0;
    
    // now copy the path, and we'll rotate this to
    // find the best rotation that'll give us the
    // minimum (or very close to min) square pixels
    // to use as the backing
    UIBezierPath* rotatedPath = [path copy];
    
    CGFloat numberOfSteps = 30.0;
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(M_PI / 2.0 / numberOfSteps);
    CGFloat currentStepRotation = 0;
    for(int i=0;i<numberOfSteps;i++){
        // rotate the path, and track what that rotation value is:
        currentStepRotation += M_PI / 2.0 / numberOfSteps;
        [rotatedPath applyTransform:rotationTransform];
        // now calculate how many square pixels we'd need
        // to store that new path
        CGRect rotatedPathBounds = rotatedPath.bounds;
        CGFloat rotatedPxSize = rotatedPathBounds.size.width * rotatedPathBounds.size.height;
        // if it's fewer square pixels, then save
        // that rotation value
        if(rotatedPxSize < lastBestSize){
            lastBestRotation = currentStepRotation;
            lastBestSize = rotatedPxSize;
        }
    }
    
//    NSLog(@"memory savings of: %f", (1 - lastBestSize / initialSize));
    
    if(lastBestRotation){
        // ok, we have a rotation that'll give us a smaller square pixels
        // for the scrap's backing texture. make sure to rotate the
        // scrap around its center.
        CGPoint pathCenter = path.center;
        CGPoint initialFirstPoint = path.firstPoint;
        // first, translate to the center,
        CGAffineTransform rotateAroundCenterTransform = CGAffineTransformMakeTranslation(-pathCenter.x, -pathCenter.y);
        // then rotate,
        rotateAroundCenterTransform = CGAffineTransformConcat(rotateAroundCenterTransform, CGAffineTransformMakeRotation(lastBestRotation));
        // then translate back to its position
        rotateAroundCenterTransform = CGAffineTransformConcat(rotateAroundCenterTransform, CGAffineTransformMakeTranslation(pathCenter.x, pathCenter.y));
        [path applyTransform:rotateAroundCenterTransform];

        // the next bit is to calculate how much to move the
        // scrap so that it's new center will align the path
        // to it's old position.
        //
        // rotate the path back around its new center (as it will rotate in its scrap form)
        // this path now needs to be re-aligned with its old center'd path.
        // so look at how far the firstPoint moved in each path, and adjust the rotated
        // smaller bounded path by that much, so that the rotated scrap will appear
        // on top of the original unrotated input path
        UIBezierPath* adjustmentCalculationPath = [path copy];
        CGPoint adjustmentPathCenter = adjustmentCalculationPath.center;
        [adjustmentCalculationPath applyTransform:CGAffineTransformMakeTranslation(-adjustmentPathCenter.x, -adjustmentPathCenter.y)];
        [adjustmentCalculationPath applyTransform:CGAffineTransformMakeRotation(-lastBestRotation)];
        [adjustmentCalculationPath applyTransform:CGAffineTransformMakeTranslation(adjustmentPathCenter.x, adjustmentPathCenter.y)];
        CGPoint afterFirstPoint = adjustmentCalculationPath.firstPoint;
        CGPoint adjustment = CGPointMake(initialFirstPoint.x - afterFirstPoint.x, initialFirstPoint.y - afterFirstPoint.y);

        // this adjustment will account for the fact that the scrap
        // has a different center point than the input path
        // to this method.
        //
        // the scrap rotates around adjustmentPathCenter. so we need to
        // move the scrap so that an rotated scrap with the new path
        // would line up with the original unrotated scrap
        [path applyTransform:CGAffineTransformMakeTranslation(adjustment.x, adjustment.y)];
    }

    // now add the scrap, and rotate it to counter-act
    // the rotation we added to the path itself
    [self addScrapWithPath:path andRotation:-lastBestRotation];
}




/**
 * the input path contains the offset
 * and size of the new scrap from its
 * bounds
 */
-(MMScrapView*) addScrapWithPath:(UIBezierPath*)path andRotation:(CGFloat)lastBestRotation{
    //
    // at this point, we have the correct path and rotation that will
    // give us the minimal square px. For instance, drawing a thin diagonal
    // strip of paper will create a thin texture and rotate it, instead of
    // an unrotated thick rectangle.
    
    CGPoint pathCenter = path.center;
    
    MMScrapView* newScrap = [[MMScrapView alloc] initWithBezierPath:path];
    [scrapContainerView addSubview:newScrap];
    [newScrap loadStateAsynchronously:NO];
    [newScrap setShouldShowShadow:[self isEditable]];
    
    [newScrap setScale:1.00];
    [newScrap setRotation:lastBestRotation];

    CGPoint scrapCenter = newScrap.center;
    
    NSLog(@"pc: %f %f", pathCenter.x, pathCenter.y);
    NSLog(@"xc: %f %f", scrapCenter.x, scrapCenter.y);
    
    //    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
    //        [newScrap setRotation:-lastBestRotation];
    //        [newScrap setScale:1];
    //    } completion:nil];
    
    [self saveToDisk];
    return newScrap;
}





-(void) addScrap:(MMScrapView*)scrap{
    [scrapContainerView addSubview:scrap];
    [scrap setShouldShowShadow:[self isEditable]];
    [self saveToDisk];
}

-(BOOL) hasScrap:(MMScrapView*)scrap{
    return [[self scraps] containsObject:scrap];
}

/**
 * returns all subviews in back-to-front
 * order
 */
-(NSArray*) scraps{
    // we'll be calling this method quite often,
    // so don't create a new auto-released array
    // all the time. instead, just return our subview
    // array, so that if the caller just needs count
    // or to iterate on the main thread, we don't
    // spend unnecessary resources copying a potentially
    // long array.
    return scrapContainerView.subviews;
}

#pragma mark - Pinch and Zoom

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    CGFloat _scale = frame.size.width / self.superview.frame.size.width;
    scrapContainerView.transform = CGAffineTransformMakeScale(_scale, _scale);
}

#pragma mark - Pan and Scale Scraps

/**
 * this is an important method to ensure that panning scraps and panning pages
 * don't step on each other.
 *
 * when panning, single touches are held as "possible" touches for both panning
 * gestures. once two possible touches exist in the pan gestures, then one of the
 * two gestures will own it.
 *
 * when a pan gesture takes ownership of a pair of touches, it needs to notify
 * the other pan gestures that it owns it. Since the PanPage gesture is owned
 * by the page and the PanScrap gesture is owned by the stack, we need these
 * delegate calls to be passed from gesture -> the gesture delegate -> page or stack
 * without causing an infinite loop of delegate calls.
 *
 * in this way, each gesture will notify its own delegate, either the stack or page.
 * the stack and page will notify each other *only* of touch ownerships from gestures
 * that they own. so the page will notify about PanPage ownership, and the stack
 * will notify of PanScrap ownership
 */
-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture{
    [panGesture ownershipOfTouches:touches isGesture:gesture];
    if([gesture isKindOfClass:[MMPanAndPinchGestureRecognizer class]]){
        // only notify of our own gestures
        [self.delegate ownershipOfTouches:touches isGesture:gesture];
    }
}

-(BOOL) panScrapRequiresLongPress{
    return [self.delegate panScrapRequiresLongPress];
}

-(void) panAndScale:(MMPanAndPinchGestureRecognizer *)_panGesture{
    [[MMDebugDrawView sharedInstace] clear];
    
    [super panAndScale:_panGesture];
}

#pragma mark - JotViewDelegate



-(NSArray*) willAddElementsToStroke:(NSArray *)elements fromPreviousElement:(AbstractBezierPathElement*)_previousElement{
    NSArray* strokeElementsToDraw = [super willAddElementsToStroke:elements fromPreviousElement:_previousElement];
    
    if(![self.scraps count]){
        return strokeElementsToDraw;
    }
    
    NSMutableArray* strokesToCrop = [NSMutableArray arrayWithArray:strokeElementsToDraw];
    
    for(MMScrapView* scrap in [self.scraps reverseObjectEnumerator]){
        // find the bounding box of the scrap, so we can determine
        // quickly if they even possibly intersect
        UIBezierPath* scrapClippingPath = scrap.clippingPath;
        
        CGRect boundsOfScrap = scrapClippingPath.bounds;
        
        NSMutableArray* nextStrokesToCrop = [NSMutableArray array];
        
        // the first step is to loop over all of the strokes
        // to see where and if they intersect with our scraps.
        //
        // if they intersect, then we'll split that element into pieces
        // and add some pieces to the scrap and return the rest.
        AbstractBezierPathElement* previousElement = _previousElement;
        for(AbstractBezierPathElement* element in strokesToCrop){
            if(!CGRectIntersectsRect(element.bounds, boundsOfScrap)){
                // if we don't intersect the bounds of a scrap, then we definitely
                // don't intersect it's path, so just add it to our return value
                // (which we'll check on other scraps too)
                [nextStrokesToCrop addObject:element];
            }else if([element isKindOfClass:[CurveToPathElement class]]){
                // ok, we intersect at least the bounds of the scrap, so check
                // to see if we intersect its path and if we should split it

                // create a simple uibezier path that represents just the path
                // of this single element
                UIBezierPath* strokePath = [element bezierPathSegment];

                // track which elements we should add to the scrap
                // instead of continue to chop and add to the page / other scrap
                NSMutableArray* elementsToAddToScrap = [NSMutableArray array];

                // now find out where this element intersects the scrap.
                // this return value will give us the paths of the intersection
                // and the difference, as well as the tvalues on our element
                // path (strokePath) that the intersections happen.
                //
                // this will let us calcualte how much the width/color/rotation
                // change during each split
                NSArray* redAndBlueSegments = [UIBezierPath redAndGreenAndBlueSegmentsCreatedFrom:scrapClippingPath bySlicingWithPath:strokePath];
                NSArray* redSegments = [redAndBlueSegments firstObject]; // intersection
                NSArray* greenSegments = [redAndBlueSegments objectAtIndex:1]; // difference
                
                if(![redSegments count]){
                    // we can't make the same optimization for [.difference isEmpty],
                    // because the element needs to be transformed into the scrap's
                    // coordinate space no matter what. this means that we can't
                    // simply add the element to elementsToAddToScrap
                    //
                    // if the entire element lands in the difference (intersection is empty)
                    // then add the entire element to the page/other scraps to look at
                    [nextStrokesToCrop addObject:element];
                }else{
                    // take the difference of the drawn stroke, and send those elements
                    // to the next scrap beneath us to clip them smaller still.
                    // any unclipped elements will be passed back up to the page
                    // itself
                    for(DKUIBezierPathClippedSegment* segment in greenSegments){
                        [nextStrokesToCrop addObjectsFromArray:[segment convertToPathElementsFromColor:previousElement.color
                                                                                             toColor:element.color
                                                                                           fromWidth:previousElement.width
                                                                                             toWidth:element.width]];
                    }
                    

                    // since a scrap's center point is changed if the scrap is being
                    // held, we can't just use scrap.center to adjust the path for
                    // rotations etc. we need to calculate the center of a scrap
                    // so that it doesn't matter if it's position/anchor have been
                    // changed or not.
                    CGPoint calculatedScrapCenter = [scrap convertPoint:CGPointMake(scrap.bounds.size.width/2, scrap.bounds.size.height/2) toView:scrap.superview];
                    
                    // determine the tranlsation that we need to make on the path
                    // so that it's moved into the scrap's coordinate space
                    CGAffineTransform entireTransform = CGAffineTransformIdentity;
                    
                    // find the scrap location in open gl
                    CGAffineTransform flipTransform = CGAffineTransformMake(1, 0, 0, -1, 0, self.originalUnscaledBounds.size.height);
                    CGPoint scrapCenterInOpenGL = CGPointApplyAffineTransform(calculatedScrapCenter, flipTransform);
                    // center the stroke around the scrap center,
                    // so that any scale/rotate happens in relation to the scrap
                    entireTransform = CGAffineTransformConcat(entireTransform, CGAffineTransformMakeTranslation(-scrapCenterInOpenGL.x, -scrapCenterInOpenGL.y));
                    // now scale and rotate the scrap
                    // we reverse the scale, b/c the scrap itself is scaled. these two together will make the
                    // path have a scale of 1 after it's added
                    entireTransform = CGAffineTransformConcat(entireTransform, CGAffineTransformMakeScale(1.0/scrap.scale, 1.0/scrap.scale));
                    // this one confuses me honestly. i would think that
                    // i'd need to rotate by -scrap.rotation so that with the
                    // scrap's rotation it'd end up not rotated at all. somehow the
                    // scrap has an effective rotation of -rotation (?).
                    //
                    // thinking about it some more, I think the issue is that
                    // scrap.rotation is defined as the rotation in Core Graphics
                    // coordinate space, but since OpenGL is flipped, then the
                    // rotation flips.
                    //
                    // think of a spinning clock. it spins in different directions
                    // if you look at it from the top or bottom.
                    //
                    // either way, when i rotate the path by scrap.rotation, it ends up
                    // in the correct visible space. it works!
                    entireTransform = CGAffineTransformConcat(entireTransform, CGAffineTransformMakeRotation(scrap.rotation));
                    
                    // before this line, the path is in the correct place for a scrap
                    // that has (0,0) in it's center. now move everything so that
                    // (0,0) is in the bottom/left of the scrap. (this might also
                    // help w/ the rotation somehow, since the rotate happens before the
                    // translate (?)
                    CGPoint recenter = CGPointMake(scrap.bounds.size.width/2, scrap.bounds.size.height/2);
                    entireTransform = CGAffineTransformConcat(entireTransform, CGAffineTransformMakeTranslation(recenter.x, recenter.y));
                    
                    // take the difference of the drawn stroke, and send those elements
                    // to the next scrap beneath us to clip them smaller still.
                    // any unclipped elements will be passed back up to the page
                    // itself
                    for(DKUIBezierPathClippedSegment* segment in redSegments){
                        [elementsToAddToScrap addObjectsFromArray:[segment convertToPathElementsFromColor:previousElement.color
                                                                                               toColor:element.color
                                                                                             fromWidth:previousElement.width
                                                                                               toWidth:element.width
                                                                                         withTransform:entireTransform
                                                                                                 andScale:scrap.scale]];
                    }
                }
                if([elementsToAddToScrap count]){
                    [scrap addElements:elementsToAddToScrap];
                }
            }else{
                [nextStrokesToCrop addObject:element];
            }
            
            previousElement = element;
        }
        
        strokesToCrop = nextStrokesToCrop;
    }
    
    // anything that's left over at this point
    // is fair game for to add to the page itself
    return strokesToCrop;
}


#pragma mark - MMRotationManagerDelegate

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading{
    for(MMScrapView* scrap in self.scraps){
        [scrap didUpdateAccelerometerWithRawReading:-currentRawReading];
    }
}

#pragma mark - Polygon and Scrap builder

-(void) beginShapeAtPoint:(CGPoint)point{
    // send touch event to the view that
    // will display the drawn polygon line
    [shapeBuilderView clear];
    [shapeBuilderView addTouchPoint:point];
}

-(BOOL) continueShapeAtPoint:(CGPoint)point{
    // send touch event to the view that
    // will display the drawn polygon line
    if([shapeBuilderView addTouchPoint:point]){
        [self completeBuildingNewScrap];
        return NO;
    }
    return YES;
}

-(void) finishShapeAtPoint:(CGPoint)point{
    // send touch event to the view that
    // will display the drawn polygon line
    //
    // and also process the touches into the new
    // scrap polygon shape, and add that shape
    // to the page
    [shapeBuilderView addTouchPoint:point];
    [self completeBuildingNewScrap];
}

-(void) cancelShapeAtPoint:(CGPoint)point{
    // we've cancelled the polygon (possibly b/c
    // it was a pan/pinch instead), so clear
    // the drawn polygon and reset.
    [shapeBuilderView clear];
}

-(void) completeBuildingNewScrap{
    UIBezierPath* shape = [shapeBuilderView completeAndGenerateShape];
    [shapeBuilderView clear];
    if(shape.isPathClosed){
        UIBezierPath* shapePath = [shape copy];
        [shapePath applyTransform:CGAffineTransformMakeScale(1/self.scale, 1/self.scale)];
        [self addScrapWithPath:shapePath];
    }
}


#pragma mark - Scissors


-(void) beginScissorAtPoint:(CGPoint)point{
    // send touch event to the view that
    // will display the drawn polygon line
    [shapeBuilderView clear];
    [shapeBuilderView addTouchPoint:point];
}

-(BOOL) continueScissorAtPoint:(CGPoint)point{
    // send touch event to the view that
    // will display the drawn polygon line
    if([shapeBuilderView addTouchPoint:point]){
        [self completeScissorsCut];
        return NO;
    }
    return YES;
}

-(void) finishScissorAtPoint:(CGPoint)point{
    // send touch event to the view that
    // will display the drawn polygon line
    //
    // and also process the touches into the new
    // scrap polygon shape, and add that shape
    // to the page
    [shapeBuilderView addTouchPoint:point];
    [self completeScissorsCut];
}

-(void) cancelScissorAtPoint:(CGPoint)point{
    // we've cancelled the polygon (possibly b/c
    // it was a pan/pinch instead), so clear
    // the drawn polygon and reset.
    [shapeBuilderView clear];
}


-(void) completeScissorsCut{
    // in this debug version of the scissor, it will draw
    // a thick black line where it would do the cut
    //
    // this is just to prove that we can take the path
    // (closed or unclosed) and do something productive
    // with it
    UIBezierPath* shapePath = [shapeBuilderView completeAndGenerateShape];
    [shapeBuilderView clear];
    NSMutableArray* elements = [NSMutableArray array];
    [shapePath applyTransform:CGAffineTransformMakeScale(1/self.scale, 1/self.scale)];
    
    // flip from CoreGraphics to OpenGL coordinates
    CGAffineTransform flipTransform = CGAffineTransformMake(1, 0, 0, -1, 0, self.originalUnscaledBounds.size.height);
    [shapePath applyTransform:flipTransform];
    
    __block CGPoint previousEndpoint = shapePath.firstPoint;
    [shapePath iteratePathWithBlock:^(CGPathElement pathEle){
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
            newElement.color = [UIColor blackColor];
            newElement.width = 10.0;
            [elements addObject:newElement];
        }
    }];
    
    [drawableView addElements:[self willAddElementsToStroke:elements fromPreviousElement:nil]];
}


#pragma mark - Save and Load

/**
 * TODO: when our drawable view is set, our state
 * should already be 100% loaded, including scrap views
 *
 * ask super to set our drawable view, and we need to set
 * our scrap views
 */
-(void) setDrawableView:(JotView *)_drawableView{
    [super setDrawableView:_drawableView];
}

-(void) setEditable:(BOOL)isEditable{
    [super setEditable:isEditable];
    [scrapState setShouldShowShadows:isEditable];
}


-(BOOL) hasEditsToSave{
    return [super hasEditsToSave];
}

-(void) saveToDisk{
    
    // track if our back ground page has saved
    dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
    // track if all of our scraps have saved
    dispatch_semaphore_t sema2 = dispatch_semaphore_create(0);

    // save our backing page
    [super saveToDisk:^{
        dispatch_semaphore_signal(sema1);
    }];
    
    dispatch_async([MMScrapsOnPaperState importExportStateQueue], ^(void) {
        @autoreleasepool {
            [[scrapState immutableState] saveToDisk];
            dispatch_semaphore_signal(sema2);
        }
    });

    dispatch_async([MMScrappedPaperView concurrentBackgroundQueue], ^(void) {
        @autoreleasepool {
            dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_wait(sema2, DISPATCH_TIME_FOREVER);
            dispatch_release(sema1);
            dispatch_release(sema2);
            if([self hasEditsToSave]){
                // our save failed. this may happen if we
                // call [saveToDisk] in very quick succession
                // so that the 1st call is still saving, and the
                // 2nd ends early b/c it knows the 1st is still going
                return;
            }
            [NSThread performBlockOnMainThread:^{
                [self.delegate didSavePage:self];
            }];
        }
    });
}

-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize)pagePixelSize andContext:(JotGLContext*)context{
    [super loadStateAsynchronously:async withSize:pagePixelSize andContext:context];
    [scrapState loadStateAsynchronously:async andMakeEditable:YES];
}

-(void) unloadState{
    [super unloadState];
    [[scrapState immutableState] saveToDisk];
    // unloading the scrap state will also remove them
    // from their superview (us)
    [scrapState unload];
}

-(BOOL) hasStateLoaded{
    return [super hasStateLoaded];
}

-(void) didLoadScrap:(MMScrapView*)scrap{
    [scrapContainerView addSubview:scrap];
}

-(void) didLoadAllScrapsFor:(MMScrapsOnPaperState*)scrapState{
    // check to see if we've also loaded
    [self didLoadState:self.paperState];
}

/**
 * load any scrap previews, if applicable.
 * not sure if i'll just draw these into the
 * page preview or not
 */
-(void) loadCachedPreview{
    // make sure our thumbnail is loaded
    [super loadCachedPreview];
    // make sure our scraps' thumbnails are loaded
    [scrapState loadStateAsynchronously:YES andMakeEditable:NO];
}

-(void) unloadCachedPreview{
    // free our preview memory
    [super unloadCachedPreview];
    // free all scraps from memory too
    [scrapState unload];
}

#pragma mark - JotViewStateProxyDelegate

/**
 * TODO: only fire off these state methods
 * if we have also loaded state for our scraps
 * https://github.com/adamwulf/loose-leaf/issues/254
 */
-(void) didLoadState:(JotViewStateProxy*)state{
    if([self hasStateLoaded]){
        [NSThread performBlockOnMainThread:^{
            [self.delegate didLoadStateForPage:self];
        }];
    }
}

-(void) didUnloadState:(JotViewStateProxy *)state{
    [NSThread performBlockOnMainThread:^{
        [self.delegate didUnloadStateForPage:self];
    }];
}

#pragma mark - Paths

-(NSString*) scrapIDsPath{
    if(!scrapIDsPath){
        scrapIDsPath = [[[self pagesPath] stringByAppendingPathComponent:@"scrapIDs"] stringByAppendingPathExtension:@"plist"];
    }
    return scrapIDsPath;
}


@end
