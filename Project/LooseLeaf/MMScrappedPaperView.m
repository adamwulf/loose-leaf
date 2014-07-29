//
//  MMScrappedPaperView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrappedPaperView.h"
#import "MMEditablePaperView+UndoRedo.h"
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
#import "MMLoadImageCache.h"
#import "MMCachedPreviewManager.h"
#import "MMScrapSidebarContainerView.h"
#import "MMScrapsInSidebarState.h"
#import "UIView+Animations.h"


@implementation MMScrappedPaperView{
    MMScrapContainerView* scrapContainerView;
    NSString* scrapIDsPath;
    MMScrapsOnPaperState* scrapsOnPaperState;
    MMDecompressImagePromise* scrappedImgViewImage;
    // this defaults to NO, which means we'll try to
    // load a thumbnail. if an image does not exist
    // on disk, then we'll set this to YES which will
    // prevent any more thumbnail loads until this page
    // is saved
    BOOL definitelyDoesNotHaveAScrappedThumbnail;
    BOOL isLoadingCachedScrappedThumbnailFromDisk;
    // track if we should have our thumbnail loaded
    // this will help us since we use lots of threads
    // during thumbnail loading.
    BOOL isAskedToLoadThumbnail;
    // has pending icon update. this will be YES
    // during a save
    int hasPendingScrappedIconUpdate;

    dispatch_queue_t concurrentBackgroundQueue;

    
    NSInteger lastSavedPaperStateHashForGeneratedThumbnail;
    NSInteger lastSavedScrapStateHashForGeneratedThumbnail;
}

@synthesize scrapsOnPaperState;
@synthesize scrapContainerView;


-(dispatch_queue_t) concurrentBackgroundQueue{
    if(!concurrentBackgroundQueue){
        concurrentBackgroundQueue = dispatch_queue_create("com.milestonemade.looseleaf.scraps.concurrentBackgroundQueue", DISPATCH_QUEUE_SERIAL);
    }
    return concurrentBackgroundQueue;
}

- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid{
    self = [super initWithFrame:frame andUUID:_uuid];
    if (self) {
        // Initialization code
        scrapContainerView = [[MMScrapContainerView alloc] initWithFrame:self.bounds andPage:self];

        [self.contentView addSubview:scrapContainerView];
        // anchor the view to the top left,
        // so that when we scale down, the drawable view
        // stays in place
        scrapContainerView.layer.anchorPoint = CGPointMake(0,0);
        scrapContainerView.layer.position = CGPointMake(0,0);

        panGesture.scrapDelegate = self;
        rulerGesture.scrapDelegate = self;
        
        scrapsOnPaperState = [[MMScrapsOnPaperState alloc] initWithDelegate:self];
        
        [self updateThumbnailVisibility];
    }
    return self;
}

-(int) fullByteSize{
    return [super fullByteSize] + scrapsOnPaperState.fullByteSize;
}

#pragma mark - Public Methods

// https://github.com/adamwulf/loose-leaf/issues/614
//
// should show combinations of drawable view, scrap container,
// ink thumb, or scrapped thumb depending on editable state
// and what's loaded into memory
-(void) updateThumbnailVisibility{
    CheckMainThread;
    if(drawableView && drawableView.superview && (self.scale > kMinPageZoom || hasPendingScrappedIconUpdate)){
        // if we have a drawable view, and it's been added to our page
        // then we know it was it's prepped and ready to show valid ink
        if([self.paperState isStateLoaded] && [self.scrapsOnPaperState isStateLoaded]){
            // page is editable and ready for work
//            NSLog(@"page %@ is editing, so nil thumb", self.uuid);
            [self setThumbnailTo:nil];
            scrapContainerView.hidden = NO;
            drawableView.hidden = NO;
            shapeBuilderView.hidden = NO;
            cachedImgView.hidden = YES;
        }else if([self.scrapsOnPaperState isStateLoaded]){
            // scrap state is loaded, so at least
            // show that
//            NSLog(@"page %@ wants editing, has scraps, showing ink thumb", self.uuid);
            [self setThumbnailTo:[self cachedImgViewImage]];
            scrapContainerView.hidden = NO;
            drawableView.hidden = YES;
            shapeBuilderView.hidden = YES;
            cachedImgView.hidden = NO;
        }else{
            // scrap state isn't loaded, so show
            // our thumbnail
//            NSLog(@"page %@ wants editing, doens't have scraps, showing scrap thumb", self.uuid);
            [self setThumbnailTo:scrappedImgViewImage.image];
            scrapContainerView.hidden = YES;
            drawableView.hidden = YES;
            shapeBuilderView.hidden = YES;
            cachedImgView.hidden = NO;
        }
    }else if([self.scrapsOnPaperState isStateLoaded] && [self.scrapsOnPaperState hasEditsToSave]){
//        NSLog(@"page %@ isn't editing, has unsaved scraps, showing ink thumb", self.uuid);
        [self setThumbnailTo:[self cachedImgViewImage]];
        scrapContainerView.hidden = NO;
        drawableView.hidden = YES;
        shapeBuilderView.hidden = YES;
        cachedImgView.hidden = NO;
    }else if(!isAskedToLoadThumbnail){
//        NSLog(@"default thumb for %@, HIDING thumb", self.uuid);
        [self setThumbnailTo:nil];
        scrapContainerView.hidden = YES;
        drawableView.hidden = YES;
        shapeBuilderView.hidden = YES;
    }else{
//        NSLog(@"default thumb for %@, SHOWING thumb", self.uuid);
//        NSLog(@"page %@ isn't editing, scraps are saved, showing scrapped thumb", self.uuid);
        [self setThumbnailTo:scrappedImgViewImage.image];
        scrapContainerView.hidden = YES;
        drawableView.hidden = YES;
        shapeBuilderView.hidden = YES;
        cachedImgView.hidden = NO;
    }
}

-(void) undo{
    if(scrapsOnPaperState){
        for(MMScrapView* scrap in self.scrapsOnPaper){
            [scrap.state.drawableView undo];
        }
    }
    [super undo];
}

-(void) redo{
    if(scrapsOnPaperState){
        for(MMScrapView* scrap in self.scrapsOnPaper){
            [scrap.state.drawableView redo];
        }
    }
    [super redo];
}

#pragma mark - Protected Methods

-(void) addDrawableViewToContentView{
    // default will be to just append drawable view. subclasses
    // can (and will) change behavior
    [self.contentView insertSubview:drawableView belowSubview:scrapContainerView];
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
    
//    debug_NSLog(@"memory savings of: %f", (1 - lastBestSize / initialSize));
    
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
-(MMScrapView*) addScrapWithPath:(UIBezierPath*)path andRotation:(CGFloat)rotation andScale:(CGFloat)scale{
    [[[Mixpanel sharedInstance] people] increment:kMPNumberOfScraps by:@(1)];
    //
    // at this point, we have the correct path and rotation that will
    // give us the minimal square px. For instance, drawing a thin diagonal
    // strip of paper will create a thin texture and rotate it, instead of
    // an unrotated thick rectangle.
    MMScrapView* newScrap = [scrapsOnPaperState addScrapWithPath:path andRotation:rotation andScale:scale];
    [scrapsOnPaperState showScrap:newScrap];
    return newScrap;
}


/**
 * returns all subviews in back-to-front
 * order
 */
-(NSArray*) scrapsOnPaper{
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

#pragma mark - MMPanAndPinchScrapGestureRecognizerDelegate

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
    [rulerGesture ownershipOfTouches:touches isGesture:gesture];
    if([gesture isKindOfClass:[MMPanAndPinchGestureRecognizer class]]){
        // only notify of our own gestures
        [self.delegate ownershipOfTouches:touches isGesture:gesture];
    }
}

-(NSArray*) scrapsToPan{
    return self.scrapsOnPaper;
}

-(CGFloat) topVisiblePageScaleForScrap:(MMScrapView *)scrap{
    @throw kAbstractMethodException;
}

-(CGPoint) convertScrapCenterToScrapContainerCoordinate:(MMScrapView *)scrap{
    @throw kAbstractMethodException;
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

-(BOOL) isAllowedToBezel{
    return [self.delegate isAllowedToBezel];
}

-(BOOL) allowsHoldingScrapsWithTouch:(UITouch*)touch{
    return [self.delegate allowsHoldingScrapsWithTouch:(UITouch*)touch];
}

#pragma mark - JotViewDelegate

-(void) didEndStrokeWithTouch:(JotTouch *)touch{
    for(MMScrapView* scrap in [self.scrapsOnPaper reverseObjectEnumerator]){
        [scrap addUndoLevelAndFinishStroke];
        [scrap.state.drawableView clearUndoneStrokes];
    }
    [super didEndStrokeWithTouch:touch];
}

-(void) didCancelStroke:(JotStroke*)stroke withTouch:(JotTouch *)touch{
    // when a stroke ends, our drawableview has its undo-state
    // set by removing its current stroke. to match, we need to
    // end all the strokes of our scraps, and then undo them, to
    // make it as though this never happened.
    //
    // however! just undoing will add an extra stroke to the
    // strokesThatHaveBeenUndone array. so we need to make sure
    // both the undo-able and undone arrays are unchanged.
    for(MMScrapView* scrap in [self.scrapsOnPaper reverseObjectEnumerator]){
        [scrap addUndoLevelAndFinishStroke];
        [scrap.state.drawableView undoAndForget];
    }
    [super didCancelStroke:stroke withTouch:touch];
}


// adds an undo level to the drawable views and maintains
// any alive strokes
-(void) addUndoLevelAndContinueStroke{
    NSLog(@"adding undo level");
    [self.drawableView addUndoLevelAndContinueStroke];
    for(MMScrapView* scrap in [self.scrapsOnPaper reverseObjectEnumerator]){
        [scrap.state.drawableView addUndoLevelAndContinueStroke];
    }
}

-(NSArray*) willAddElementsToStroke:(NSArray *)elements fromPreviousElement:(AbstractBezierPathElement*)_previousElement{
    NSArray* strokeElementsToDraw = [super willAddElementsToStroke:elements fromPreviousElement:_previousElement];
    
    // track distance drawn
    CGFloat strokeDistance = 0;
    // track size of these added elements, so we can
    // trigger an undo level if needed
    NSInteger sizeInBytes = 0;
    for(AbstractBezierPathElement* ele in strokeElementsToDraw){
        strokeDistance += ele.lengthOfElement;
        sizeInBytes += [ele fullByteSize]; // byte size is zero since the vbo hasn't loaded yet
    }
    [self.delegate didDrawStrokeOfCm:strokeDistance / [UIDevice ppc]];
    
    
    
    // i need to check here if i should add an undo level
    // based on the stroke size.
    //
    // this used to be done automatically inside the jotview,
    // but instead i've pulled it out so that whoever owns
    // the jotview can arbitrarily add undo levels mid-stroke
    // as needed. this helps us, because we may need to add
    // undo levels to all scraps as well, not just whichever
    // drawable view happens to exceed the byte limit
    NSMutableArray* strokeElementsToCrop = [NSMutableArray arrayWithArray:strokeElementsToDraw];
    BOOL shouldAddUndoLevel = [self.drawableView maxCurrentStrokeByteSize] + sizeInBytes > kJotMaxStrokeByteSize;
    for(MMScrapView* scrap in [self.scrapsOnPaper reverseObjectEnumerator]){
        if([scrap.state.drawableView maxCurrentStrokeByteSize] + sizeInBytes > kJotMaxStrokeByteSize || shouldAddUndoLevel){
            shouldAddUndoLevel = YES;
            break;
        }
    }
    
    if(shouldAddUndoLevel){
        // if we land in here, then that means that either our
        // drawable view, or one of our scraps, would exceed the max
        // byte size for a stroke. so we should add an undo level
        // to make sure byte sizes stay smaller than our max allowed
        [self addUndoLevelAndContinueStroke];
    }
    
    // we can exit early here if we don't have any scraps on our paper
    if(![self.scrapsOnPaper count]){
        return strokeElementsToDraw;
    }
    
    
    
    for(MMScrapView* scrap in [self.scrapsOnPaper reverseObjectEnumerator]){
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
            previousElement = [strokeElementsToCrop firstObject];
        }
        for(AbstractBezierPathElement* element in strokeElementsToCrop){
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
                    debug_NSLog(@"need to mail the paths");
                    
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
        
        strokeElementsToCrop = nextStrokesToCrop;
    }
    
    // anything that's left over at this point
    // is fair game for to add to the page itself
    return strokeElementsToCrop;
}


#pragma mark - MMRotationManagerDelegate

-(void) didUpdateAccelerometerWithRawReading:(MMVector*)currentRawReading{
    for(MMScrapView* scrap in self.scrapsOnPaper){
        [scrap didUpdateAccelerometerWithRawReading:currentRawReading];
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
    @autoreleasepool {
        UIBezierPath* scissorPath = [shapeBuilderView completeAndGenerateShape];
        [self completeScissorsCutWithPath:scissorPath];
    }
}


-(MMScissorResult*) completeScissorsCutWithPath:(UIBezierPath*)scissorPath{
    // track path information for debugging
    NSString* debugFullText = @"";

    NSMutableArray* scrapsBeingBuilt = [NSMutableArray array];
    NSMutableArray* scrapsBeingRemoved = [NSMutableArray array];
    NSMutableArray* removedScrapProperties = [NSMutableArray array];
    BOOL didFill = NO;
    
    @try {
        // scale the scissors into the zoom of the page, in case the user is
        // pinching and zooming the page our scissor path will be in page coordinates
        // instead of screen coordinates
        [scissorPath applyTransform:CGAffineTransformMakeScale(1/self.scale, 1/self.scale)];
        
        BOOL hasBuiltAnyScraps = NO;
        
        CGAffineTransform verticalFlip = CGAffineTransformMake(1, 0, 0, -1, 0, self.originalUnscaledBounds.size.height);

        // iterate over the scraps from the visibly top scraps
        // to the bottom of the stack
        for(MMScrapView* scrap in [self.scrapsOnPaper reverseObjectEnumerator]){
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
                        UIBezierPath* shapePath = [shape.fullPath copy];
                        [sortedArrayOfNewSubpaths addObject:shapePath];
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
                        if([subshapePath containsDuplicateAndReversedSubpaths]){
                            @throw [NSException exceptionWithName:@"DuplicateSubshape" reason:@"shape contains duplicate subshapes" userInfo:nil];
                        }
                        // and add the scrap so that it's scale matches the scrap that its built from
                        MMScrapView* addedScrap = [self addScrapWithPath:subshapePath andScale:scrap.scale];
                        @synchronized(scrapContainerView){
                            [scrapContainerView insertSubview:addedScrap aboveSubview:scrap];
                        }
                        
                        // stamp the background
                        if(scrap.backgroundView.backingImage){
                            [addedScrap setBackgroundView:[scrap.backgroundView stampBackgroundFor:addedScrap.state]];
                        }
                        
                        // stamp the contents
                        [addedScrap stampContentsFrom:scrap.state.drawableView];
                        
                        // calculate vectors for pushing scraps apart
                        CGFloat addedScrapDist = distance(scrap.center, addedScrap.center);
                        if(addedScrapDist > maxDist){
                            maxDist = addedScrapDist;
                        }
                        [vectors addObject:[MMVector vectorWithPoint:scrap.center andPoint:addedScrap.center]];
                        
                        [scraps addObject:addedScrap];
                        [scrapsBeingBuilt addObject:addedScrap];
                    }

                    [removedScrapProperties addObject:[scrap propertiesDictionary]];
                    [scrap removeFromSuperview];
                    [scrapsBeingRemoved addObject:scrap];
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
            debug_NSLog(@"didn't cut any scraps, so make one");
            NSArray* subshapes = [[UIBezierPath bezierPathWithRect:drawableView.bounds] uniqueShapesCreatedFromSlicingWithUnclosedPath:scissorPath];
            if([subshapes count] >= 1){
                scissorPath = [[[subshapes firstObject] fullPath] copy];
            }
            
            MMScrapView* addedScrap = [self addScrapWithPath:scissorPath andScale:1.0];
            [addedScrap stampContentsFrom:self.drawableView];
            
            [scrapsBeingBuilt addObject:addedScrap];
            
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
            didFill = YES;
            [[NSThread mainThread] performBlock:^{
                [drawableView forceAddStrokeForFilledPath:scissorPath andP1:p1 andP2:p2 andP3:p3 andP4:p4 andSize:addedScrap.bounds.size];
                for(MMScrapView* scrap in [self.scrapsOnPaper reverseObjectEnumerator]){
                    [scrap.state.drawableView forceAddEmptyStroke];
                }
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
    
    return [[MMScissorResult alloc] initWithAddedScraps:scrapsBeingBuilt
                                       andRemovedScraps:scrapsBeingRemoved
                              andRemovedScrapProperties:removedScrapProperties
                                       andDidFillStroke:didFill];
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
    [scrapsOnPaperState setShouldShowShadows:isEditable];
}

-(BOOL) hasEditsToSave{
    return [super hasEditsToSave] || [scrapsOnPaperState hasEditsToSave];
}

-(BOOL) hasPenOrScrapEditsToSave{
    return [super hasEditsToSave] || [scrapsOnPaperState hasEditsToSave];
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
    if(scrap.backgroundView.backingImage){
        // save our scrap's coordinate system
        CGContextSaveGState(context);
        // move to scrap center
        CGAffineTransform backingTransform = CGAffineTransformMakeTranslation(scrap.bounds.size.width / 2, scrap.bounds.size.height / 2);
        // move to background center
        backingTransform = CGAffineTransformConcat(backingTransform, CGAffineTransformMakeTranslation(scrap.backgroundView.backgroundOffset.x, scrap.backgroundView.backgroundOffset.y));
        // scale and rotate into background's coordinate space
        CGContextConcatCTM(context, backingTransform);
        // rotate and scale
        CGContextConcatCTM(context, CGAffineTransformConcat(CGAffineTransformMakeRotation(scrap.backgroundView.backgroundRotation),CGAffineTransformMakeScale(scrap.backgroundView.backgroundScale, scrap.backgroundView.backgroundScale)));
        // draw the image, and keep the images center at cgpointzero
        UIImage* backingImage = scrap.backgroundView.backingImage;
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

-(UIImage*) scrappedImgViewImage{
    return [scrappedImgViewImage image];
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
    UIImage* generatedScrappedThumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    scrappedImgViewImage = [[MMDecompressImagePromise alloc] initForDecompressedImage:generatedScrappedThumbnailImage andDelegate:self];
    [[MMLoadImageCache sharedInstance] updateCacheForPath:[self scrappedThumbnailPath] toImage:scrappedImgViewImage.image];
    [[NSThread mainThread] performBlock:^{
        [self didDecompressImage:scrappedImgViewImage];
    }];
    
    [UIImagePNGRepresentation(scrappedImgViewImage.image) writeToFile:[self scrappedThumbnailPath] atomically:YES];
    definitelyDoesNotHaveAScrappedThumbnail = NO;
    
    // clean up drawing environment
    UIGraphicsEndImageContext();
}

-(void) setThumbnailTo:(UIImage*)img{
    CheckMainThread;
    @autoreleasepool {
        // create the cache thumbnail view
        if(!cachedImgView && img){
            cachedImgView = [[MMCachedPreviewManager sharedInstace] requestCachedImageViewForView:self];
            cachedImgView.image = img;
            if(drawableView){
                [self.contentView insertSubview:cachedImgView belowSubview:drawableView];
            }else{
                [self.contentView insertSubview:cachedImgView belowSubview:scrapContainerView];
            }
        }else if(cachedImgView && !img){
            // giving the cachedImgView back to the cache will automatically
            // remove it from the superview
            [[MMCachedPreviewManager sharedInstace] giveBackCachedImageView:cachedImgView];
            cachedImgView = nil;
        }else if(img){
            cachedImgView.image = img;
        }
    }
}

-(void) saveToDisk{
    [self saveToDisk:nil];
}

-(void) saveToDisk:(void (^)(BOOL))onComplete{
    debug_NSLog(@"asking %@ to save to disk at %lu", self.uuid, (unsigned long)self.drawableView.undoHash);
    //
    // for now, I will always save the entire page to disk.
    // the JotView will optimize its part away, but the
    // scrap state is currently always re-saving, and the
    // thumbnail will always be re-generated.
    //
    // TODO: https://github.com/adamwulf/loose-leaf/issues/531
    
    CheckMainThread;
    
    // track if our back ground page has saved
    dispatch_semaphore_t sema1 = dispatch_semaphore_create(0);
    // track if all of our scraps have saved
    dispatch_semaphore_t sema2 = dispatch_semaphore_create(0);

    [self updateThumbnailVisibility];
    
    __block NSInteger lastSavedPaperStateHash = 0;
    __block NSInteger lastSavedScrapStateHash = 0;
    
    @synchronized(self){
        hasPendingScrappedIconUpdate++;
//        NSLog(@"starting save! %d", hasPendingScrappedIconUpdate);
    }
    
    __block BOOL pageHadBeenChanged = NO;
    __block BOOL scrapsHadBeenChanged = NO;
    
    // save our backing page
    [super saveToDisk:^(BOOL hadEditsToSave){
        lastSavedPaperStateHash = paperState.lastSavedUndoHash;
        pageHadBeenChanged = hadEditsToSave;
        dispatch_semaphore_signal(sema1);
    }];
    
    // need to keep reference to immutableScrapState so that
    // we can update the thumbnail after the save
    __block MMImmutableScrapsOnPaperState* immutableScrapState;
    dispatch_async([MMScrapsOnPaperState importExportStateQueue], ^(void) {
        @autoreleasepool {
            immutableScrapState = [scrapsOnPaperState immutableStateForPath:self.scrapIDsPath];
            scrapsHadBeenChanged = [immutableScrapState saveStateToDiskBlocking];
            lastSavedScrapStateHash = immutableScrapState.undoHash;
//            NSLog(@"scrapsHadBeenChanged %d %lu",scrapsHadBeenChanged, (unsigned long)immutableScrapState.undoHash);
            dispatch_semaphore_signal(sema2);
        }
    });

    dispatch_async([self concurrentBackgroundQueue], ^(void) {
        @autoreleasepool {
            dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_wait(sema2, DISPATCH_TIME_FOREVER);
//            dispatch_release(sema1); ARC handles these
//            dispatch_release(sema2);
            if([self hasEditsToSave] && ![self hasPenOrScrapEditsToSave]){
//                NSLog(@"gotcha!!");
            }
            @synchronized(self){
//                NSLog(@"ending save pre icon at %lu", (unsigned long)immutableScrapState.undoHash);
                hasPendingScrappedIconUpdate--;
            }
            BOOL needsThumbnailUpdateSinceLastSave = NO;
            if(lastSavedPaperStateHash != lastSavedPaperStateHashForGeneratedThumbnail ||
               lastSavedScrapStateHash != lastSavedScrapStateHashForGeneratedThumbnail){
                needsThumbnailUpdateSinceLastSave = YES;
//                NSLog(@"needs thumbnail update since last generation");
            }else{
//                NSLog(@"doesn't need thumbnail update since last generation");
            }
            
            if([self hasPenOrScrapEditsToSave]){
//                NSLog(@"i have more edits to save for %@ (now %lu). bailing. %d %d",self.uuid, (unsigned long) immutableScrapState.undoHash, pageHadBeenChanged, scrapsHadBeenChanged);
                // our save failed. this may happen if we
                // call [saveToDisk] in very quick succession
                // so that the 1st call is still saving, and the
                // 2nd ends early b/c it knows the 1st is still going
//                NSLog(@"saved %@ but still have edits to save: saved at %lu but is now %lu",self.uuid, (unsigned long)immutableScrapState.undoHash,
//                      (unsigned long)[self.scrapsOnPaperState immutableStateForPath:nil].undoHash);
//                NSLog(@"needs save at %lu: %d %d", (unsigned long)[self.scrapsOnPaperState immutableStateForPath:nil].undoHash, [super hasEditsToSave], [scrapsOnPaperState hasEditsToSave]);
                if(onComplete) onComplete(NO);
                return;
            }else{
//                NSLog(@"finished save for %@ %d %d %d (at %lu)", self.uuid, pageHadBeenChanged, scrapsHadBeenChanged, needsThumbnailUpdateSinceLastSave, (unsigned long) immutableScrapState.undoHash);
            }
            
            if(!hasPendingScrappedIconUpdate && (needsThumbnailUpdateSinceLastSave || pageHadBeenChanged || scrapsHadBeenChanged)){
                // only save a new thumbnail when we're the last pending save.
                // otherwise the next pending save will generate it
//                NSLog(@"generating thumbnail (at %lu) with %d saves in progress", (unsigned long) immutableScrapState.undoHash, hasPendingScrappedIconUpdate);
                lastSavedPaperStateHashForGeneratedThumbnail = lastSavedPaperStateHash;
                lastSavedScrapStateHashForGeneratedThumbnail = lastSavedScrapStateHash;
                [self updateFullPageThumbnail:immutableScrapState];
//                NSLog(@"done generating thumbnail (at %lu) with %d saves in progress", (unsigned long) immutableScrapState.undoHash, hasPendingScrappedIconUpdate);
            }else if(hasPendingScrappedIconUpdate){
//                NSLog(@"skipped generating thumbnail (at %lu) because of %d pending saves", (unsigned long) immutableScrapState.undoHash, hasPendingScrappedIconUpdate);
            }else{
//                NSLog(@"skipped generating thumbnail (at %lu) because page and scraps hadn't changed", (unsigned long) immutableScrapState.undoHash);
            }

            [NSThread performBlockOnMainThread:^{
//                NSLog(@"done saving page (at %lu)", (unsigned long) immutableScrapState.undoHash);
                // reset canvas visibility
                [self updateThumbnailVisibility];
                [self.delegate didSavePage:self];
                if(onComplete) onComplete(YES);
            }];
        }
    });
}

-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize)pagePixelSize andContext:(JotGLContext*)context{
    debug_NSLog(@"asking %@ to load state", self.uuid);
    [super loadStateAsynchronously:async withSize:pagePixelSize andContext:context];
    if([[NSFileManager defaultManager] fileExistsAtPath:self.scrapIDsPath]){
        [scrapsOnPaperState loadStateAsynchronously:async atPath:self.scrapIDsPath andMakeEditable:YES];
    }else{
        [scrapsOnPaperState loadStateAsynchronously:async atPath:self.bundledScrapIDsPath andMakeEditable:YES];
    }
}

-(void) unloadState{
    debug_NSLog(@"asking %@ to unload", self.uuid);
    [super unloadState];
    MMScrapsOnPaperState* strongScrapState = scrapsOnPaperState;
    dispatch_async([MMScrapsOnPaperState importExportStateQueue], ^(void) {
        @autoreleasepool {
            [[strongScrapState immutableStateForPath:self.scrapIDsPath] saveStateToDiskBlocking];
            // unloading the scrap state will also remove them
            // from their superview (us)
            [strongScrapState unload];
        }
    });
}

// this method will load the scrapsOnPaperState, run
// the input block that requires the loaded state,
// and then will save and unload the scrapsOnPaper state
//
// this allows us to drop scraps onto pages that don't
// have their scrapsOnPaperState loaded
-(void) performBlockForUnloadedScrapStateSynchronously:(void(^)())block{
    if([scrapsOnPaperState isStateLoaded]){
        @throw [NSException exceptionWithName:@"LoadedStateForUnloadedBlockException" reason:@"Cannot run block on unloaded state when state is already loaded" userInfo:nil];
    }
    if([[NSFileManager defaultManager] fileExistsAtPath:self.scrapIDsPath]){
        [scrapsOnPaperState loadStateAsynchronously:NO atPath:self.scrapIDsPath andMakeEditable:YES];
    }else{
        [scrapsOnPaperState loadStateAsynchronously:NO atPath:self.bundledScrapIDsPath andMakeEditable:YES];
    }
    block();
    dispatch_async([MMScrapsOnPaperState importExportStateQueue], ^(void) {
        @autoreleasepool {
            MMImmutableScrapsOnPaperState* immutableScrapState = [scrapsOnPaperState immutableStateForPath:self.scrapIDsPath];
            [immutableScrapState saveStateToDiskBlocking];
            [self updateFullPageThumbnail:immutableScrapState];
            [scrapsOnPaperState unload];
        }
    });
}

-(BOOL) hasStateLoaded{
    return [super hasStateLoaded];
}

#pragma mark - MMScrapsOnPaperStateDelegate

-(MMScrappedPaperView*) page{
    return self;
}

-(void) didLoadScrapOnPage:(MMScrapView*)scrap{
    // noop, adding scrap to scrapContainerView is handled in the scrapOnPaperState
}

-(void) didLoadScrapOffPage:(MMScrapView*)scrap{
    // noop, scrap in the undo/redo stack only
}

-(void) didLoadAllScrapsFor:(MMScrapsOnPaperState*)scrapState{
    // check to see if we've also loaded
    lastSavedScrapStateHashForGeneratedThumbnail = [scrapState lastSavedUndoHash];
    [self didLoadState:self.paperState];
    [self updateThumbnailVisibility];
}

-(void) didUnloadAllScrapsFor:(MMScrapsOnPaperState*)scrapState{
    lastSavedScrapStateHashForGeneratedThumbnail = 0;
    [self updateThumbnailVisibility];
}

/**
 * load any scrap previews, if applicable.
 * not sure if i'll just draw these into the
 * page preview or not
 */
-(void) loadCachedPreview{
    @autoreleasepool {
        @synchronized(self){
            isAskedToLoadThumbnail = YES;
        }
        // make sure our thumbnail is loaded
        [super loadCachedPreview];
        if(!definitelyDoesNotHaveAScrappedThumbnail && !scrappedImgViewImage && !isLoadingCachedScrappedThumbnailFromDisk){
            isLoadingCachedScrappedThumbnailFromDisk = YES;
            dispatch_async([MMEditablePaperView importThumbnailQueue], ^(void) {
                @autoreleasepool {
                    BOOL shouldLoad = YES;
                    @synchronized(self){
                        if(!isAskedToLoadThumbnail){
                            shouldLoad = NO;
                        }
                    }
                    if(shouldLoad){
                        if([[NSFileManager defaultManager] fileExistsAtPath:[self scrappedThumbnailPath]]){
                            scrappedImgViewImage = [[MMDecompressImagePromise alloc] initForImage:[[MMLoadImageCache sharedInstance] imageAtPath:[self scrappedThumbnailPath]]
                                                                                      andDelegate:self];
                        }else{
                            scrappedImgViewImage = [[MMDecompressImagePromise alloc] initForImage:[[MMLoadImageCache sharedInstance] imageAtPath:[self bundledScrappedThumbnailPath]]
                                                                                      andDelegate:self];
                        }
                        if(!scrappedImgViewImage.image){
                            definitelyDoesNotHaveAScrappedThumbnail = YES;
                        }
                    }
                    isLoadingCachedScrappedThumbnailFromDisk = NO;
                }
            });
        }
    }
    // make sure our scraps' thumbnails are loaded
//    [scrapState loadStateAsynchronously:YES andMakeEditable:NO];
}

-(void) didDecompressImage:(MMDecompressImagePromise*)promise{
    [self updateThumbnailVisibility];
}

-(void) unloadCachedPreview{
    @autoreleasepool {
        if(self == [[MMPageCacheManager sharedInstance] currentEditablePage]){
            NSLog(@"what");
        }
        @synchronized(self){
            isAskedToLoadThumbnail = NO;
        }
        // free our preview memory
        [super unloadCachedPreview];
        @synchronized(self){
            if(scrappedImgViewImage){
                [scrappedImgViewImage cancel];
                scrappedImgViewImage = nil;
                // cachedImgView.image is already set to nil in super
            }
        }
        [NSThread performBlockOnMainThread:^{
            [self didDecompressImage:nil];
        }];
        if([scrapsOnPaperState isStateLoaded]){
            MMScrapsOnPaperState* strongScrapState = scrapsOnPaperState;
            dispatch_async([MMEditablePaperView importThumbnailQueue], ^(void) {
                @autoreleasepool {
                    // save if needed
                    // currently this will always save to disk. in the future #338
                    // we should only save if this has changed.
                    [[strongScrapState immutableStateForPath:self.scrapIDsPath] saveStateToDiskBlocking];
                    // free all scraps from memory too
                    [strongScrapState unload];
                }
            });
        }
    }
}

-(MMScrapView*) scrapForUUIDIfAlreadyExists:(NSString*)scrapUUID{
    // try to load a scrap from the bezel sidebar if possible,
    // otherwise our scrap state will load it
    return [delegate.bezelContainerView.scrapState scrapForUUID:scrapUUID];
}

#pragma mark - JotViewStateProxyDelegate

/**
 * TODO: only fire off these state methods
 * if we have also loaded state for our scraps
 * https://github.com/adamwulf/loose-leaf/issues/254
 */
-(void) didLoadState:(JotViewStateProxy*)state{
    if([self hasStateLoaded]){
        lastSavedPaperStateHashForGeneratedThumbnail = [state undoHash];
        [NSThread performBlockOnMainThread:^{
            [[MMPageCacheManager sharedInstance] didLoadStateForPage:self];
            if(scrappedImgViewImage.isDecompressed){
                [self didDecompressImage:scrappedImgViewImage];
            }
        }];
    }
}

-(void) didUnloadState:(JotViewStateProxy *)state{
    lastSavedPaperStateHashForGeneratedThumbnail = 0;
    [NSThread performBlockOnMainThread:^{
        [[MMPageCacheManager sharedInstance] didUnloadStateForPage:self];
    }];
}

#pragma mark - Paths

-(NSString*) scrappedThumbnailPath{
    return [[[self pagesPath] stringByAppendingPathComponent:[@"scrapped" stringByAppendingString:@".thumb"]] stringByAppendingPathExtension:@"png"];
}

-(NSString*) bundledScrappedThumbnailPath{
    return [[[self bundledPagesPath] stringByAppendingPathComponent:[@"scrapped" stringByAppendingString:@".thumb"]] stringByAppendingPathExtension:@"png"];
}

-(NSString*) scrapIDsPath{
    if(!scrapIDsPath){
        scrapIDsPath = [[[self pagesPath] stringByAppendingPathComponent:@"scrapIDs"] stringByAppendingPathExtension:@"plist"];
    }
    return scrapIDsPath;
}
-(NSString*) bundledScrapIDsPath{
    return [[[self bundledPagesPath] stringByAppendingPathComponent:@"scrapIDs"] stringByAppendingPathExtension:@"plist"];
}


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    UIViewController* rootController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootController dismissViewControllerAnimated:YES completion:nil];
}

@end
