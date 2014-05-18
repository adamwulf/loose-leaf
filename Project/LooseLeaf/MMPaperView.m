//
//  MMPaperView.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSArray+MapReduce.h"
#import "MMShadowManager.h"
#import "NSString+UUID.h"
#import "UIView+Debug.h"

@implementation MMPaperView{
    CGRect originalUnscaledBounds;
}

@synthesize scale;
@synthesize delegate;
@synthesize isBeingPannedAndZoomed;
@synthesize textLabel;
@synthesize isBrandNewPage;
@synthesize uuid;
@synthesize unitShadowPath;
@synthesize originalUnscaledBounds;
@synthesize panGesture;

- (id)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame andUUID:[NSString createStringUUID]];
}

- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        uuid = _uuid;
        originalUnscaledBounds = self.bounds;
        
        [self.layer setMasksToBounds:YES ];
        self.scale = 1;

        //
        // allow the user to select an object by long pressing
        // on it. this'll allow the user to select + move/scale/rotate
        // an object in one gesture
        longPress = [[MMObjectSelectLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPress.numberOfTouchesRequired = 2;
        longPress.allowableMovement = 20;
        [self addGestureRecognizer:longPress];
        //
        // allow the user to select an object by tapping on the page
        // with two fingers
        tap = [[MMImmovableTapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleFingerDoubleTap:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 2;
        //
        // only allow tap if the long press fails, otherwise
        // we'll get a double positive
        [tap requireGestureRecognizerToFail:longPress];
        [self addGestureRecognizer:tap];

        //
        // This pan gesture is used to pan/scale the page itself.
        panGesture = [[MMPanAndPinchGestureRecognizer alloc] initWithTarget:self action:@selector(panAndScale:)];
        panGesture.bezelDirectionMask = MMBezelDirectionRight | MMBezelDirectionLeft;
        //
        // This gesture is only allowed to run if the user is not
        // acting on an object on the page. defer to the long press
        // and the tap gesture, and only allow page pan/scale if
        // these fail
        [panGesture requireGestureRecognizerToFail:longPress];
        [panGesture requireGestureRecognizerToFail:tap];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}


-(void) setScale:(CGFloat)_scale{
    if(_scale == 0){
        NSLog(@"what");
    }
    scale = _scale;
}


-(void) setFrame:(CGRect)_frame{
    if(!_frame.size.width){
        debug_NSLog(@"zero width");
    }
    [super setFrame:_frame];
    // now that we have adjusted our frame
    // let's set our scale to match exactly what our
    // actual frame scale is
    self.scale = _frame.size.width / originalUnscaledBounds.size.width;
}


#pragma mark - Gestures

-(void) longPress:(MMObjectSelectLongPressGestureRecognizer*)pressGesture{
    if(pressGesture.state == UIGestureRecognizerStateBegan){
        [self.delegate didLongPressPage:self withTouches:pressGesture.activeTouches];
    }
}

-(void) doubleFingerDoubleTap:(UITapGestureRecognizer*)tapGesture{
    debug_NSLog(@"tap! %d", (int) tapGesture.state);
}


/**
 * helpful when testing visible vs hidden pages
 */
-(void)didMoveToSuperview{
    return;
    if(isBrandNewPage){
        self.backgroundColor = [UIColor blueColor];
    }else if([self.delegate isInVisibleStack:self]){
        self.backgroundColor = [UIColor greenColor];
    }else{
        self.backgroundColor = [UIColor redColor];
    }
}
 


/**
 * returns true if the gesture will exit the right bezel
 * returns false if the gesture will not exit bezel
 *
 * returns false if the gesture is ended or canceled!
 * this means a valid bezel gesture will return false here
 * if it has ended.
 */
-(BOOL) willExitToBezel:(MMBezelDirection)bezelDirection{
    if(self.scale < kMinPageZoom){
        return NO;
    }
    BOOL isBezel = (panGesture.didExitToBezel & bezelDirection) != MMBezelDirectionNone;
    return isBezel && (panGesture.subState != UIGestureRecognizerStateChanged);
}

/**
 * returns the number of times the user has exited the bezel,
 * but only if the page is currently being exited bezel. If the
 * user has pulled it back in, then 0 is returned.
 */
-(NSInteger) numberOfTimesExitedBezel{
    if(self.scale < kMinPageZoom){
        return 0;
    }
    BOOL isBezeled = (panGesture.didExitToBezel & panGesture.bezelDirectionMask) != MMBezelDirectionNone;
    BOOL willExit = isBezeled && (panGesture.state == UIGestureRecognizerStateChanged || panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled);
    if(willExit){
        return 1;
    }
    return 0;
}


/**
 * cancels all gestures attached to
 * this page, if they are cancelable
 */
-(void) cancelAllGestures{
    for(UIGestureRecognizer* gesture in self.gestureRecognizers){
        if([gesture respondsToSelector:@selector(cancel)]){
            if(gesture.enabled && gesture.state != UIGestureRecognizerStatePossible){
//                NSLog(@"gesture is active %@", gesture);
            }
            [(MMPanAndPinchGestureRecognizer*)gesture cancel];
        }
    }
}
/**
 * disables all gestures on this page
 */
-(void) disableAllGestures{
    for(UIGestureRecognizer* gesture in self.gestureRecognizers){
        if(gesture.enabled && gesture.state != UIGestureRecognizerStatePossible){
//            NSLog(@"gesture is active %@ %d", gesture, gesture.state);
        }
        [gesture setEnabled:NO];
    }
    textLabel.text = @"disabled";
    if([self.uuid hasPrefix:@"41B98"]){
        NSLog(@"disabled: %@ %d", self.uuid, panGesture.enabled);
    }
}
/**
 * enables all gestures on this page
 */
-(void) enableAllGestures{
    for(UIGestureRecognizer* gesture in self.gestureRecognizers){
        [gesture setEnabled:YES];
    }
    textLabel.text = @"enabled";
    if([self.uuid hasPrefix:@"41B98"]){
        NSLog(@"enabled: %@", self.uuid);
    }
}


/**
 * this is the heart of the two finger zoom/pan for pages
 *
 * the premise is:
 *
 * a) if two fingers are down, then pan and zoom
 * b) if the user lifts a finger, then stop all motion, but don't yield to any other gesture
 *      (ios default is to continue the gesture altogether. instead we'll stop the gesture, but still won't yeild)
 * c) the zoom should zoom into the location of the zoom gesture. don't just zoom from top/left or center
 * d) lock zoom at kMinPageZoom > kMaxPageZoom
 * e) call delegates to ask if panning or zoom should even be enabled
 * f) call delegates to ask them to perform any other modifications to the frame before setting it to the page
 * g) notify the delegate when the pan and zoom is complete
 *
 * TODO
 * its possible using 3+ fingers to have the page suddenly fly offscreen
 * i should possibly cap the speed that the page can move just like i do with scale,
 * and also should ensure it never goes offscreen. there's no reason to show less than 100px
 * in any direction (maybe more).
 *
 * to fix this, i should figure out the offset that the gesture position changes for
 * every new touch added to the gesture, then the page won't move at all when new
 * touches are added
 *
 *
 *
 * TODO
 * need to pull out the logic that scales the actual page into a separate method.
 * this way, i can send in a normalized gesture location + scale from inputs to a method
 * instead of state thats kept in this page object. then i can refactor to have both of my
 * pan gestures use proper state control etc to zoom a page in and out.
 */
-(void) panAndScale:(MMPanAndPinchGestureRecognizer*)_panGesture{
    if(![self.delegate shouldAllowPan:self]){
        return;
    }
    //
    // procede with the pan gesture
    CGPoint lastLocationInSuper = [panGesture locationInView:self.superview];
    
//    debug_NSLog(@"pan: %d %f %f", panGesture.state, lastLocationInSuper.x, lastLocationInSuper.y);
    
//    NSLog(@"panAndScale cancelled: %d   ended: %d   began: %d   failed: %d", panGesture.state == UIGestureRecognizerStateCancelled,
//          panGesture.state == UIGestureRecognizerStateEnded, panGesture.state == UIGestureRecognizerStateBegan,
//          panGesture.state == UIGestureRecognizerStateFailed);
    
    if(panGesture.state == UIGestureRecognizerStateCancelled ||
       panGesture.state == UIGestureRecognizerStateEnded ||
       panGesture.state == UIGestureRecognizerStateFailed ||
       ([_panGesture.validTouches count] == 0 && isBeingPannedAndZoomed)){
        if(panGesture.hasPannedOrScaled){
            if(isBeingPannedAndZoomed){
                isBeingPannedAndZoomed = NO;
                if(scale < (kMinPageZoom + kZoomToListPageZoom)/2 && panGesture.didExitToBezel == MMBezelDirectionNone){
                    if((_panGesture.scaleDirection & MMScaleDirectionSmaller) == MMScaleDirectionSmaller){
                        [self.delegate finishedScalingReallySmall:self];
                    }else{
                        [self.delegate cancelledScalingReallySmall:self];
                    }
                }else{
                    if(scale < kMinPageZoom){
                        [self.delegate cancelledScalingReallySmall:self];
                    }
                    [self.delegate finishedPanningAndScalingPage:self
                                                       intoBezel:panGesture.didExitToBezel
                                                       fromFrame:panGesture.frameOfPageAtBeginningOfGesture
                                                         toFrame:self.frame];
                }
            }
        }
        return;
    }else if(panGesture.subState == UIGestureRecognizerStatePossible){
        //
        // the gesture requires 2 fingers. it may still say it only has 1 touch if the user
        // started the gesture with 2 fingers but then lifted a finger. in that case, 
        // don't continue the gesture at all, just wait till they finish it proper or re-put
        // that 2nd touch down
        isBeingPannedAndZoomed = NO;
        return;
    }else if(!isBeingPannedAndZoomed && (panGesture.subState == UIGestureRecognizerStateBegan ||
                                         panGesture.subState == UIGestureRecognizerStateChanged)){
        isBeingPannedAndZoomed = YES;
        //
        // if the user had 1 finger down and re-touches with the 2nd finger, then this
        // will be called as if it was a "new" gesture. this lets the pan and zoom start
        // from the correct new gesture area of the page.
        //
        // to test. begin pan/zoom in bottom left, then lift 1 finger and move to the top right
        // of the page, then re-pan/zoom on the top right. it should "just work".

        // notify the delegate of our state change
        [self.delegate isBeginning:YES
                 toPanAndScalePage:self
                         fromFrame:panGesture.frameOfPageAtBeginningOfGesture
                           toFrame:panGesture.frameOfPageAtBeginningOfGesture
                           withTouches:panGesture.validTouches];
        return;
    }
    
    if([_panGesture.validTouches count] < 2){
        NSLog(@"skipping pan gesture: has %d valid touches and substate %d", (int) [_panGesture.validTouches count], (int) _panGesture.subState);
        return;
    }

    //
    // to track panning, we collect the first location of the pan gesture, and calculate the offset
    // of the current location of the gesture. that distance is the amount moved for the pan.
    if([self.delegate allowsScaleForPage:self]){
        CGFloat gestureScale = panGesture.scale;
        CGFloat targetScale = panGesture.preGestureScale * gestureScale;
        CGFloat scaleDiff = ABS((float)(targetScale - scale));
        
        //
        // to track scaling, the scale value has to be a value between kMinPageZoom and kMaxPageZoom of the /superview/'s size
        // if i begin scaling an already zoomed in page, the gesture's default is the re-begin the zoom at 1.0x
        // even though it may be 2x of our page size. so we need to remember the current scale in preGestureScale
        // and multiply that by the gesture's scale value. this gives us the scale value as a factor of the superview
        
        BOOL didCancelSmallScale = NO;
        if(targetScale >= kMinPageZoom && scale < kMinPageZoom){
            didCancelSmallScale = YES;
        }
        if(targetScale > kMaxPageZoom){
            self.scale = kMaxPageZoom;
            if(didCancelSmallScale) [self.delegate cancelledScalingReallySmall:self];
        }else if(targetScale < kMinPageZoom && scale >= kMinPageZoom){
            // doesn't count if the bezel is exiting.
            //
            // this tracks if the user is zooming out far enough to trigger a zoom into
            // list mode
            self.scale = targetScale;
            [self.delegate isBeginningToScaleReallySmall:self];
        }else if((targetScale >= 1 && scaleDiff > kMinScaleDelta) ||
                 (targetScale < 1 && scaleDiff > kMinScaleDelta / 2)){
            self.scale = targetScale;
            if(didCancelSmallScale) [self.delegate cancelledScalingReallySmall:self];
        }
    }
    
    if(CGPointEqualToPoint(panGesture.normalizedLocationOfScale, CGPointZero)){
        // somehow the pan gesture doesn't always get initialized above as it
        // should when it changes from < 2 touches to 2 touches. i'm having a very
        // hard time reproing after the last fix (chaging to < 2 from == 1 above)
        // but occassionally the page still jumps when panning while drawing.
        @throw [NSException exceptionWithName:@"Pan Exception" reason:@"location of pan gesture is unknown" userInfo:nil];
    }
    
    //
    // now, with our pan offset and new scale, we need to calculate the new frame location.
    //
    // first, find the location of the gesture at the size of the page before the gesture began.
    // then, find the location of the gesture at the new scale of the page.
    // since we're using the normalized location of the gesture, this will make sure the before/after
    // location of the gesture is in the same place of the view after scaling the width/height.
    // the difference in these locations is how muh we need to move the origin of the page to
    // accomodate the new scale while maintaining the location of the gesture uner the user's fingers
    //
    // the, add the diff of the pan gesture to get the full displacement of the origin. also set the
    // width and height to the new scale.
    CGSize superviewSize = self.superview.bounds.size;
    CGPoint locationOfPinchAfterScale = CGPointMake(scale * panGesture.normalizedLocationOfScale.x * superviewSize.width,
                                                    scale * panGesture.normalizedLocationOfScale.y * superviewSize.height);
    CGSize newSizeOfView = CGSizeMake(superviewSize.width * scale, superviewSize.height * scale);

    
    //
    // now calculate our final frame given our pan and zoom
    CGRect fr = self.frame;
    CGPoint newOriginOfView = CGPointMake(lastLocationInSuper.x - locationOfPinchAfterScale.x,
                                 lastLocationInSuper.y - locationOfPinchAfterScale.y);
    fr.origin = newOriginOfView;
    fr.size = newSizeOfView;
    
    //
    // now, notify delegate that we're about to set the frame of the page during a gesture,
    // and give it a chance to modify the frame if at all needed.
    fr = [self.delegate isBeginning:NO
                  toPanAndScalePage:self
                      fromFrame:panGesture.frameOfPageAtBeginningOfGesture
                        toFrame:fr
                        withTouches:panGesture.validTouches];
    
    if(panGesture.state != UIGestureRecognizerStateCancelled &&
       panGesture.state != UIGestureRecognizerStateEnded &&
       panGesture.state != UIGestureRecognizerStateFailed){
        //
        // now we're ready, set the frame!
        //
        // only set it if a delegate didn't change our state to
        // complete the gesture. this can happen if the gesture
        // is cancelled
        self.frame = fr;
    }
}


#pragma mark - PaintableViewDelegate

-(NSArray*) paintableViewsAbove:(UIView*)aView{
    return [NSArray array];
}

-(BOOL) shouldDrawClipPath{
    return NO;
}

-(CGAffineTransform) transform{
    return CGAffineTransformIdentity;
}


#pragma mark - List View

-(NSInteger) rowInListView{
    NSInteger indexOfPage = [self.delegate indexOfPageInCompleteStack:self];
    return [self.delegate rowInListViewGivenIndex:indexOfPage];
}

-(NSInteger) columnInListView{
    NSInteger indexOfPage = [self.delegate indexOfPageInCompleteStack:self];
    return [self.delegate columnInListViewGivenIndex:indexOfPage];
}


#pragma mark - description

-(NSString*) description{
    return [NSString stringWithFormat:@"[%@ %@]", NSStringFromClass(self.class), self.uuid];
}

-(NSDictionary*) dictionaryDescription{
    return [NSDictionary dictionaryWithObjectsAndKeys:NSStringFromClass(self.class), @"class",
            self.uuid, @"uuid", nil];
}

@end
