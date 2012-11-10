//
//  SLPaperView.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 Skylight, LLC. All rights reserved.
//

#import "SLPaperView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSArray+MapReduce.h"
#import "SLShadowManager.h"
#import "NSString+UUID.h"
#import "UIView+Debug.h"
#import "SLObjectSelectLongPressGestureRecognizer.h"
#import "SLDrawingGestureRecognizer.h"
#import "SLImmovableTapGestureRecognizer.h"

@implementation SLPaperView

@synthesize scale;
@synthesize delegate;
@synthesize isBeingPannedAndZoomed;
@synthesize textLabel;
@synthesize isBrandNewPage;
@synthesize uuid;
@synthesize unitShadowPath;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        uuid = [[NSString createStringUUID] retain];
        
        //////////////////////////////////////////////////////////////////////
        //
        // debug image to help show page zoom/pan etc better
        // than a blank page
        //
        NSInteger photo = rand() % 6 + 1;
        UIImage* img = [UIImage imageNamed:[NSString stringWithFormat:@"img0%d.jpg", photo]];
        UIImageView* imgView = [[[UIImageView alloc] initWithImage:img] autorelease];
        imgView.frame = self.contentView.bounds;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imgView.clipsToBounds = YES;
//        [self.contentView addSubview:imgView];
        //
        // end debug image
        //
        //////////////////////////////////////////////////////////////////////
        [self.layer setMasksToBounds:YES ];
        preGestureScale = 1;
        self.scale = 1;
        
        paintView = [[PaintView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width * kMaxPageResolution, self.bounds.size.height * kMaxPageResolution)];
        paintView.autoresizingMask = UIViewAutoresizingNone; // UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:paintView];
        initialPaintViewFrame = paintView.frame;
        [self updatePaintScaleTransform];
        
        
        
        
        //
        // this gesture handles any single finger drawing
        // on the page. any gesture that overrides the one finger
        // drag (a pan or scale, for instance) will need to call
        // [cancel] on this gesture to make sure that the drawing
        // turns off
        drawGesture = [[SLDrawingGestureRecognizer alloc] initWithTarget:self action:@selector(draw:)];
        drawGesture.minimumNumberOfTouches = 1;
        drawGesture.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:drawGesture];
        

        //
        // allow the user to select an object by long pressing
        // on it. this'll allow the user to select + move/scale/rotate
        // an object in one gesture
        SLObjectSelectLongPressGestureRecognizer* longPress = [[[SLObjectSelectLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]autorelease];
        longPress.numberOfTouchesRequired = 2;
        [self addGestureRecognizer:longPress];
        //
        // allow the user to select an object by tapping on the page
        // with two fingers
        SLImmovableTapGestureRecognizer* tap = [[[SLImmovableTapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleFingerDoubleTap:)] autorelease];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 2;
        //
        // only allow tap if the long press fails, otherwise
        // we'll get a double positive
        [tap requireGestureRecognizerToFail:longPress];
        [self addGestureRecognizer:tap];

        
        
                
        
        //
        // This pan gesture is used to pan/scale the page itself.
        panGesture = [[[SLPanAndPinchGestureRecognizer alloc]
                                               initWithTarget:self 
                                                      action:@selector(panAndScale:)] autorelease];
        panGesture.bezelDirectionMask = SLBezelDirectionRight | SLBezelDirectionLeft;
        //
        // This gesture is only allowed to run if the user is not
        // acting on an object on the page. defer to the long press
        // and the tap gesture, and only allow page pan/scale if
        // these fail
        [panGesture requireGestureRecognizerToFail:longPress];
        [panGesture requireGestureRecognizerToFail:tap];
//        [draw requireGestureRecognizerToFail:tap];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}


-(void) setScale:(CGFloat)_scale{
    scale = _scale;
}

/**
 * this function makes sure that our paint view,
 * regardless of size, is scaled properly to exactly fit
 * our page
 *
 * this way, we can make a paint view 2x our screen size,
 * so that it's native resolution when fully zoomed
 */
-(void) updatePaintScaleTransform{
    paintView.transform = CGAffineTransformMakeScale(self.frame.size.width / initialPaintViewFrame.size.width,
                                                     self.frame.size.height / initialPaintViewFrame.size.height);
    paintView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}

-(void) setFrame:(CGRect)_frame{
    [super setFrame:_frame];
    [self updatePaintScaleTransform];
}

-(void) longPress:(UILongPressGestureRecognizer*)pressGesture{
    NSLog(@"long press!!!!! %d", pressGesture.state);
}

-(void) doubleFingerDoubleTap:(UITapGestureRecognizer*)tapGesture{
    NSLog(@"tap! %d", tapGesture.state);
}

-(void) draw:(SLDrawingGestureRecognizer*)_drawGesture{
    if(drawGesture.state == UIGestureRecognizerStateBegan ||
       drawGesture.state == UIGestureRecognizerStateChanged ||
       drawGesture.state == UIGestureRecognizerStateEnded){
        if(drawGesture.pathElement.type == kCGPathElementMoveToPoint){
            [self drawDotAtPoint:drawGesture.startPoint withFingerWidth:drawGesture.fingerWidth fromView:self];
        }else if(drawGesture.pathElement.type == kCGPathElementAddLineToPoint){
            [self drawLineAtStart:drawGesture.startPoint
                              end:drawGesture.pathElement.points[0]
                  withFingerWidth:drawGesture.fingerWidth
                         fromView:self];
        }else if(drawGesture.pathElement.type == kCGPathElementAddCurveToPoint){
            [self drawArcAtStart:drawGesture.startPoint
                             end:drawGesture.pathElement.points[2]
                   controlPoint1:drawGesture.pathElement.points[0]
                   controlPoint2:drawGesture.pathElement.points[1]
                 withFingerWidth:drawGesture.fingerWidth
                        fromView:self];
        }
        if(drawGesture.state == UIGestureRecognizerStateEnded){
            [self commitStroke];
        }
    }else{
        // cancelled or something
        [self cancelStroke];
    }
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
-(BOOL) willExitToBezel:(SLBezelDirection)bezelDirection{
    BOOL isBezel = (panGesture.didExitToBezel & bezelDirection) != SLBezelDirectionNone;
    return isBezel && (panGesture.state == UIGestureRecognizerStateChanged) && panGesture.numberOfTouches == 1;
}

/**
 * returns the number of times the user has exited the bezel,
 * but only if the page is currently being exited bezel. If the
 * user has pulled it back in, then 0 is returned.
 */
-(NSInteger) numberOfTimesExitedBezel{
    BOOL isBezeled = (panGesture.didExitToBezel & panGesture.bezelDirectionMask) != SLBezelDirectionNone;
    BOOL willExit = isBezeled && (panGesture.state == UIGestureRecognizerStateChanged || panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled);
    if(willExit){
        return panGesture.numberOfRepeatingBezels;
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
            [(SLPanAndPinchGestureRecognizer*)gesture cancel];
        }
    }
}
/**
 * disables all gestures on this page
 */
-(void) disableAllGestures{
    for(UIGestureRecognizer* gesture in self.gestureRecognizers){
        [gesture setEnabled:NO];
    }
    textLabel.text = @"disabled";
}
/**
 * enables all gestures on this page
 */
-(void) enableAllGestures{
    for(UIGestureRecognizer* gesture in self.gestureRecognizers){
        [gesture setEnabled:YES];
    }
    textLabel.text = @"enabled";
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
-(void) panAndScale:(SLPanAndPinchGestureRecognizer*)_panGesture{
    //
    // cancel drawing, if any
    [drawGesture cancel];
    [drawGesture setEnabled:NO];
    
    
    //
    // procede with the pan gesture
    CGPoint lastLocationInSelf = [panGesture locationInView:self];
    CGPoint lastLocationInSuper = [panGesture locationInView:self.superview];
    
//    NSLog(@"pan: %d %f %f", panGesture.state, lastLocationInSuper.x, lastLocationInSuper.y);
    
    CGPoint velocity = [_panGesture velocity];
    if(panGesture.state == UIGestureRecognizerStateCancelled ||
       panGesture.state == UIGestureRecognizerStateEnded ||
       panGesture.state == UIGestureRecognizerStateFailed){
        //
        // pan is finished, re-enable drawing
        [drawGesture setEnabled:YES];

        if(scale < kMinPageZoom && panGesture.didExitToBezel == SLBezelDirectionNone){
            isBeingPannedAndZoomed = NO;
            if((_panGesture.scaleDirection & SLScaleDirectionSmaller) == SLScaleDirectionSmaller){
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
                                               fromFrame:frameOfPageAtBeginningOfGesture
                                                 toFrame:self.frame
                                            withVelocity:velocity];
        }
        
        isBeingPannedAndZoomed = NO;
        return;
    }else if(panGesture.numberOfTouches == 1){
        if(lastNumberOfTouchesForPanGesture != 1){
            // notify the delegate of our state change
            [self.delegate isPanningAndScalingPage:self
                                         fromFrame:frameOfPageAtBeginningOfGesture
                                           toFrame:frameOfPageAtBeginningOfGesture];
        }
        //
        // the gesture requires 2 fingers. it may still say it only has 1 touch if the user
        // started the gesture with 2 fingers but then lifted a finger. in that case, 
        // don't continue the gesture at all, just wait till they finish it proper or re-put
        // that 2nd touch down
        lastNumberOfTouchesForPanGesture = 1;
        isBeingPannedAndZoomed = NO;
        return;
    }else if(lastNumberOfTouchesForPanGesture == 1 ||
             panGesture.state == UIGestureRecognizerStateBegan){
        isBeingPannedAndZoomed = YES;
        //
        // if the user had 1 finger down and re-touches with the 2nd finger, then this
        // will be called as if it was a "new" gesture. this lets the pan and zoom start
        // from the correct new gesture are of the page.
        //
        // to test. begin pan/zoom in bottom left, then lift 1 finger and move to the top right
        // of the page, then re-pan/zoom on the top right. it should "just work".
        
        // Reset Panning
        // ====================================================================================
        // we know a valid gesture has 2 touches down
        lastNumberOfTouchesForPanGesture = 2;
        // find the location of the first touch in relation to the superview.
        // since the superview doesn't move, this'll give us a static coordinate system to
        // measure panning distance from
        firstLocationOfPanGestureInSuperView = [panGesture locationInView:self.superview];
        // note the origin of the frame before the gesture begins.
        // all adjustments of panning/zooming will be offset from this origin.
        frameOfPageAtBeginningOfGesture = self.frame;
        
        // Reset Scaling
        // ====================================================================================
        // remember the scale of the view before the gesture begins. we'll normalize the gesture's
        // scale value to the superview location by multiplying it to the page's current scale
        preGestureScale = self.scale;
        // the normalized location of the gesture is (0 < x < 1, 0 < y < 1).
        // this lets us locate where the gesture should be in the view from any width or height
        normalizedLocationOfScale = CGPointMake(lastLocationInSelf.x / self.frame.size.width,
                                                lastLocationInSelf.y / self.frame.size.height);

        // notify the delegate of our state change
        [self.delegate isPanningAndScalingPage:self
                                     fromFrame:frameOfPageAtBeginningOfGesture
                                       toFrame:frameOfPageAtBeginningOfGesture];
        return;
    }
    
    
    //
    // to track panning, we collect the first location of the pan gesture, and calculate the offset
    // of the current location of the gesture. that distance is the amount moved for the pan.
//    panDiffLocation = CGPointMake(lastLocationInSuperview.x - firstLocationOfPanGestureInSuperView.x, lastLocationInSuperview.y - firstLocationOfPanGestureInSuperView.y);
    
    if([self.delegate allowsScaleForPage:self]){
        
        CGFloat gestureScale = panGesture.scale;
        CGFloat targetScale = preGestureScale * gestureScale;
        CGFloat scaleDiff = ABS((float)(targetScale - scale));
//        if(targetScale > 1){
//            targetScale = roundf(targetScale * 2) / 2;
//        }
        
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
        }else if(targetScale < kMinPageZoom && scale >= kMinPageZoom && ![_panGesture didExitToBezel]){
            // doesn't count if the bezel is exiting.
            //
            // this tracks if the user is zooming out far enough to trigger a zoom into
            // list mode
            self.scale = targetScale;
            [self.delegate isBeginningToScaleReallySmall:self];
        }else if((targetScale >= 1 && scaleDiff > kMinScaleDelta) ||
                 (targetScale < 1 && scaleDiff > kMinScaleDelta / 2)){
            //
            // TODO
            // only update the scale if its greater than a 1% difference of the previous
            // scale. the goal here is to optimize re-draws for the view, but this should be
            // validated when the full page contents are implemented.
            if(scale < targetScale && scale > targetScale - .05){
                self.scale = targetScale;
            }else if(scale < targetScale){
                scale += (targetScale - scale) / 5;
            }else if(scale > targetScale && scale < targetScale + .05){
                self.scale = targetScale;
            }else if(scale > targetScale){
                self.scale -= (scale - targetScale) / 5;
            }
//            self.scale = targetScale;
            if(didCancelSmallScale) [self.delegate cancelledScalingReallySmall:self];
        }
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
    CGPoint locationOfPinchAfterScale = CGPointMake(scale * normalizedLocationOfScale.x * superviewSize.width,
                                                    scale * normalizedLocationOfScale.y * superviewSize.height);
    CGSize newSizeOfView = CGSizeMake(superviewSize.width * scale, superviewSize.height * scale);

    
    //
    // now calculate our final frame given our pan and zoom
    CGRect fr = self.frame;
    fr.origin = CGPointMake(lastLocationInSuper.x - locationOfPinchAfterScale.x,
                            lastLocationInSuper.y - locationOfPinchAfterScale.y);
    fr.size = newSizeOfView;
    
    //
    // now, notify delegate that we're about to set the frame of the page during a gesture,
    // and give it a chance to modify the frame if at all needed.
    fr = [self.delegate isPanningAndScalingPage:self
                      fromFrame:frameOfPageAtBeginningOfGesture
                        toFrame:fr];
    
    if(panGesture.state != UIGestureRecognizerStateCancelled &&
       panGesture.state != UIGestureRecognizerStateEnded &&
       panGesture.state != UIGestureRecognizerStateFailed){
        //
        // now we're ready, set the frame!
        //
        // only set it if a delegate didn't change our state to
        // complete the gesture
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



#pragma mark - SLDrawingGestureRecognizerDelegate

-(void) drawArcAtStart:(CGPoint)point1 end:(CGPoint)point2 controlPoint1:(CGPoint)ctrl1 controlPoint2:(CGPoint)ctrl2 withFingerWidth:(CGFloat)fingerWidth fromView:(UIView *)view{
    [paintView drawArcAtStart:point1 end:point2 controlPoint1:ctrl1 controlPoint2:ctrl2 withFingerWidth:fingerWidth fromView:view];
}

-(void) drawDotAtPoint:(CGPoint)point withFingerWidth:(CGFloat)fingerWidth fromView:(UIView *)view{
    [paintView drawDotAtPoint:point withFingerWidth:fingerWidth fromView:view];
}

-(void) drawLineAtStart:(CGPoint)start end:(CGPoint)end withFingerWidth:(CGFloat)fingerWidth fromView:(UIView *)view{
    [paintView drawLineAtStart:start end:end withFingerWidth:fingerWidth fromView:view];
}

-(BOOL) fullyContainsArcAtStart:(CGPoint)point1 end:(CGPoint)point2 controlPoint1:(CGPoint)ctrl1 controlPoint2:(CGPoint)ctrl2 withFingerWidth:(CGFloat)fingerWidth fromView:(UIView *)view{
    return YES;
}

-(void) cancelStroke{
    [paintView cancelStroke];
}

-(void) commitStroke{
    [paintView commitStroke];
}


@end
