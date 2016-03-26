//
//  MMScrappedPaperView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrappedPaperView.h"
#import "MMEditablePaperViewSubclass.h"
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
#import <PerformanceBezier/PerformanceBezier.h>
#import "DKUIBezierPathClippedSegment+PathElement.h"
#import "UIBezierPath+PathElement.h"
#import "MMVector.h"
#import "MMScrapViewState.h"
#import "MMPageCacheManager.h"
#import "Mixpanel.h"
#import "UIDevice+PPI.h"
#import "MMLoadImageCache.h"
#import "MMCachedPreviewManager.h"
#import "MMScrapsInBezelContainerView.h"
#import "MMScrapsInSidebarState.h"
#import "UIView+Animations.h"
#import "MMStatTracker.h"
#import "MMTrashManager.h"


@interface MMEditablePaperView (Private)

-(UIImage*) synchronouslyLoadInkPreview;

@end

@implementation MMScrappedPaperView{
    NSString* scrapIDsPath;
    MMDecompressImagePromise* scrappedImgViewImage;
    // track if we should have our thumbnail loaded
    // this will help us since we use lots of threads
    // during thumbnail loading.
    BOOL isAskedToLoadThumbnail;
    // has pending icon update. this will be YES
    // during a save
    int hasPendingScrappedIconUpdate;

    dispatch_queue_t serialBackgroundQueue;

    NSUInteger lastSavedPaperStateHashForGeneratedThumbnail;
    NSUInteger lastSavedScrapStateHashForGeneratedThumbnail;
    
    const void * kSerialQueueIdentifier;
    
}

@synthesize scrapsOnPaperState;
@synthesize cachedImgView;
@dynamic delegate;


-(dispatch_queue_t) serialBackgroundQueue{
    if(!serialBackgroundQueue){
        serialBackgroundQueue = dispatch_queue_create("com.milestonemade.looseleaf.scraps.serialBackgroundQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(serialBackgroundQueue, kSerialQueueIdentifier, (void *)kSerialQueueIdentifier, NULL);
    }
    return serialBackgroundQueue;
}
-(BOOL) isSerialBackgroundQueue{
    return dispatch_get_specific(kSerialQueueIdentifier) != NULL;
}

- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid{
    self = [super initWithFrame:frame andUUID:_uuid];
    if (self) {
        kSerialQueueIdentifier = &kSerialQueueIdentifier;
        // Initialization code
        scrapsOnPaperState = [[MMScrapsOnPaperState alloc] initWithDelegate:self withScrapContainerSize:self.bounds.size];
        
        [self.contentView addSubview:scrapsOnPaperState.scrapContainerView];

        panGesture.scrapDelegate = self;
        rulerGesture.scrapDelegate = self;
        
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
-(void) updateThumbnailVisibility:(BOOL)forceUpdateIconImage{
    CheckMainThread;
    if(drawableView && drawableView.superview && (self.scale > kMinPageZoom || hasPendingScrappedIconUpdate)){
        // if we have a drawable view, and it's been added to our page
        // then we know it was it's prepped and ready to show valid ink
        if([self.paperState isStateLoaded] && [self.scrapsOnPaperState isStateLoaded]){
            // page is editable and ready for work
//            DebugLog(@"page %@ is editing, so nil thumb", self.uuid);
            [self setThumbnailTo:nil];
            scrapsOnPaperState.scrapContainerView.hidden = NO;
            drawableView.hidden = NO;
            shapeBuilderView.hidden = NO;
            cachedImgView.hidden = YES;
            [self isShowingDrawableView:YES andIsShowingThumbnail:NO];
        }else if([self.scrapsOnPaperState isStateLoaded]){
            // scrap state is loaded, so at least
            // show that
//            DebugLog(@"page %@ wants editing, has scraps, showing ink thumb", self.uuid);
            [self setThumbnailTo:[self cachedImgViewImage]];
            scrapsOnPaperState.scrapContainerView.hidden = NO;
            drawableView.hidden = YES;
            shapeBuilderView.hidden = YES;
            cachedImgView.hidden = NO;
            [self isShowingDrawableView:NO andIsShowingThumbnail:YES];
        }else{
            // scrap state isn't loaded, so show
            // our thumbnail
//            DebugLog(@"page %@ wants editing, doens't have scraps, showing scrap thumb", self.uuid);
            [self setThumbnailTo:scrappedImgViewImage.image];
            scrapsOnPaperState.scrapContainerView.hidden = YES;
            drawableView.hidden = YES;
            shapeBuilderView.hidden = YES;
            cachedImgView.hidden = NO;
            [self isShowingDrawableView:NO andIsShowingThumbnail:YES];
        }
    }else if([self.scrapsOnPaperState isStateLoaded] && [self.scrapsOnPaperState hasEditsToSave]){
//        DebugLog(@"page %@ isn't editing, has unsaved scraps, showing ink thumb", self.uuid);
        [self setThumbnailTo:[self cachedImgViewImage]];
        scrapsOnPaperState.scrapContainerView.hidden = NO;
        drawableView.hidden = YES;
        shapeBuilderView.hidden = YES;
        cachedImgView.hidden = NO;
        [self isShowingDrawableView:NO andIsShowingThumbnail:YES];
    }else if(!isAskedToLoadThumbnail){
//        DebugLog(@"default thumb for %@, HIDING thumb", self.uuid);
        [self setThumbnailTo:nil];
        scrapsOnPaperState.scrapContainerView.hidden = YES;
        drawableView.hidden = YES;
        shapeBuilderView.hidden = YES;
        [self isShowingDrawableView:NO andIsShowingThumbnail:NO];
    }else{
//        DebugLog(@"default thumb for %@, SHOWING thumb", self.uuid);
//        DebugLog(@"page %@ isn't editing, scraps are saved, showing scrapped thumb", self.uuid);
        [self setThumbnailTo:scrappedImgViewImage.image];
        scrapsOnPaperState.scrapContainerView.hidden = YES;
        drawableView.hidden = YES;
        shapeBuilderView.hidden = YES;
        cachedImgView.hidden = NO;
        [self isShowingDrawableView:NO andIsShowingThumbnail:YES];
    }
}

#pragma mark - Thumbnail helpers

-(void) isShowingDrawableView:(BOOL)showDrawableView andIsShowingThumbnail:(BOOL)showThumbnail{
    // noop
}

#pragma mark - Undo Redo

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
    CheckMainThread;
    // default will be to just append drawable view. subclasses
    // can (and will) change behavior
    [self.contentView insertSubview:drawableView belowSubview:scrapsOnPaperState.scrapContainerView];
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
    CGRect lastBestBounds = pathBounds;
    
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
            lastBestBounds = rotatedPathBounds;
        }
    }
    
    if(lastBestBounds.size.width > lastBestBounds.size.height){
        // scraps will always use textures the size of the portrait
        // screen when they export, so we need to ensure that
        // the scrap is always taller than it is wide. otherwise,
        // the scrap's width might be wider than our screen texture
        lastBestRotation -= M_PI / 2;
    }
    
//    DebugLog(@"memory savings of: %f", (1 - lastBestSize / initialSize));
    
    if(lastBestRotation){
        [path rotateAndAlignCenter:lastBestRotation];
    }
    
    CGFloat maxScrapHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat scaleUpForScrap = scale;
    if(path.bounds.size.height > maxScrapHeight){
        CGFloat scaleDownForPath = maxScrapHeight / path.bounds.size.height;
        scaleUpForScrap = 1 / scaleDownForPath;
        [path scaleAndPreserveCenter:scaleDownForPath];

        // if the user cuts a very long scrap diagonally on the page, then
        // it's 1.0 scale size will be taller than the screen-sized texture
        // that we'll use when exporting. so we're going to create a smaller
        // scrap that would fit within that area, and then scale it up to
        // fit back where the user actually cut it.
//        DebugLog(@"scale scrap to %f fit in %f maxdim texture",scaleUpForScrap, maxScrapHeight);
    }

    // now add the scrap, and rotate it to counter-act
    // the rotation we added to the path itself
    MMScrapView* addedScrap = [self addScrapWithPath:path andRotation:-lastBestRotation andScale:scale];
    if(scaleUpForScrap != 1.0){
        [addedScrap setScale:scaleUpForScrap];
    }
    return addedScrap;
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
    return scrapsOnPaperState.scrapsOnPaper;
}

#pragma mark - Pinch and Zoom

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    scrapsOnPaperState.scrapContainerView.transform = CGAffineTransformMakeScale(self.scale, self.scale);
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
//    DebugLog(@"adding undo level");
    [self.drawableView addUndoLevelAndContinueStroke];
    for(MMScrapView* scrap in [self.scrapsOnPaper reverseObjectEnumerator]){
        [scrap.state.drawableView addUndoLevelAndContinueStroke];
    }
}

-(NSArray*) willAddElements:(NSArray *)elements toStroke:(JotStroke *)stroke fromPreviousElement:(AbstractBezierPathElement*)_previousElement{
    NSArray* strokeElementsToDraw = [super willAddElements:elements toStroke:stroke fromPreviousElement:_previousElement];
    
    // track the segment test/reset count
    // when splitting the stroke
    [UIBezierPath resetSegmentTestCount];
    [UIBezierPath resetSegmentCompareCount];
    
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
        DebugLog(@"should add undo level!");
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
                    DebugLog(@"need to mail the paths");

                    //
                    // TODO: https://github.com/adamwulf/loose-leaf/issues/664
//                    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
//                    
//                    [dateFormater setDateFormat:@"yyyy-MM-DD HH:mm:ss"];
//                    NSString *convertedDateString = [dateFormater stringFromDate:[NSDate date]];
//                    
//                    NSString* textForEmail = @"Shapes in view:\n\n";
//                    textForEmail = [textForEmail stringByAppendingFormat:@"scissor:\n%@\n\n\n", strokePath];
//                    textForEmail = [textForEmail stringByAppendingFormat:@"shape:\n%@\n\n\n", scrapClippingPath];
//                    
//                    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
//                    [controller setMailComposeDelegate:self];
//                    [controller setToRecipients:[NSArray arrayWithObject:@"adam.wulf@gmail.com"]];
//                    [controller setSubject:[NSString stringWithFormat:@"Shape Clipping Test Case %@", convertedDateString]];
//                    [controller setMessageBody:textForEmail isHTML:NO];
//                    //        [controller addAttachmentData:imageData mimeType:@"image/png" fileName:@"screenshot.png"];
//                    
//                    if(controller){
//                        UIViewController* rootController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
//                        [rootController presentViewController:controller animated:YES completion:nil];
//                    }
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
                                                                                               toWidth:element.width
                                                                                          andStepWidth:element.stepWidth
                                                                                           andRotation:element.rotation]];
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
                                                                                                 andScale:scrap.scale
                                                                                             andStepWidth:element.stepWidth
                                                                                              andRotation:element.rotation]];
                    }
                }
                if([elementsToAddToScrap count]){
                    [scrap addElements:elementsToAddToScrap withTexture:stroke.texture];
                }
            }else{
                [nextStrokesToCrop addObject:element];
            }
            
            previousElement = element;
        }
        
        strokeElementsToCrop = nextStrokesToCrop;
    }
    
    
    if([UIBezierPath segmentTestCount] || [UIBezierPath segmentCompareCount]){
//        DebugLog(@"segment counts: %d %d", (int)[UIBezierPath segmentTestCount], (int)[UIBezierPath segmentCompareCount]);
        [[MMStatTracker trackerWithName:kMPStatSegmentTestCount andTargetCount:100] trackValue:[UIBezierPath segmentTestCount]];
        [[MMStatTracker trackerWithName:kMPStatSegmentCompareCount andTargetCount:100] trackValue:[UIBezierPath segmentCompareCount]];
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
    if(shapeBuilderView){
        [shapeBuilderView clear];
//        DebugLog(@"cancelling scissors");
    }
}

-(void) completeScissorsCut{
    @autoreleasepool {
        UIBezierPath* scissorPath = [shapeBuilderView completeAndGenerateShape];
        [self completeScissorsCutWithPath:scissorPath];
    }
}


-(MMScissorResult*) completeScissorsCutWithPath:(UIBezierPath*)scissorPath{
    // track the segment test/compare count
    // when splitting scraps with scissors
    [UIBezierPath resetSegmentCompareCount];
    [UIBezierPath resetSegmentTestCount];
    
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


        CGFloat maxDist = 0;
        NSMutableArray* vectorsForAnimation = [NSMutableArray array];
        NSMutableArray* scrapsToAnimate = [NSMutableArray array];

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
                        return s1 < s2 ? NSOrderedAscending : NSOrderedDescending;
                    }];
                    
                    debugFullText = [debugFullText stringByAppendingFormat:@"shape:\n %@ scissor:\n %@ \n\n\n\n", subshapePath, scissorPath];
                    for(UIBezierPath* subshapePath in sortedArrayOfNewSubpaths){
                        if([subshapePath containsDuplicateAndReversedSubpaths]){
                            @throw [NSException exceptionWithName:@"DuplicateSubshape" reason:@"shape contains duplicate subshapes" userInfo:nil];
                        }
                        // and add the scrap so that it's scale matches the scrap that its built from
                        MMScrapView* addedScrap = [self addScrapWithPath:subshapePath andScale:scrap.scale];

                        // track the boundary of the scrap
                        [[MMStatTracker trackerWithName:kMPStatScrapPathSegments] trackValue:addedScrap.bezierPath.elementCount];
                        @synchronized(scrapsOnPaperState.scrapContainerView){
                            [scrapsOnPaperState.scrapContainerView insertSubview:addedScrap aboveSubview:scrap];
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

                [vectorsForAnimation addObjectsFromArray:vectors];
                [scrapsToAnimate addObjectsFromArray:scraps];
            }
        }

        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            for(int i=0;i<[vectorsForAnimation count];i++){
                MMVector* vector = [vectorsForAnimation objectAtIndex:i];
                vector = [vector normalizedTo:maxDist];
                MMScrapView* scrap = [scrapsToAnimate objectAtIndex:i];

                CGPoint newC = [vector pointFromPoint:scrap.center distance:10];
                scrap.center = newC;
            }
        } completion:nil];


        if(hasBuiltAnyScraps){
            // track if they cut existing scraps
            [[[Mixpanel sharedInstance] people] increment:kMPNumberOfScissorUses by:@(1)];
        }
        if(!hasBuiltAnyScraps && [scissorPath isClosed]){
            // track if they cut new scrap from base page
            [[[Mixpanel sharedInstance] people] increment:kMPNumberOfScissorUses by:@(1)];
            NSArray* subshapes = [[UIBezierPath bezierPathWithRect:drawableView.bounds] uniqueShapesCreatedFromSlicingWithUnclosedPath:scissorPath];
            if([subshapes count] >= 1){
                scissorPath = [[[subshapes firstObject] fullPath] copy];
            }
            
            // track circumference of newly added scrap
            [[MMStatTracker trackerWithName:kMPStatScrapPathSegments] trackValue:scissorPath.elementCount];

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
                [self saveToDisk:nil];
            } afterDelay:.01];
        }else{
            [self saveToDisk:nil];
        }
        
        // clear the dotted line of the scissor
        [shapeBuilderView clear];

    }
    @catch (NSException *exception) {
        //
        //
        // DEBUG
        //
        // TODO: https://github.com/adamwulf/loose-leaf/issues/664
        //
        // send an email with the paths that we cut
//        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
//        
//        [dateFormater setDateFormat:@"yyyy-MM-DD HH:mm:ss"];
//        NSString *convertedDateString = [dateFormater stringFromDate:[NSDate date]];
//        
//        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
//        [controller setMailComposeDelegate:self];
//        [controller setToRecipients:[NSArray arrayWithObject:@"adam.wulf@gmail.com"]];
//        [controller setSubject:[NSString stringWithFormat:@"Shape Clipping Test Case %@", convertedDateString]];
//        [controller setMessageBody:debugFullText isHTML:NO];
////        [controller addAttachmentData:imageData mimeType:@"image/png" fileName:@"screenshot.png"];
//        
//        if(controller){
//            UIViewController* rootController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
//            [rootController presentViewController:controller animated:YES completion:nil];
//        }
    }
    

    if([UIBezierPath segmentTestCount] || [UIBezierPath segmentCompareCount]){
//        DebugLog(@"segment counts: %d %d", (int)[UIBezierPath segmentTestCount], (int)[UIBezierPath segmentCompareCount]);
        [[MMStatTracker trackerWithName:kMPStatSegmentTestCount andTargetCount:100] trackValue:[UIBezierPath segmentTestCount]];
        [[MMStatTracker trackerWithName:kMPStatSegmentCompareCount andTargetCount:100] trackValue:[UIBezierPath segmentCompareCount]];
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
    for(MMScrapView* scrap in self.scrapsOnPaper){
        [scrap setShouldShowShadow:isEditable];
    }
}

-(BOOL) hasEditsToSave{
    return [super hasEditsToSave] || [scrapsOnPaperState hasEditsToSave];
}

-(BOOL) hasPenOrScrapEditsToSave{
    return [super hasEditsToSave] || [scrapsOnPaperState hasEditsToSave];
}



-(void) drawScrap:(MMScrapView*)scrap intoContext:(CGContextRef)context withSize:(CGSize)contextSize{
    @autoreleasepool {
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
        
        
        UIImage* thumbnail = nil;
        @synchronized(scrap.state){
            thumbnail = scrap.state.activeThumbnailImage;
            if(!thumbnail){
                thumbnail = [scrap.state oneOffLoadedThumbnailImage];
            }
        }
        
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
        if(thumbnail){
            [thumbnail drawInRect:scrap.bounds];
        }

        // restore the state, no more clip
        CGContextRestoreGState(context);
        
        // stroke the scrap path
        CGContextSetLineWidth(context, 1);
        [[UIColor grayColor] setStroke];
        [path stroke];
        
        CGContextRestoreGState(context);
    }
}

-(UIImage*) scrappedImgViewImage{
    return [scrappedImgViewImage image];
}

-(CGSize) thumbnailSize{
    CGSize thumbSize = self.originalUnscaledBounds.size;
    thumbSize.width /= 2;
    thumbSize.height /= 2;
    return thumbSize;
}

-(void) drawPageBackgroundInContext:(CGContextRef)context forThumbnailSize:(CGSize)thumbSize{
    [[UIColor whiteColor] setFill];
    CGContextFillRect(context, CGRectMake(0, 0, thumbSize.width, thumbSize.height));
}

-(void) updateFullPageThumbnail:(MMImmutableScrapsOnPaperState*)immutableScrapState{
    @autoreleasepool {
        UIImage* thumb = [self synchronouslyLoadInkPreview];
        CGSize thumbSize = [self thumbnailSize];
        UIGraphicsBeginImageContextWithOptions(thumbSize, NO, 0.0);
        
        // get context
        CGContextRef context = UIGraphicsGetCurrentContext();

        [self drawPageBackgroundInContext:context forThumbnailSize:thumbSize];
        
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
        
        [[JotDiskAssetManager sharedManager] writeImage:scrappedImgViewImage.image toPath:self.scrappedThumbnailPath];
        
        [[MMLoadImageCache sharedInstance] updateCacheForPath:[self scrappedThumbnailPath] toImage:scrappedImgViewImage.image];
        [[NSThread mainThread] performBlock:^{
            [self didDecompressImage:scrappedImgViewImage];
        }];
        
        definitelyDoesNotHaveAScrappedThumbnail = NO;
        
        // clean up drawing environment
        UIGraphicsEndImageContext();
    }
}

-(void) setThumbnailTo:(UIImage*)img{
    CheckMainThread;
    @autoreleasepool {
        // create the cache thumbnail view
        if(!cachedImgView && img){
            cachedImgView = [[MMCachedPreviewManager sharedInstance] requestCachedImageViewForView:self];
            cachedImgView.image = img;
            if(drawableView){
                [self.contentView insertSubview:cachedImgView belowSubview:drawableView];
            }else{
                [self.contentView insertSubview:cachedImgView belowSubview:scrapsOnPaperState.scrapContainerView];
            }
        }else if(cachedImgView && !img){
            // giving the cachedImgView back to the cache will automatically
            // remove it from the superview
            [[MMCachedPreviewManager sharedInstance] giveBackCachedImageView:cachedImgView];
            cachedImgView = nil;
        }else if(img){
            cachedImgView.image = img;
        }
    }
}

-(void) saveToDisk:(void (^)(BOOL didSaveEdits))onComplete{
    [self saveToDiskHelper:^(BOOL hadEditsToSave){
        if(hadEditsToSave){
//            DebugLog(@"saved edits for %@", self);
        }else{
//            DebugLog(@"didn't save any edits for %@", self);
        }
        if(onComplete) onComplete(hadEditsToSave);
    }];
}

-(void) saveToDiskHelper:(void (^)(BOOL))onComplete{
//    DebugLog(@"asking %@ to save to disk at %lu", self.uuid, (unsigned long)self.drawableView.undoHash);
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
    
    if(!sema1 || !sema2){
        NSLog(@"what");
        @throw [NSException exceptionWithName:@"SemaphoreException" reason:@"could not allocate semaphore" userInfo:nil];
    }

    [self updateThumbnailVisibility];
    
    __block NSUInteger lastSavedPaperStateHash = 0;
    __block NSUInteger lastSavedScrapStateHash = 0;
    
    @synchronized(self){
        hasPendingScrappedIconUpdate++;
//        DebugLog(@"%@ starting save! %d, hasPenOrScrapChanges: %d", self.uuid, hasPendingScrappedIconUpdate, [self hasPenOrScrapEditsToSave]);
    }
    
    __block BOOL pageHadBeenChanged = NO;
    __block BOOL scrapsHadBeenChanged = NO;
    
//    NSLog(@"==== starting to save %@", self.uuid);
    // save our backing page
    [super saveToDiskHelper:^(BOOL hadEditsToSave){
        // NOTE!
        // https://github.com/adamwulf/loose-leaf/issues/658
        // it's important that we use paperState.lastSavedUndoHash
        // only /after/ both semaphores are signaled. this is
        // because if a 2nd save happens too quickly, then it
        // will trigger this immediately and our lastSavedUndoHash
        // will be /before/ the currently in progress save that is
        // happening right before us. so if we check lastSavedUndoHash
        // after the signals, it'll be properly updated.
        pageHadBeenChanged = hadEditsToSave;
//        DebugLog(@"ScrapPage notified of page state save at %lu (success %d)", (unsigned long)lastSavedPaperStateHash, hadEditsToSave);
//        NSLog(@"====== signaled page's drawable view saved for %@", self.uuid);
        dispatch_semaphore_signal(sema1);
    }];
    
    __block MMImmutableScrapsOnPaperState* immutableScrapState;
    if([scrapsOnPaperState isStateLoaded]){
        // need to keep reference to immutableScrapState so that
        // we can update the thumbnail after the save
        dispatch_async([MMScrapCollectionState importExportStateQueue], ^(void) {
            @autoreleasepool {
                immutableScrapState = [scrapsOnPaperState immutableStateForPath:self.scrapIDsPath];
                scrapsHadBeenChanged = [immutableScrapState saveStateToDiskBlocking];
                lastSavedScrapStateHash = immutableScrapState.undoHash;
                //            DebugLog(@"scrapsHadBeenChanged %d %lu",scrapsHadBeenChanged, (unsigned long)immutableScrapState.undoHash);
//                NSLog(@"====== signaled scrap collection saved for %@", self.uuid);
                dispatch_semaphore_signal(sema2);
            }
        });
    }else{
        lastSavedScrapStateHash = lastSavedScrapStateHashForGeneratedThumbnail;
        dispatch_semaphore_signal(sema2);
    }

    dispatch_async([self serialBackgroundQueue], ^(void) {
        @autoreleasepool {
//            NSLog(@"====== waiting on %@ to save", self.uuid);
            dispatch_semaphore_wait(sema1, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_wait(sema2, DISPATCH_TIME_FOREVER);
//            NSLog(@"==== done waiting on %@ to save", self.uuid);
            @synchronized(self){
                hasPendingScrappedIconUpdate--;
//                DebugLog(@"%@ ending save pre icon at %lu with %d pending saves", self, (unsigned long)immutableScrapState.undoHash, hasPendingScrappedIconUpdate);
            }
            lastSavedPaperStateHash = paperState.lastSavedUndoHash;

            BOOL needsThumbnailUpdateSinceLastSave = NO;
//            DebugLog(@"checking need for thumbnail? %lu == %lu ? %lu == %lu ?", (unsigned long)lastSavedPaperStateHash,
//                  (unsigned long)lastSavedPaperStateHashForGeneratedThumbnail,
//                  (unsigned long)lastSavedScrapStateHash,
//                  (unsigned long)lastSavedScrapStateHashForGeneratedThumbnail);
            if(lastSavedPaperStateHash != lastSavedPaperStateHashForGeneratedThumbnail ||
               lastSavedScrapStateHash != lastSavedScrapStateHashForGeneratedThumbnail){
                needsThumbnailUpdateSinceLastSave = YES;
//                DebugLog(@"%@ needs thumbnail update since last generation", self);
            }else{
//                DebugLog(@"%@ doesn't need thumbnail update since last generation", self);
            }
            
            // NOTE:
            // we need to check [hasPenOrScrapEditsToSave] not [hasEditsToSave].
            // otherwise we'd accidentally take undoManager etc into account
            // when we shouldn't (since undoManager will aways save after us
            if([self hasPenOrScrapEditsToSave] || self.paperState.isForgetful){
                if(self.paperState.isForgetful){
                    DebugLog(@"forget: page is forgetful, bailing save early");
                }
//                DebugLog(@"i have more edits to save for %@ (now %lu). bailing. %d %d %d",self.uuid, (unsigned long) immutableScrapState.undoHash, pageHadBeenChanged, scrapsHadBeenChanged, needsThumbnailUpdateSinceLastSave);
                // our save failed. this may happen if we
                // call [saveToDisk] in very quick succession
                // so that the 1st call is still saving, and the
                // 2nd ends early b/c it knows the 1st is still going
//                DebugLog(@"saved %@ but still have edits to save: saved at %lu but is now %lu",self.uuid, (unsigned long)immutableScrapState.undoHash,
//                      (unsigned long)[self.scrapsOnPaperState immutableStateForPath:nil].undoHash);
//                DebugLog(@"%@ needs save at %lu: %d %d",self, (unsigned long)[self.scrapsOnPaperState immutableStateForPath:nil].undoHash, [super hasEditsToSave], [scrapsOnPaperState hasEditsToSave]);
                if(onComplete) onComplete(NO);
                return;
            }else{
//                DebugLog(@"finished save for %@ %d %d %d (at %lu)", self.uuid, pageHadBeenChanged, scrapsHadBeenChanged, needsThumbnailUpdateSinceLastSave, (unsigned long) immutableScrapState.undoHash);
            }
            
            if(!hasPendingScrappedIconUpdate && (needsThumbnailUpdateSinceLastSave || pageHadBeenChanged || scrapsHadBeenChanged)){
                // only save a new thumbnail when we're the last pending save.
                // otherwise the next pending save will generate it
                if(immutableScrapState){
                    // only update our last saved hash when
                    // we actually generate the thumbnail.
                    lastSavedPaperStateHashForGeneratedThumbnail = lastSavedPaperStateHash;
                    lastSavedScrapStateHashForGeneratedThumbnail = lastSavedScrapStateHash;
//                    DebugLog(@"generating thumbnail for %@ (at %lu) with %d saves in progress",self, (unsigned long) immutableScrapState.undoHash, hasPendingScrappedIconUpdate);
                    // only save a new thumbnail if we have our state loaded
                    [self updateFullPageThumbnail:immutableScrapState];
                }else{
//                    DebugLog(@"can't generating thumbnail without immutableScrapState for %@ (at %lu) with %d saves in progress",self, (unsigned long) immutableScrapState.undoHash, hasPendingScrappedIconUpdate);
                }
//                DebugLog(@"done generating thumbnail (at %lu) with %d saves in progress", (unsigned long) immutableScrapState.undoHash, hasPendingScrappedIconUpdate);
            }else if(hasPendingScrappedIconUpdate){
//                DebugLog(@"%@ skipped generating thumbnail (at %lu) because of %d pending saves",self, (unsigned long) immutableScrapState.undoHash, hasPendingScrappedIconUpdate);
            }else{
//                DebugLog(@"%@ skipped generating thumbnail (at %lu) because page and scraps hadn't changed",self, (unsigned long) immutableScrapState.undoHash);
            }

            [NSThread performBlockOnMainThread:^{
//                DebugLog(@"done saving page (at %lu)", (unsigned long) immutableScrapState.undoHash);
                // reset canvas visibility
                if(!self.paperState.isForgetful){
                    [self updateThumbnailVisibility];
                }else{
                    DebugLog(@"forget: skipping thumbnail update");
                }
                [self.delegate didSavePage:self];
                if(onComplete) onComplete(YES);
            }];
        }
    });
}

-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize)pagePixelSize andScale:(CGFloat)scale andContext:(JotGLContext*)context{
    CheckMainThread;
//    DebugLog(@"asking %@ to load state", self.uuid);
    [super loadStateAsynchronously:async withSize:pagePixelSize andScale:scale andContext:context];
    if([[NSFileManager defaultManager] fileExistsAtPath:self.scrapIDsPath]){
        [scrapsOnPaperState loadStateAsynchronously:async atPath:self.scrapIDsPath andMakeEditable:YES];
//        [scrapsOnPaperState unloadPaperState];
//        [scrapsOnPaperState loadStateAsynchronously:async atPath:self.scrapIDsPath andMakeEditable:YES];
    }else{
        [scrapsOnPaperState loadStateAsynchronously:async atPath:self.bundledScrapIDsPath andMakeEditable:YES];
    }
}

-(void) unloadState{
    CheckMainThread;
//    DebugLog(@"asking %@ to unload", self.uuid);
    [super unloadState];
    __block MMScrapsOnPaperState* strongScrapState = scrapsOnPaperState;
    dispatch_async([MMScrapCollectionState importExportStateQueue], ^(void) {
        @autoreleasepool {
            [[strongScrapState immutableStateForPath:self.scrapIDsPath] saveStateToDiskBlocking];
            // unloading the scrap state will also remove them
            // from their superview (us)
            [strongScrapState unloadPaperState];
            strongScrapState = nil;
        }
    });
}

// this method will load the scrapsOnPaperState, run
// the input block that requires the loaded state,
// and then will save and unload the scrapsOnPaper state
//
// this allows us to drop scraps onto pages that don't
// have their scrapsOnPaperState loaded
-(void) performBlockForUnloadedScrapStateSynchronously:(void(^)())block andImmediatelyUnloadState:(BOOL)shouldImmediatelyUnload andSavePaperState:(BOOL)shouldSavePaperState{
    CheckThreadMatches([NSThread isMainThread] || [MMTrashManager isTrashManagerQueue]);
    [scrapsOnPaperState performBlockForUnloadedScrapStateSynchronously:block
                                                       onBlockComplete:^{
                                                           if(shouldSavePaperState){
                                                               MMImmutableScrapsOnPaperState* immutableScrapState = [self.scrapsOnPaperState immutableStateForPath:scrapIDsPath];
                                                               [immutableScrapState saveStateToDiskBlocking];
                                                               [NSThread performBlockOnMainThread:^{
                                                                   [self updateFullPageThumbnail:immutableScrapState];
                                                               }];
                                                           }
                                                       }
                                                           andLoadFrom:self.scrapIDsPath
                                               withBundledScrapIDsPath:self.bundledScrapIDsPath
                                             andImmediatelyUnloadState:shouldImmediatelyUnload];
}

-(BOOL) isStateLoaded{
    return [super isStateLoaded];
}
-(BOOL) isStateLoading{
    return [super isStateLoading] || [scrapsOnPaperState isCollectionStateLoading];
}


#pragma mark - MMScrapsOnPaperStateDelegate / MMScrapCollectionStateDelegate

-(NSString*) uuidOfScrapCollectionStateOwner{
    return self.uuid;
}

-(MMScrappedPaperView*) page{
    return self;
}

-(void) didLoadScrapInContainer:(MMScrapView*)scrap{
    [scrap setShouldShowShadow:self.isEditable];
}

-(void) didLoadScrapOutOfContainer:(MMScrapView*)scrap{
    [scrap setShouldShowShadow:self.isEditable];
}

-(void) didLoadAllScrapsFor:(MMScrapCollectionState*)scrapState{
    // check to see if we've also loaded
    lastSavedScrapStateHashForGeneratedThumbnail = [scrapState lastSavedUndoHash];
    [self didLoadState:self.paperState];
    [self updateThumbnailVisibility];
}

-(void) didUnloadAllScrapsFor:(MMScrapCollectionState*)scrapState{
    lastSavedScrapStateHashForGeneratedThumbnail = 0;
    [self updateThumbnailVisibility];
}

-(void) loadCachedPreview{
    [self loadCachedPreviewAndDecompressImmediately:NO];
}


/**
 * load any scrap previews, if applicable.
 * not sure if i'll just draw these into the
 * page preview or not
 */
-(void) loadCachedPreviewAndDecompressImmediately:(BOOL)forceToDecompressImmediately{
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
}

-(void) didDecompressImage:(MMDecompressImagePromise*)promise{
    [self updateThumbnailVisibility:YES];
}

-(void) unloadCachedPreview{
    @autoreleasepool {
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
            dispatch_async([MMScrapCollectionState importExportStateQueue], ^(void) {
                @autoreleasepool {
                    // save if needed
                    // currently this will always save to disk. in the future #338
                    // we should only save if this has changed.
                    [[strongScrapState immutableStateForPath:self.scrapIDsPath] saveStateToDiskBlocking];
                    // free all scraps from memory too
                    [strongScrapState unloadPaperState];
                }
            });
        }
    }
}

-(MMScrapView*) scrapForUUIDIfAlreadyExistsInOtherContainer:(NSString*)scrapUUID{
    return [self.delegate scrapForUUIDIfAlreadyExistsInOtherContainer:scrapUUID];
}

-(void) deleteScrapWithUUID:(NSString*)scrapUUID shouldRespectOthers:(BOOL)respectOthers{
    @throw kAbstractMethodException;
}

#pragma mark - JotViewStateProxyDelegate

/**
 * TODO: only fire off these state methods
 * if we have also loaded state for our scraps
 * https://github.com/adamwulf/loose-leaf/issues/254
 */
-(void) didLoadState:(JotViewStateProxy*)state{
    if([self isStateLoaded]){
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
    return [[[self pagesPath] stringByAppendingPathComponent:@"scrapped.thumb"] stringByAppendingPathExtension:@"png"];
}

-(NSString*) bundledScrappedThumbnailPath{
    return [[[self bundledPagesPath] stringByAppendingPathComponent:@"scrapped.thumb"] stringByAppendingPathExtension:@"png"];
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


#pragma mark - dealloc

-(void) dealloc{
    CheckMainThread;
    [[MMLoadImageCache sharedInstance] clearCacheForPath:self.scrappedThumbnailPath];
    [[MMLoadImageCache sharedInstance] clearCacheForPath:self.bundledScrappedThumbnailPath];
    if(!scrappedImgViewImage.isDecompressed){
        [scrappedImgViewImage cancel];
    }
    [self setThumbnailTo:nil];
    scrappedImgViewImage = nil;
    [cachedImgView removeFromSuperview];
    cachedImgView = nil;
}


@end
