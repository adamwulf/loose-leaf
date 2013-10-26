//
//  MMScrappedPaperView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrappedPaperView.h"
#import "PolygonToolDelegate.h"
#import "UIColor+ColorWithHex.h"
#import "MMScrapView.h"
#import "MMScrapContainerView.h"
#import "NSThread+BlockAdditions.h"
#import "NSArray+Extras.h"
#import "DrawKit-iOS.h"
#import <JotUI/JotUI.h>
#import <JotUI/AbstractBezierPathElement-Protected.h>
#import "MMDebugDrawView.h"
#import "MMScrapsOnPaperState.h"
#import "MMImmutableScrapsOnPaperState.h"
#import "MMPaperState.h"
#import "DKUIBezierPathClippedSegmentTPair.h"
#import <JotUI/UIColor+JotHelper.h>


@implementation MMScrappedPaperView{
    UIView* scrapContainerView;
    NSString* scrapIDsPath;
    MMScrapsOnPaperState* scrapState;
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
    MMScrapView* newScrap = [[MMScrapView alloc] initWithBezierPath:path];
    [scrapContainerView addSubview:newScrap];
    [newScrap loadStateAsynchronously:NO];
    [newScrap setShouldShowShadow:[self isEditable]];
    
    newScrap.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.03, 1.03);
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        newScrap.transform = CGAffineTransformIdentity;
    } completion:nil];

    [path closePath];
    [self saveToDisk];
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
        
        NSMutableArray* newStrokesToCrop = [NSMutableArray array];
        
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
                [newStrokesToCrop addObject:element];
            }else if([element isKindOfClass:[CurveToPathElement class]]){
                // ok, we intersect at least the bounds of the scrap, so check
                // to see if we intersect its path and if we should split it
                CurveToPathElement* curveElement = (CurveToPathElement*)element;

                // create a imple uibezier path that represents just the path
                // of this single element
                UIBezierPath* strokePath = [UIBezierPath bezierPath];
                [strokePath moveToPoint:curveElement.startPoint];
                [strokePath addCurveToPoint:curveElement.endPoint controlPoint1:curveElement.ctrl1 controlPoint2:curveElement.ctrl2];

                // now find out where this element intersects the scrap.
                // this return value will give us the paths of the intersection
                // and the difference, as well as the tvalues on our element
                // path (strokePath) that the intersections happen.
                //
                // this will let us calcualte how much the width/color/rotation
                // change during each split
                DKUIBezierPathClippingResult* clippingAndIntersectionMetaInformation = [strokePath clipUnclosedPathToClosedPath:scrapClippingPath];
                
                // track which elements we should add to the scrap
                // instead of continue to chop and add to the page / other scrap
                NSMutableArray* elementsToAddToScrap = [NSMutableArray array];

                if([clippingAndIntersectionMetaInformation.intersection isEmpty]){
                    //
                    // we can't make the same optimization for [.difference isEmpty],
                    // because the element needs to be transformed into the scrap's
                    // coordinate space no matter what. this means that we can't
                    // simply add the element to elementsToAddToScrap
                    //
                    // if the entire element lands in the difference (intersection is empty)
                    // then add the entire element to the page/other scraps to look at
                    [newStrokesToCrop addObject:element];
                }else{
                    //
                    // now we've taken our stroke segment, and computed the intersection
                    // and difference with the scrap. we'll add the difference here to
                    // our "strokes to newStrokesToCrop array. we'll crop these with scraps
                    // below this current scrap on our next loop.
                    __block CGPoint previousEndpoint = strokePath.firstPoint;
                    
                    //
                    // information to track changes in width and color
                    // the index will traack which info in clippingAndIntersectionMetaInformation
                    // is relevant to our difference
                    __block int clippingInformationIndex = 0;
                    // this is the total width difference along our original element,
                    // and we'll use this to calculate what our width should be along
                    // our chopped difference/intersection
                    CGFloat widthDiff = element.width - previousElement.width;
                    CGFloat rotationDiff = element.rotation - previousElement.rotation;
                    GLfloat _prevColor[4], elementColor[4];
                    GLfloat _colorDiff[4];
                    CGFloat* prevColor = (CGFloat*)_prevColor;
                    CGFloat* colorDiff = (CGFloat*)_colorDiff;
                    [previousElement.color getRGBAComponents:prevColor];
                    [element.color getRGBAComponents:elementColor];
                    colorDiff[0] = elementColor[0] - prevColor[0];
                    colorDiff[1] = elementColor[1] - prevColor[1];
                    colorDiff[2] = elementColor[2] - prevColor[2];
                    colorDiff[3] = elementColor[3] - prevColor[3];
                    [clippingAndIntersectionMetaInformation.difference iteratePathWithBlock:^(CGPathElement pathEle){
                        AbstractBezierPathElement* newElement = nil;
                        DKUIBezierPathClippedSegmentTPair* clippingInformation = [clippingAndIntersectionMetaInformation.differenceTValues objectAtIndex:clippingInformationIndex];
                        //
                        // there are two possibilities - either it's a move to
                        // or a curve/line to.
                        if(pathEle.type == kCGPathElementMoveToPoint){
                            // if it's a move to, then we're just beginning this next segment.
                            // create the MoveTo element and initialize it's width/color/rotation
                            // to what it would have been at that location if we hand't split
                            newElement = [MoveToPathElement elementWithMoveTo:pathEle.points[0]];
                            previousEndpoint = pathEle.points[0];
                            
                            CGFloat tValueAtStartPoint = clippingInformation.tValueStart.tValue1;
                            CGFloat red = prevColor[0] + colorDiff[0] * tValueAtStartPoint;
                            CGFloat green = prevColor[1] + colorDiff[1] * tValueAtStartPoint;
                            CGFloat blue = prevColor[2] + colorDiff[2] * tValueAtStartPoint;
                            CGFloat alpha = prevColor[3] + colorDiff[3] * tValueAtStartPoint;
                            if(element.color){
                                newElement.color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
                            }else{
                                newElement.color = nil;
                            }
                            newElement.width = previousElement.width + widthDiff*tValueAtStartPoint;
                            newElement.rotation = previousElement.rotation + rotationDiff*tValueAtStartPoint;
                        }else if(pathEle.type == kCGPathElementAddCurveToPoint ||
                                 pathEle.type == kCGPathElementAddLineToPoint){
                            // if i'ts a curve/line to, then this is the meat of the
                            // curve. create the element, and set it's width/color/rotation
                            // to what it would have been at the end of this peice.
                            //
                            // when this is rendered, it'll draw a line with the attributes
                            // interpolating between the MoveTo defined above, and this curveTo
                            if(pathEle.type == kCGPathElementAddCurveToPoint){
                                // curve
                                newElement = [CurveToPathElement elementWithStart:previousEndpoint
                                                                       andCurveTo:pathEle.points[2]
                                                                      andControl1:pathEle.points[0]
                                                                      andControl2:pathEle.points[1]];
                                previousEndpoint = pathEle.points[2];
                            }else if(pathEle.type == kCGPathElementAddLineToPoint){
                                newElement = [CurveToPathElement elementWithStart:previousEndpoint andLineTo:pathEle.points[0]];
                                previousEndpoint = pathEle.points[0];
                            }
                            
                            // be sure to set color/width/etc
                            CGFloat tValueAtEndPoint = clippingInformation.tValueEnd.tValue1;
                            if(element.color){
                                CGFloat red = prevColor[0] + colorDiff[0] * tValueAtEndPoint;
                                CGFloat green = prevColor[1] + colorDiff[1] * tValueAtEndPoint;
                                CGFloat blue = prevColor[2] + colorDiff[2] * tValueAtEndPoint;
                                CGFloat alpha = prevColor[3] + colorDiff[3] * tValueAtEndPoint;
                                newElement.color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
                            }else{
                                newElement.color = nil;
                            }
                            newElement.width = previousElement.width + widthDiff*tValueAtEndPoint;
                            newElement.rotation = previousElement.rotation + rotationDiff*tValueAtEndPoint;
                            
                            clippingInformationIndex++;
                        }
                        if(newElement){
                            [newStrokesToCrop addObject:newElement];
                        }
                    }];
                    
                    // this UIBezierPath represents the intersection of our input
                    // stroke over our scrap. this path needs to be adjusted into
                    // the scrap's coordinate system and then added to the scrap
                    //
                    // I'm applying transforms to this path below, so if i were to
                    // reuse this path I'd want to [copy] it. but i don't need to
                    // because I only use it once.
                    UIBezierPath* inter = clippingAndIntersectionMetaInformation.intersection;
                    // if the intersection contains any segments at all
                    
                    previousEndpoint = strokePath.firstPoint;
                    
                    // find the scrap location in open gl
                    CGAffineTransform flipTransform = CGAffineTransformMake(1, 0, 0, -1, 0, self.bounds.size.height);
                    CGPoint scrapCenterInOpenGL = CGPointApplyAffineTransform(scrap.center, flipTransform);
                    // center the stroke around the scrap center,
                    // so that any scale/rotate happens in relation to the scrap
                    [inter applyTransform:CGAffineTransformMakeTranslation(-scrapCenterInOpenGL.x, -scrapCenterInOpenGL.y)];
                    // now scale and rotate the scrap
                    // we reverse the scale, b/c the scrap itself is scaled. these two together will make the
                    // path have a scale of 1 after it's added
                    [inter applyTransform:CGAffineTransformMakeScale(1.0/scrap.scale, 1.0/scrap.scale)];
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
                    // either way, when i rotate the path by -scrap.rotation, it ends up
                    // in the correct visible space. it works!
                    [inter applyTransform:CGAffineTransformMakeRotation(scrap.rotation)];
                    
                    // before this line, the path is in the correct place for a scrap
                    // that has (0,0) in it's center. now move everything so that
                    // (0,0) is in the bottom/left of the scrap. (this might also
                    // help w/ the rotation somehow, since the rotate happens before the
                    // translate (?)
                    CGPoint recenter = CGPointMake(scrap.bounds.size.width/2, scrap.bounds.size.height/2);
                    [inter applyTransform:CGAffineTransformMakeTranslation(recenter.x, recenter.y)];
                    
                    
                    // here's our meta for the segment tvalue information
                    clippingInformationIndex = 0;
                    // now add it to the scrap!
                    [inter iteratePathWithBlock:^(CGPathElement pathEle){
                        AbstractBezierPathElement* newElement = nil;
                        DKUIBezierPathClippedSegmentTPair* clippingInformation = [clippingAndIntersectionMetaInformation.intersectionTValues objectAtIndex:clippingInformationIndex];
                        if(pathEle.type == kCGPathElementMoveToPoint){
                            newElement = [MoveToPathElement elementWithMoveTo:pathEle.points[0]];
                            previousEndpoint = pathEle.points[0];
                            CGFloat tValueAtStartPoint = clippingInformation.tValueStart.tValue1;
                            if(element.color){
                                CGFloat red = prevColor[0] + colorDiff[0] * tValueAtStartPoint;
                                CGFloat green = prevColor[1] + colorDiff[1] * tValueAtStartPoint;
                                CGFloat blue = prevColor[2] + colorDiff[2] * tValueAtStartPoint;
                                CGFloat alpha = prevColor[3] + colorDiff[3] * tValueAtStartPoint;
                                newElement.color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
                            }else{
                                newElement.color = nil;
                            }
                            newElement.width = previousElement.width + widthDiff*tValueAtStartPoint;
                            newElement.width /= scrap.scale;
                            newElement.rotation = previousElement.rotation + rotationDiff*tValueAtStartPoint;
                        }else if(pathEle.type == kCGPathElementAddCurveToPoint ||
                                 pathEle.type == kCGPathElementAddLineToPoint){
                            if(pathEle.type == kCGPathElementAddCurveToPoint){
                                // curve
                                newElement = [CurveToPathElement elementWithStart:previousEndpoint
                                                                       andCurveTo:pathEle.points[2]
                                                                      andControl1:pathEle.points[0]
                                                                      andControl2:pathEle.points[1]];
                                previousEndpoint = pathEle.points[2];
                            }else if(pathEle.type == kCGPathElementAddLineToPoint){
                                newElement = [CurveToPathElement elementWithStart:previousEndpoint andLineTo:pathEle.points[0]];
                                previousEndpoint = pathEle.points[0];
                            }
                            CGFloat tValueAtEndPoint = clippingInformation.tValueEnd.tValue1;
                            if(element.color){
                                CGFloat red = prevColor[0] + colorDiff[0] * tValueAtEndPoint;
                                CGFloat green = prevColor[1] + colorDiff[1] * tValueAtEndPoint;
                                CGFloat blue = prevColor[2] + colorDiff[2] * tValueAtEndPoint;
                                CGFloat alpha = prevColor[3] + colorDiff[3] * tValueAtEndPoint;
                                newElement.color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
                            }else{
                                newElement.color = nil;
                            }
                            newElement.width = previousElement.width + widthDiff*tValueAtEndPoint;
                            newElement.width /= scrap.scale;
                            newElement.rotation = previousElement.rotation + rotationDiff*tValueAtEndPoint;
                            
                            clippingInformationIndex++;
                        }
                        if(newElement){
                            [elementsToAddToScrap addObject:newElement];
                        }
                    }];
                }
                if([elementsToAddToScrap count]){
                    [scrap addElements:elementsToAddToScrap];
                }
            }else{
                [newStrokesToCrop addObject:element];
            }
            
            previousElement = element;
        }
        
        strokesToCrop = newStrokesToCrop;
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

#pragma mark - PolygonToolDelegate

-(void) beginShapeAtPoint:(CGPoint)point{
    // send touch event to the view that
    // will display the drawn polygon line
//    NSLog(@"begin");
    [shapeBuilderView clear];
    
    [shapeBuilderView addTouchPoint:point];
}

-(BOOL) continueShapeAtPoint:(CGPoint)point{
    // noop for now
    // send touch event to the view that
    // will display the drawn polygon line
    if([shapeBuilderView addTouchPoint:point]){
        [self complete];
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
//    NSLog(@"finish");
    [shapeBuilderView addTouchPoint:point];
    [self complete];
}

-(void) complete{
    NSArray* shapes = [shapeBuilderView completeAndGenerateShapes];
    [shapeBuilderView clear];
    for(UIBezierPath* shape in shapes){
        //        if([scraps count]){
        //            [[scraps objectAtIndex:0] intersect:shape];
        //        }else{
        UIBezierPath* shapePath = [shape copy];
        [shapePath applyTransform:CGAffineTransformMakeScale(1/self.scale, 1/self.scale)];
        [self addScrapWithPath:shapePath];
        //        }
    }
    
}

-(void) cancelShapeAtPoint:(CGPoint)point{
    // we've cancelled the polygon (possibly b/c
    // it was a pan/pinch instead), so clear
    // the drawn polygon and reset.
//    NSLog(@"cancel");
    [shapeBuilderView clear];
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

    dispatch_async([MMScrapsOnPaperState concurrentBackgroundQueue], ^(void) {
        @autoreleasepool {
            dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_wait(sema2, DISPATCH_TIME_FOREVER);
            dispatch_release(sema1);
            dispatch_release(sema2);
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

#pragma mark - MMPaperStateDelegate

/**
 * TODO: only fire off these state methods
 * if we have also loaded state for our scraps
 * https://github.com/adamwulf/loose-leaf/issues/254
 */
-(void) didLoadState:(MMPaperState*)state{
    if([self hasStateLoaded]){
        [NSThread performBlockOnMainThread:^{
            [self.delegate didLoadStateForPage:self];
        }];
    }
}

-(void) didUnloadState:(MMPaperState *)state{
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
