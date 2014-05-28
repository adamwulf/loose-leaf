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
#import "MMUntouchableView.h"
#import "NSThread+BlockAdditions.h"
#import "NSArray+Extras.h"
#import <JotUI/JotUI.h>
#import <JotUI/AbstractBezierPathElement-Protected.h>
#import "MMScrapsOnPaperState.h"
#import "MMImmutableScrapsOnPaperState.h"
#import <JotUI/UIColor+JotHelper.h>
#import <DrawKit-iOS/DrawKit-iOS.h>
#import "DKUIBezierPathClippedSegment+PathElement.h"
#import "UIBezierPath+PathElement.h"
#import "UIBezierPath+Description.h"
#import "MMVector.h"
#import "MMScrapViewState.h"
#import "MMPageCacheManager.h"
#import "Mixpanel.h"
#import "UIDevice+PPI.h"


@implementation MMScrappedPaperView{
    UIView* scrapContainerView;
    NSString* scrapIDsPath;
    MMScrapsOnPaperState* scrapState;
    UIImage* scrappedImgViewImage;
    // this defaults to NO, which means we'll try to
    // load a thumbnail. if an image does not exist
    // on disk, then we'll set this to YES which will
    // prevent any more thumbnail loads until this page
    // is saved
    BOOL definitelyDoesNotHaveAScrappedThumbnail;
    BOOL isLoadingCachedScrappedThumbnailFromDisk;
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
        // create the cache thumbnail view
        cachedImgView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        cachedImgView.frame = self.contentView.bounds;
        cachedImgView.contentMode = UIViewContentModeScaleAspectFill;
        cachedImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cachedImgView.clipsToBounds = YES;
        cachedImgView.opaque = YES;
        cachedImgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:cachedImgView];

        // Initialization code
        scrapContainerView = [[MMUntouchableView alloc] initWithFrame:self.bounds];
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

#pragma mark - Public Methods

-(void) setCanvasVisible:(BOOL)isCanvasVisible{
    [super setCanvasVisible:isCanvasVisible];
    if(isCanvasVisible){
        cachedImgView.hidden = YES;
    }else{
        cachedImgView.hidden = NO;
    }
}

#pragma mark - Protected Methods

-(void) addDrawableViewToContentView{
    // default will be to just append drawable view. subclasses
    // can (and will) change behavior
    [self.contentView insertSubview:drawableView aboveSubview:cachedImgView];
}


#pragma mark - Scraps

/**
 * the input path contains the offset
 * and size of the new scrap from its
 * bounds
 */
-(MMScrapView*) addScrapWithPath:(UIBezierPath*)path andScale:(CGFloat)scale{

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
        [path rotateAndAlignCenter:lastBestRotation];
    }

    // now add the scrap, and rotate it to counter-act
    // the rotation we added to the path itself
    return [self addScrapWithPath:path andRotation:-lastBestRotation andScale:scale];
}


/**
 * the input path contains the offset and size of the new scrap from its
 * bounds. the input scale attribute tells us what the scale should be for
 * it's given size. the scrap should exactly fit the input path, but already
 * have the input scale. this lets us create higher resolution scraps
 * at specific paths.
 *
 * so, an input scale of 2.0 will not change the visible size of the added scrap, but it
 * will have twice the resolution in both dimensions.
 */
-(MMScrapView*) addScrapWithPath:(UIBezierPath*)path andRotation:(CGFloat)lastBestRotation andScale:(CGFloat)scale{
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfScraps by:@(1)];
    //
    // at this point, we have the correct path and rotation that will
    // give us the minimal square px. For instance, drawing a thin diagonal
    // strip of paper will create a thin texture and rotate it, instead of
    // an unrotated thick rectangle.
    CGPoint pathC = path.center;
    CGAffineTransform scalePathToFullResTransform = CGAffineTransformMakeTranslation(pathC.x, pathC.y);
    scalePathToFullResTransform = CGAffineTransformScale(scalePathToFullResTransform, 1/scale, 1/scale);
    scalePathToFullResTransform = CGAffineTransformTranslate(scalePathToFullResTransform, -pathC.x, -pathC.y);
    [path applyTransform:scalePathToFullResTransform];
    
    MMScrapView* newScrap = [[MMScrapView alloc] initWithBezierPath:path];
    @synchronized(scrapContainerView){
        [scrapContainerView addSubview:newScrap];
    }
    [newScrap loadScrapStateAsynchronously:NO];
    [newScrap setShouldShowShadow:[self isEditable]];
    
    [newScrap setScale:scale];
    [newScrap setRotation:lastBestRotation];

    return newScrap;
}


-(void) addScrap:(MMScrapView*)scrap{
    @synchronized(scrapContainerView){
        [scrapContainerView addSubview:scrap];
    }
    [scrap setShouldShowShadow:[self isEditable]];
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
    @synchronized(scrapContainerView){
        return scrapContainerView.subviews;
    }
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
    [super panAndScale:_panGesture];
}

-(BOOL) isAllowedToPan{
    return [self.delegate isAllowedToPan];
}

-(BOOL) allowsHoldingScrapsWithTouch:(UITouch*)touch{
    return [self.delegate allowsHoldingScrapsWithTouch:(UITouch*)touch];
}

#pragma mark - JotViewDelegate



-(NSArray*) willAddElementsToStroke:(NSArray *)elements fromPreviousElement:(AbstractBezierPathElement*)_previousElement{
    NSArray* strokeElementsToDraw = [super willAddElementsToStroke:elements fromPreviousElement:_previousElement];
    
    
    // track distance drawn
    CGFloat strokeDistance = 0;
    for(AbstractBezierPathElement* ele in strokeElementsToDraw){
        strokeDistance += ele.lengthOfElement;
    }
    [self.delegate didDrawStrokeOfCm:strokeDistance / [UIDevice ppc]];
    
    
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
        if(!previousElement){
            previousElement = [strokesToCrop firstObject];
        }
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
                NSArray* redAndBlueSegments = nil;
                @try {
                    redAndBlueSegments = [UIBezierPath redAndGreenAndBlueSegmentsCreatedFrom:scrapClippingPath bySlicingWithPath:strokePath andNumberOfBlueShellSegments:nil];
                }@catch (id exc) {
                    //        NSAssert(NO, @"need to log this");
                    NSLog(@"need to mail the paths");
                    
                    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
                    
                    [dateFormater setDateFormat:@"yyyy-MM-DD HH:mm:ss"];
                    NSString *convertedDateString = [dateFormater stringFromDate:[NSDate date]];
                    
                    NSString* textForEmail = @"Shapes in view:\n\n";
                    textForEmail = [textForEmail stringByAppendingFormat:@"scissor:\n%@\n\n\n", strokePath];
                    textForEmail = [textForEmail stringByAppendingFormat:@"shape:\n%@\n\n\n", scrapClippingPath];
                    
                    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
                    [controller setMailComposeDelegate:self];
                    [controller setToRecipients:[NSArray arrayWithObject:@"adam.wulf@gmail.com"]];
                    [controller setSubject:[NSString stringWithFormat:@"Shape Clipping Test Case %@", convertedDateString]];
                    [controller setMessageBody:textForEmail isHTML:NO];
                    //        [controller addAttachmentData:imageData mimeType:@"image/png" fileName:@"screenshot.png"];
                    
                    if(controller){
                        UIViewController* rootController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                        [rootController presentViewController:controller animated:YES completion:nil];
                    }
                }
                
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
                    // determine the tranlsation that we need to make on the path
                    // so that it's moved into the scrap's coordinate space
                    CGAffineTransform entireTransform = [scrap pageToScrapTransformWithPageOriginalUnscaledBounds:self.originalUnscaledBounds];
                    
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
    UIBezierPath* scissorPath = [shapeBuilderView completeAndGenerateShape];
    [self completeScissorsCutWithPath:scissorPath];
}


-(void) completeScissorsCutWithPath:(UIBezierPath*)scissorPath{
    // track path information for debugging
    NSString* debugFullText = @"";

    @try {
        // scale the scissors into the zoom of the page, in case the user is
        // pinching and zooming the page our scissor path will be in page coordinates
        // instead of screen coordinates
        [scissorPath applyTransform:CGAffineTransformMakeScale(1/self.scale, 1/self.scale)];
        
        BOOL hasBuiltAnyScraps = NO;
        
        CGAffineTransform verticalFlip = CGAffineTransformMake(1, 0, 0, -1, 0, self.originalUnscaledBounds.size.height);


        // iterate over the scraps from the visibly top scraps
        // to the bottom of the stack
        for(MMScrapView* scrap in [self.scraps reverseObjectEnumerator]){
            debugFullText = @"";
            // get the clipping path of the scrap and convert it into
            // CoreGraphics coordinate system
            UIBezierPath* subshapePath = [[scrap clippingPath] copy];
            [subshapePath applyTransform:verticalFlip];
            
            //
            // this subshape path is based on the scrap's current scale, which may or
            // may not be 1.0. if it's not 1.0 scale, then the new scrap would be built
            // with the incorrect initial resolution.
            //
            // to fix this, we need to scale this path to 1.0 scale so that our new
            // scrap is built with the correct initial resolution
            
            CGFloat maxDist = 0;
            NSMutableArray* vectors = [NSMutableArray array];
            NSMutableArray* scraps = [NSMutableArray array];
            @autoreleasepool {
                // cut the shape and get all unique shapes
                NSArray* subshapes = [subshapePath uniqueShapesCreatedFromSlicingWithUnclosedPath:scissorPath];
                if([subshapes count] > 1){
                    
                    NSMutableArray* sortedArrayOfNewSubpaths = [NSMutableArray array];
                    for(DKUIBezierPathShape* shape in subshapes){
                        [sortedArrayOfNewSubpaths addObject:[shape.fullPath copy]];
                    }
                    [sortedArrayOfNewSubpaths sortUsingComparator:^(id obj1, id obj2){
                        UIBezierPath* p1 = obj1;
                        UIBezierPath* p2 = obj2;
                        CGFloat s1 = p1.bounds.size.width * p1.bounds.size.height;
                        CGFloat s2 = p2.bounds.size.width * p2.bounds.size.height;
                        return s1 > s2 ? NSOrderedAscending : NSOrderedDescending;
                    }];
                    
                    debugFullText = [debugFullText stringByAppendingFormat:@"shape:\n %@ scissor:\n %@ \n\n\n\n", subshapePath, scissorPath];
                    for(UIBezierPath* subshapePath in sortedArrayOfNewSubpaths){
                        // and add the scrap so that it's scale matches the scrap that its built from
                        MMScrapView* addedScrap = [self addScrapWithPath:subshapePath andScale:scrap.scale];
                        @synchronized(scrapContainerView){
                            [scrapContainerView insertSubview:addedScrap belowSubview:scrap];
                        }
                        [addedScrap stampContentsFrom:scrap.state.drawableView];
                        
                        CGFloat addedScrapDist = distance(scrap.center, addedScrap.center);
                        if(addedScrapDist > maxDist){
                            maxDist = addedScrapDist;
                        }
                        [vectors addObject:[MMVector vectorWithPoint:scrap.center andPoint:addedScrap.center]];
                        CGFloat orgRot = scrap.rotation;
                        CGFloat newRot = addedScrap.rotation;
                        CGFloat rotDiff = orgRot - newRot;
                        
                        CGPoint orgC = scrap.center;
                        CGPoint newC = addedScrap.center;
                        CGPoint moveC = CGPointMake(newC.x - orgC.x, newC.y - orgC.y);
                        
                        CGPoint convertedC = [addedScrap.state.contentView convertPoint:scrap.state.backingContentView.center fromView:scrap.state.contentView];
                        CGPoint refPoint = CGPointMake(addedScrap.state.contentView.bounds.size.width/2,
                                                       addedScrap.state.contentView.bounds.size.height/2);
                        CGPoint moveC2 = CGPointMake(convertedC.x - refPoint.x, convertedC.y - refPoint.y);
                        
                        // we have the correct adjustment value,
                        // but now we need to account for the fact
                        // that the new scrap has a different rotation
                        // than the start scrap
                        
                        moveC = CGPointApplyAffineTransform(moveC, CGAffineTransformMakeRotation(scrap.rotation - addedScrap.rotation));
                        
                        [addedScrap setBackingImage:scrap.backingImage];
                        [addedScrap setBackgroundRotation:scrap.backgroundRotation + rotDiff];
                        [addedScrap setBackgroundScale:scrap.backgroundScale];
                        [addedScrap setBackgroundOffset:moveC2];
                        [scraps addObject:addedScrap];
                    }
                    //
                    // TODO: handle deleting scraps, and consider the undo queue as well
                    // https://github.com/adamwulf/loose-leaf/issues/213
                    [scrap removeFromSuperview];
                    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfScraps by:@(-1)];
                }
                // clip out the portion of the scissor path that
                // intersects with the scrap we just cut
                scissorPath = [scissorPath differenceOfPathTo:subshapePath];
            }
            if([scraps count]){
                hasBuiltAnyScraps = YES;
                [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    for(int i=0;i<[vectors count];i++){
                        MMVector* vector = [vectors objectAtIndex:i];
                        vector = [vector normalizedTo:maxDist];
                        MMScrapView* scrap = [scraps objectAtIndex:i];
                        
                        CGPoint newC = [vector pointFromPoint:scrap.center distance:10];
                        scrap.center = newC;
                    }
                } completion:nil];
            }
        }
        
        if(hasBuiltAnyScraps){
            // track if they cut existing scraps
            [[[Mixpanel sharedInstance] people] increment:kMPNumberOfScissorUses by:@(1)];
        }
        if(!hasBuiltAnyScraps && [scissorPath isClosed]){
            // track if they cut new scrap from base page
            [[[Mixpanel sharedInstance] people] increment:kMPNumberOfScissorUses by:@(1)];
            NSLog(@"didn't cut any scraps, so make one");
            NSArray* subshapes = [[UIBezierPath bezierPathWithRect:drawableView.bounds] uniqueShapesCreatedFromSlicingWithUnclosedPath:scissorPath];
            if([subshapes count] >= 1){
                scissorPath = [[[subshapes firstObject] fullPath] copy];
            }
            
            MMScrapView* addedScrap = [self addScrapWithPath:scissorPath andScale:1.0];
            [addedScrap stampContentsFrom:self.drawableView];
            
            // now we need to add a stroke to the underlying page that
            // will erase the area below the new scrap
            CGPoint p1 = addedScrap.bounds.origin;
            CGPoint p2 = addedScrap.bounds.origin;
            p2.x += addedScrap.bounds.size.width;
            CGPoint p3 = addedScrap.bounds.origin;
            p3.y += addedScrap.bounds.size.height;
            CGPoint p4 = addedScrap.bounds.origin;
            p4.x += addedScrap.bounds.size.width;
            p4.y += addedScrap.bounds.size.height;
            
            p1 = [drawableView convertPoint:p1 fromView:addedScrap];
            p2 = [drawableView convertPoint:p2 fromView:addedScrap];
            p3 = [drawableView convertPoint:p3 fromView:addedScrap];
            p4 = [drawableView convertPoint:p4 fromView:addedScrap];
            
            p1 = CGPointApplyAffineTransform(p1, verticalFlip);
            p2 = CGPointApplyAffineTransform(p2, verticalFlip);
            p3 = CGPointApplyAffineTransform(p3, verticalFlip);
            p4 = CGPointApplyAffineTransform(p4, verticalFlip);
            
            // push the added scrap onto the page, and rotate it slightly into position
            CGFloat randX = (rand() % 100 - 50) / 50.0;
            CGFloat randY = (rand() % 100 - 50) / 50.0;
            CGFloat randTurn = (rand() % 10 - 5) / 5.0;
            randTurn = randTurn * M_PI / 180; // convert to radians
            MMVector* vector = [[MMVector vectorWithX:randX andY:randY] normal];
            
            [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                CGPoint newC = [vector pointFromPoint:addedScrap.center distance:10];
                addedScrap.center = newC;
                addedScrap.rotation = addedScrap.rotation + randTurn;
            } completion:nil];
            

            [scissorPath applyTransform:CGAffineTransformMakeTranslation(-scissorPath.bounds.origin.x + kScrapShadowBufferSize, -scissorPath.bounds.origin.y + kScrapShadowBufferSize)];
            [[NSThread mainThread] performBlock:^{
                [drawableView forceAddStrokeForFilledPath:scissorPath andP1:p1 andP2:p2 andP3:p3 andP4:p4 andSize:addedScrap.bounds.size];
                [self saveToDisk];
            } afterDelay:.01];
        }else{
            [self saveToDisk];
        }

        // clear the dotted line of the scissor
        [shapeBuilderView clear];
    }
    @catch (NSException *exception) {
        //
        //
        // DEBUG
        //
        // send an email with the paths that we cut
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        
        [dateFormater setDateFormat:@"yyyy-MM-DD HH:mm:ss"];
        NSString *convertedDateString = [dateFormater stringFromDate:[NSDate date]];
        
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        [controller setMailComposeDelegate:self];
        [controller setToRecipients:[NSArray arrayWithObject:@"adam.wulf@gmail.com"]];
        [controller setSubject:[NSString stringWithFormat:@"Shape Clipping Test Case %@", convertedDateString]];
        [controller setMessageBody:debugFullText isHTML:NO];
        //        [controller addAttachmentData:imageData mimeType:@"image/png" fileName:@"screenshot.png"];
        
        if(controller){
            UIViewController* rootController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
            [rootController presentViewController:controller animated:YES completion:nil];
        }
    }
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
//    NSLog(@"setting drawable %@: %d", [self uuid], (int)_drawableView);
    [super setDrawableView:_drawableView];
}

-(void) setEditable:(BOOL)isEditable{
    [super setEditable:isEditable];
    [scrapState setShouldShowShadows:isEditable];
}


-(BOOL) hasEditsToSave{
    return [super hasEditsToSave];
}



-(void) drawScrap:(MMScrapView*)scrap intoContext:(CGContextRef)context withSize:(CGSize)contextSize{
    CGContextSaveGState(context);
    
    CGPoint center = scrap.center;
    CGFloat scale = contextSize.width / self.originalUnscaledBounds.size.width;

    // calculate the center of the scrap, scaled to our smaller thumbnail context
    center = CGPointApplyAffineTransform(center, CGAffineTransformMakeScale(scale, scale));
    
    // transform into the scrap's coordinate system
    //
    // move to scrap center
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-scrap.bounds.size.width/2, -scrap.bounds.size.height/2);
    // rotate
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation(scrap.rotation));
    // scale it
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(scale * scrap.scale, scale * scrap.scale));
    // move to position
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(center.x, center.y));
    // apply transform, now we're in the scrap's coordinate system
    CGContextConcatCTM(context, transform);

    // work with the scrap's path
    UIBezierPath* path = [scrap.bezierPath copy];

    // clip to the scrap's path
    CGContextSaveGState(context);
    [path addClip];
    [[UIColor whiteColor] setFill];
    [path fill];

    // background
    //
    // draw the scrap's background, if it has an image background
    if(scrap.backingImage){
        // save our scrap's coordinate system
        CGContextSaveGState(context);
        // move to scrap center
        CGAffineTransform backingTransform = CGAffineTransformMakeTranslation(scrap.bounds.size.width / 2, scrap.bounds.size.height / 2);
        // move to background center
        backingTransform = CGAffineTransformConcat(backingTransform, CGAffineTransformMakeTranslation(scrap.backgroundOffset.x, scrap.backgroundOffset.y));
        // scale and rotate into background's coordinate space
        CGContextConcatCTM(context, backingTransform);
        // rotate and scale
        CGContextConcatCTM(context, CGAffineTransformConcat(CGAffineTransformMakeRotation(scrap.backgroundRotation),CGAffineTransformMakeScale(scrap.backgroundScale, scrap.backgroundScale)));
        // draw the image, and keep the images center at cgpointzero
        UIImage* backingImage = scrap.backingImage;
        [backingImage drawAtPoint:CGPointMake(-backingImage.size.width / 2, -backingImage.size.height/2)];
        // restore us back to the scrap's coordinate system
        CGContextRestoreGState(context);
    }
    
    // ink
    //
    // draw the scrap's strokes
    if(scrap.state.activeThumbnailImage){
        [scrap.state.activeThumbnailImage drawInRect:scrap.bounds];
    }
    
    // restore the state, no more clip
    CGContextRestoreGState(context);
    
    // stroke the scrap path
    CGContextSetLineWidth(context, 1);
    [[UIColor grayColor] setStroke];
    [path stroke];
    
    CGContextRestoreGState(context);
}

-(NSString*) scrappedThumbnailPath{
    return [[[self pagesPath] stringByAppendingPathComponent:[@"scrapped" stringByAppendingString:@".thumb"]] stringByAppendingPathExtension:@"png"];
}
-(UIImage*) scrappedImgViewImage{
    return scrappedImgViewImage;
}

-(void) updateFullPageThumbnail:(MMImmutableScrapsOnPaperState*)immutableScrapState{
    UIImage* thumb = [self cachedImgViewImage];
    CGSize thumbSize = self.originalUnscaledBounds.size;
    thumbSize.width /= 2;
    thumbSize.height /= 2;
    
    
    UIGraphicsBeginImageContextWithOptions(thumbSize, NO, 0.0);
    
    // get context
    CGContextRef context = UIGraphicsGetCurrentContext();

    [[UIColor whiteColor] setFill];
    CGContextFillRect(context, CGRectMake(0, 0, thumbSize.width, thumbSize.height));

    // drawing code comes here- look at CGContext reference
    // for available operations
    // this example draws the inputImage into the context
    [thumb drawInRect:CGRectMake(0, 0, thumbSize.width, thumbSize.height)];
    
    
    for(MMScrapView* scrap in immutableScrapState.scraps){
        [self drawScrap:scrap intoContext:context withSize:thumbSize];
    }
    
    // get a UIImage from the image context- enjoy!!!
    scrappedImgViewImage = UIGraphicsGetImageFromCurrentImageContext();
    [[NSThread mainThread] performBlock:^{
        cachedImgView.image = scrappedImgViewImage;
    }];
    
    [UIImagePNGRepresentation(scrappedImgViewImage) writeToFile:[self scrappedThumbnailPath] atomically:YES];
    definitelyDoesNotHaveAScrappedThumbnail = NO;
    
    // clean up drawing environment
    UIGraphicsEndImageContext();
    
}

-(void) saveToDisk{
    
    CheckMainThread;
    
    // track if our back ground page has saved
    dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
    // track if all of our scraps have saved
    dispatch_semaphore_t sema2 = dispatch_semaphore_create(0);

    
    __block BOOL pageHadBeenChanged = NO;
    __block BOOL scrapsHadBeenChanged = NO;
    
    // save our backing page
    [super saveToDisk:^(BOOL hadEditsToSave){
        pageHadBeenChanged = hadEditsToSave;
        dispatch_semaphore_signal(sema1);
    }];
    
    // need to keep reference to immutableScrapState so that
    // we can update the thumbnail after the save
    __block MMImmutableScrapsOnPaperState* immutableScrapState;
    dispatch_async([MMScrapsOnPaperState importExportStateQueue], ^(void) {
        @autoreleasepool {
            immutableScrapState = [scrapState immutableState];
            scrapsHadBeenChanged = [immutableScrapState saveStateToDiskBlocking];
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
            
            
//            NSLog(@"something actually had changed %d %d", pageHadBeenChanged, scrapsHadBeenChanged);
            [self updateFullPageThumbnail:immutableScrapState];
            
            [NSThread performBlockOnMainThread:^{
//                NSLog(@"notifying did save page %@", self.uuid);
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
    MMScrapsOnPaperState* strongScrapState = scrapState;
    dispatch_async([MMScrapsOnPaperState importExportStateQueue], ^(void) {
        [[strongScrapState immutableState] saveStateToDiskBlocking];
        // unloading the scrap state will also remove them
        // from their superview (us)
        [strongScrapState unload];
    });
    [[NSThread mainThread] performBlock:^{
        
    }];
}

-(BOOL) hasStateLoaded{
    return [super hasStateLoaded];
}

#pragma mark - MMScrapsOnPaperStateDelegate

-(void) didLoadScrap:(MMScrapView*)scrap{
    @synchronized(scrapContainerView){
        [scrapContainerView addSubview:scrap];
    }
}

-(void) didLoadAllScrapsFor:(MMScrapsOnPaperState*)scrapState{
    // check to see if we've also loaded
    [self didLoadState:self.paperState];
    cachedImgView.image = [self cachedImgViewImage];
}

-(void) didUnloadAllScrapsFor:(MMScrapsOnPaperState*)scrapState{
    cachedImgView.image = scrappedImgViewImage;
}

/**
 * load any scrap previews, if applicable.
 * not sure if i'll just draw these into the
 * page preview or not
 */
-(void) loadCachedPreview{
    // make sure our thumbnail is loaded
    [super loadCachedPreview];
    if(!definitelyDoesNotHaveAScrappedThumbnail && !scrappedImgViewImage && !isLoadingCachedScrappedThumbnailFromDisk){
        isLoadingCachedScrappedThumbnailFromDisk = YES;
        dispatch_async([MMEditablePaperView importThumbnailQueue], ^(void) {
            @autoreleasepool {
                scrappedImgViewImage = [UIImage imageWithContentsOfFile:[self scrappedThumbnailPath]];
                if(!scrappedImgViewImage){
                    definitelyDoesNotHaveAScrappedThumbnail = YES;
                }
                [NSThread performBlockOnMainThread:^{
                    cachedImgView.image = scrappedImgViewImage;
                    isLoadingCachedScrappedThumbnailFromDisk = NO;
                }];
            }
        });
    }
    // make sure our scraps' thumbnails are loaded
//    [scrapState loadStateAsynchronously:YES andMakeEditable:NO];
}

-(void) unloadCachedPreview{
    // free our preview memory
    [super unloadCachedPreview];
    if(scrappedImgViewImage){
        scrappedImgViewImage = nil;
        // cachedImgView.image is already set to nil in super
        [NSThread performBlockOnMainThread:^{
            cachedImgView.image = nil;
        }];
    }
    if([scrapState isStateLoaded]){
        MMScrapsOnPaperState* strongScrapState = scrapState;
        dispatch_async([MMEditablePaperView importThumbnailQueue], ^(void) {
            @autoreleasepool {
                // save if needed
                // currently this will always save to disk. in the future #338
                // we should only save if this has changed.
                [[strongScrapState immutableState] saveStateToDiskBlocking];
                // free all scraps from memory too
                [strongScrapState unload];
            }
        });
    }
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
            [[MMPageCacheManager sharedInstace] didLoadStateForPage:self];
            cachedImgView.image = scrappedImgViewImage;
        }];
    }
}

-(void) didUnloadState:(JotViewStateProxy *)state{
    [NSThread performBlockOnMainThread:^{
        [[MMPageCacheManager sharedInstace] didUnloadStateForPage:self];
    }];
}

#pragma mark - Paths

-(NSString*) scrapIDsPath{
    if(!scrapIDsPath){
        scrapIDsPath = [[[self pagesPath] stringByAppendingPathComponent:@"scrapIDs"] stringByAppendingPathExtension:@"plist"];
    }
    return scrapIDsPath;
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    UIViewController* rootController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootController dismissViewControllerAnimated:YES completion:nil];
}


@end
