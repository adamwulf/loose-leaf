//
//  MMScrapPaperStackView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/29/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapPaperStackView.h"
#import "MMScrapContainerView.h"
#import "MMShakeScrapGestureRecognizer.h"
#import "MMScrapBubbleButton.h"
#import "MMScapBubbleContainerView.h"
#import "MMDebugDrawView.h"

@implementation MMScrapPaperStackView{
    MMScapBubbleContainerView* bezelScrapContainer;
    MMScrapContainerView* scrapContainer;
    // we get two gestures here, so that we can support
    // grabbing two scraps at the same time
    MMPanAndPinchScrapGestureRecognizer* panAndPinchScrapGesture;
    MMPanAndPinchScrapGestureRecognizer* panAndPinchScrapGesture2;
    MMShakeScrapGestureRecognizer* shakeScrapGesture;
}


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        scrapContainer = [[MMScrapContainerView alloc] initWithFrame:self.bounds];
        [self insertSubview:scrapContainer belowSubview:addPageSidebarButton];
        
        bezelScrapContainer = [[MMScapBubbleContainerView alloc] initWithFrame:self.bounds];
        bezelScrapContainer.delegate = self;
        [self insertSubview:bezelScrapContainer belowSubview:addPageSidebarButton];

        panAndPinchScrapGesture = [[MMPanAndPinchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(panAndScaleScrap:)];
        panAndPinchScrapGesture.bezelDirectionMask = MMBezelDirectionRight;
        panAndPinchScrapGesture.scrapDelegate = self;
        panAndPinchScrapGesture.cancelsTouchesInView = NO;
        [self addGestureRecognizer:panAndPinchScrapGesture];
        
//        shakeScrapGesture = [[MMShakeScrapGestureRecognizer alloc] initWithTarget:self action:@selector(shakeScrap:)];
//        [self addGestureRecognizer:shakeScrapGesture];
        
        panAndPinchScrapGesture2 = [[MMPanAndPinchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(panAndScaleScrap:)];
        panAndPinchScrapGesture2.bezelDirectionMask = MMBezelDirectionRight;
        panAndPinchScrapGesture2.scrapDelegate = self;
        panAndPinchScrapGesture2.cancelsTouchesInView = NO;
        [self addGestureRecognizer:panAndPinchScrapGesture2];
        
        
        // make sure sidebar buttons hide the scrap menu
        for(MMSidebarButton* possibleSidebarButton in self.subviews){
            if([possibleSidebarButton isKindOfClass:[MMSidebarButton class]]){
                [possibleSidebarButton addTarget:self action:@selector(anySidebarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        
//        UIButton* goButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        goButton.titleLabel.text = @"Go";
//        [goButton addTarget:self action:@selector(drawX) forControlEvents:UIControlEventTouchUpInside];
//        goButton.frame = CGRectMake(100, 100, 200, 60);
//        goButton.backgroundColor = [UIColor blueColor];
//        [self addSubview:goButton];
//        [self drawX];
    }
    return self;
}

-(void) drawX{
    [[[visibleStackHolder peekSubview].scraps objectAtIndex:0] drawX];
}

#pragma mark - Add Page

-(void) addPageButtonTapped:(UIButton*)_button{
    [self forceScrapToScrapContainerDuringGesture];
    [super addPageButtonTapped:_button];
}

-(void) anySidebarButtonTapped:(id)button{
    [bezelScrapContainer hideMenuIfNeeded];
}

#pragma mark - MMPencilAndPaletteViewDelegate

-(void) penTapped:(UIButton*)_button{
    [super penTapped:_button];
    [self anySidebarButtonTapped:nil];
}

-(void) colorMenuToggled{
    [super colorMenuToggled];
    [self anySidebarButtonTapped:nil];
}

-(void) didChangeColorTo:(UIColor*)color{
    [super didChangeColorTo:color];
    [self anySidebarButtonTapped:nil];
}

#pragma mark - Bezel Gestures

-(void) forceScrapToScrapContainerDuringGesture{
    if(panAndPinchScrapGesture.scrap){
        if(![scrapContainer.subviews containsObject:panAndPinchScrapGesture.scrap]){
            [scrapContainer addSubview:panAndPinchScrapGesture.scrap];
            [self panAndScaleScrap:panAndPinchScrapGesture];
        }
    }
    if(panAndPinchScrapGesture2.scrap){
        if(![scrapContainer.subviews containsObject:panAndPinchScrapGesture2.scrap]){
            [scrapContainer addSubview:panAndPinchScrapGesture2.scrap];
            [self panAndScaleScrap:panAndPinchScrapGesture2];
        }
    }
}

-(void) isBezelingInLeftWithGesture:(MMBezelInLeftGestureRecognizer*)bezelGesture{
    [super isBezelingInLeftWithGesture:bezelGesture];
    [self forceScrapToScrapContainerDuringGesture];
}

-(void) isBezelingInRightWithGesture:(MMBezelInRightGestureRecognizer *)bezelGesture{
    [super isBezelingInRightWithGesture:bezelGesture];
    [self forceScrapToScrapContainerDuringGesture];
}


#pragma mark - Panning Scraps

-(void) panAndScaleScrap:(MMPanAndPinchScrapGestureRecognizer*)_panGesture{
    MMPanAndPinchScrapGestureRecognizer* gesture = (MMPanAndPinchScrapGestureRecognizer*)_panGesture;
    
    //
    // when a gesture begins, I need to store its
    // pregesture scale + location in the /scrapContainer/
    // when as the gesture scales or moves, we'll convert
    // these coordinates back to the page coordinate space
    // if the scrap is still inside the page. otherwise
    // we'll just use the scrapContainer properties directly
    //
    // gesture.shouldReset is a flag for when the gesture will
    // re-begin it's state w/o triggering a UIGestureRecognizerStateBegan
    // since the state can only change between certain values
    BOOL didReset = NO;
    if(gesture.shouldReset){
        gesture.shouldReset = NO;
        didReset = YES;
        gesture.preGestureScale = gesture.scrap.scale;
        gesture.preGestureRotation = gesture.scrap.rotation;
        CGFloat pageScale = [visibleStackHolder peekSubview].scale;
        gesture.preGesturePageScale = pageScale;
        CGPoint centerInPage = _panGesture.scrap.center;
        centerInPage = CGPointApplyAffineTransform(centerInPage, CGAffineTransformMakeScale(pageScale, pageScale));
        gesture.preGestureCenter = [[visibleStackHolder peekSubview] convertPoint:centerInPage toView:scrapContainer];
    }
    
    if(gesture.scrap){
        // handle the scrap.
        //
        // if the scrap is hovering over the page that it
        // originated from, then make sure to keep it
        // inside that page so that picking up a scrap
        // doesn't change the order of the scrap in the page

        //
        // first step:
        // find the center, scale, and rotation for the scrap
        // independent of any page
        MMScrapView* scrap = gesture.scrap;
        scrap.center = CGPointMake(gesture.translation.x + gesture.preGestureCenter.x,
                                   gesture.translation.y + gesture.preGestureCenter.y);
        scrap.scale = gesture.preGestureScale * gesture.scale * gesture.preGesturePageScale;
        scrap.rotation = gesture.rotation + gesture.preGestureRotation;

        //
        // now determine if it should be inside of a page,
        // and what the page specific center and scale should be
        CGFloat scrapScaleInPage;
        CGPoint scrapCenterInPage;
        MMScrappedPaperView* pageToDropScrap = [self pageWouldDropScrap:gesture.scrap atCenter:&scrapCenterInPage andScale:&scrapScaleInPage];
        if(![pageToDropScrap isEqual:[visibleStackHolder peekSubview]]){
            // if the page it should drop isn't the top visible page,
            // then add it to the scrap container view.
            if(![scrapContainer.subviews containsObject:scrap]){
                // just keep it in the scrap container
                [scrapContainer addSubview:scrap];
            }
        }else if(pageToDropScrap && [pageToDropScrap hasScrap:scrap]){
            // only adjust for the page if the page
            // already has the scrap. otherwise we'll keep
            // the scrap in the container view and only drop
            // it onto a page once the gesture is complete.
            gesture.scrap.scale = scrapScaleInPage;
            gesture.scrap.center = scrapCenterInPage;
        }
        [self isBeginning:gesture.state == UIGestureRecognizerStateBegan toPanAndScaleScrap:gesture.scrap withTouches:gesture.touches];
    }
    
    MMScrapView* scrapViewIfFinished = nil;
    
    BOOL shouldBezel = NO;
    if(gesture.scrap && didReset){
        // glow blue
        gesture.scrap.selected = YES;
    }else if(gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateCancelled){
        // turn off glow
        gesture.scrap.selected = NO;
        
        //
        // notes for dropping scraps:
        //
        // Since the "center" of a scrap is changed to the gesture
        // location, I only need to check if the scrap center
        // is inside of a page, and make sure to add the scrap
        // to that page.
        
        if(gesture.didExitToBezel){
            shouldBezel = YES;
        }else if([scrapContainer.subviews containsObject:gesture.scrap]){
            if(gesture.state == UIGestureRecognizerStateCancelled){
                // bezel
                shouldBezel = YES;
            }else{
                CGFloat scrapScaleInPage;
                CGPoint scrapCenterInPage;
                MMScrappedPaperView* pageToDropScrap = [self pageWouldDropScrap:gesture.scrap atCenter:&scrapCenterInPage andScale:&scrapScaleInPage];
                if(pageToDropScrap){
                    [pageToDropScrap addScrap:gesture.scrap];
                    gesture.scrap.scale = scrapScaleInPage;
                    gesture.scrap.center = scrapCenterInPage;
                }else{
                    // couldn't find a page to catch it
                    shouldBezel = YES;
                }
            }
        }
        
        scrapViewIfFinished = gesture.scrap;
    }
    if(gesture.scrap && (gesture.state == UIGestureRecognizerStateEnded ||
                         gesture.state == UIGestureRecognizerStateFailed ||
                         gesture.state == UIGestureRecognizerStateCancelled)){
        // after possibly rotating the scrap, we need to reset it's anchor point
        // and position, so that we can consistently determine it's position with
        // the center property
        
        
        // giving up the scrap will make sure
        // its anchor point is back in the true
        // center of the scrap. It'll also
        // nil out the scrap in the gesture, so
        // hang onto it
        MMScrapView* scrap = gesture.scrap;
        [gesture giveUpScrap];
        
        if(shouldBezel){
            // if we've bezelled the scrap,
            // add it to the bezel container
            [bezelScrapContainer addScrapToBezelSidebarAnimated:scrap];
        }
    }
    if(scrapViewIfFinished){
        [self finishedPanningAndScalingScrap:scrapViewIfFinished];
    }
}


/**
 * this method will return the page that could contain the scrap
 * given it's current position on the screen and the pages' postions
 * on the screen.
 *
 * it will return the page that should "catch" the scrap, and the
 * center/scale for the scrap on that page
 *
 * if no page could catch it, this will return nil
 */
-(MMScrappedPaperView*) pageWouldDropScrap:(MMScrapView*)scrap atCenter:(CGPoint*)scrapCenterInPage andScale:(CGFloat*)scrapScaleInPage{
    MMScrappedPaperView* pageToDropScrap = nil;
    CGRect pageBounds;
    //
    // we want to be able to drop scraps
    // onto any page in the visible or bezel stack
    //
    // since the bezel pages are "above" the visible stack,
    // we should check them first
    //
    // these pages are in reverse order, so the last object in the
    // array is the top most visible page.
    
    //
    // I used to just create an NSMutableArray that contained the
    // combined visible and bezel stacks of subviews. but that was
    // fairly resource intensive for a method that needs to be extremely
    // quick.
    //
    // instead of an NSMutableArray, i create a C array pointing to
    // the arrays we already have. then our do:while loop will walk
    // backwards on the 2nd array, then walk backwards on the first
    // array until a page is found.
    NSArray* arrayOfArrayOfViews[2];
    arrayOfArrayOfViews[0] = visibleStackHolder.subviews;
    arrayOfArrayOfViews[1] = bezelStackHolder.subviews;
    int arrayNum = 1;
    int indexNum = [bezelStackHolder.subviews count] - 1;

    do{
        if(indexNum < 0){
            // if our index is less than zero, then we haven't been able
            // to find a page in our current array. move to the next array
            // of views further back in the view, and start checking those
            arrayNum -= 1;
            if(arrayNum == -1){
                // failsafe.
                // this may happen if the user picks up two scraps with system gestures turned on.
                // the system may exit our app, leaving us in an unknown state
                return [visibleStackHolder peekSubview];
            }
            indexNum = [(arrayOfArrayOfViews[arrayNum]) count] - 1;
        }
        // fetch the most visible page
        pageToDropScrap = [(arrayOfArrayOfViews[arrayNum]) objectAtIndex:indexNum];
        if(!pageToDropScrap){
            // if we can't find a page, we're done
            break;
        }
        CGFloat pageScale = pageToDropScrap.scale;
        CGAffineTransform reverseScaleTransform = CGAffineTransformMakeScale(1/pageScale, 1/pageScale);
        *scrapScaleInPage = scrap.scale;
        *scrapCenterInPage = scrap.center;
        *scrapScaleInPage = *scrapScaleInPage / pageScale;
        *scrapCenterInPage = [pageToDropScrap convertPoint:*scrapCenterInPage fromView:scrapContainer];
        *scrapCenterInPage = CGPointApplyAffineTransform(*scrapCenterInPage, reverseScaleTransform);
        // bounds respects the transform, so we need to scale the
        // bounds of the page too to see if the scrap is landing inside
        // of it
        pageBounds = pageToDropScrap.bounds;
        pageBounds = CGRectApplyAffineTransform(pageBounds, reverseScaleTransform);

//        if(CGRectContainsPoint(pageBounds, scrapCenterInPage)){
//            NSLog(@"page %@ contains scrap center", pageToDropScrap.uuid);
//        }
        indexNum -= 1;
    }while(!CGRectContainsPoint(pageBounds, *scrapCenterInPage));
    
    return pageToDropScrap;
}

#pragma mark - Shake Scraps

-(void) shakeScrap:(MMShakeScrapGestureRecognizer*)gesture{
    // noop for now
}



#pragma mark - MMPanAndPinchScrapGestureRecognizerDelegate

-(NSArray*) scraps{
    return [[visibleStackHolder peekSubview] scraps];
}

-(BOOL) panScrapRequiresLongPress{
    return rulerButton.selected;
}


#pragma mark - MMPaperViewDelegate

-(CGRect) isBeginning:(BOOL)beginning toPanAndScalePage:(MMPaperView *)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame withTouches:(NSArray*)touches{
    CGRect ret = [super isBeginning:beginning toPanAndScalePage:page fromFrame:fromFrame toFrame:toFrame withTouches:touches];
    if(panAndPinchScrapGesture.state == UIGestureRecognizerStateBegan){
        panAndPinchScrapGesture.state = UIGestureRecognizerStateChanged;
    }
    if(panAndPinchScrapGesture2.state == UIGestureRecognizerStateBegan){
        panAndPinchScrapGesture2.state = UIGestureRecognizerStateChanged;
    }
    [self panAndScaleScrap:panAndPinchScrapGesture];
    [self panAndScaleScrap:panAndPinchScrapGesture2];

    return ret;
}

-(void) setButtonsVisible:(BOOL)visible{
    [UIView animateWithDuration:.3 animations:^{
        bezelScrapContainer.alpha = visible ? 1 : 0;
    }];
    [super setButtonsVisible:visible];
}


-(void) isBeginning:(BOOL)isBeginningGesture toPanAndScaleScrap:(MMScrapView*)scrap withTouches:(NSArray*)touches{
    // our gesture has began, so make sure to kill
    // any touches that are being used to draw
    //
    // the stroke manager is the definitive source for all strokes.
    // cancel through that manager, and it'll notify the appropriate
    // view if need be
    for(UITouch* touch in touches){
        [[JotStrokeManager sharedInstace] cancelStrokeForTouch:touch];
        [polygon cancelPolygonForTouch:touch];
    }
}

-(void) finishedPanningAndScalingScrap:(MMScrapView*)scrap{
    // save page if we're not holding any scraps
    if(!panAndPinchScrapGesture.scrap && !panAndPinchScrapGesture2.scrap){
           [[visibleStackHolder peekSubview] saveToDisk];
    }
}

-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture{
    if([gesture isKindOfClass:[MMPanAndPinchScrapGestureRecognizer class]]){
        // only notify of our own gestures
        [[visibleStackHolder peekSubview] ownershipOfTouches:touches isGesture:gesture];
    }
    [panAndPinchScrapGesture ownershipOfTouches:touches isGesture:gesture];
    [panAndPinchScrapGesture2 ownershipOfTouches:touches isGesture:gesture];
}

-(void) didLongPressPage:(MMPaperView*)page withTouches:(NSSet*)touches{
    // if we're in ruler mode, then
    // let the pan scrap gestures know that they can move the scrap
    if([self panScrapRequiresLongPress]){
        //
        // if a long press happens, give the touches to
        // whichever scrap pan gesture doesn't have a scrap
        if(!panAndPinchScrapGesture.scrap){
            [panAndPinchScrapGesture blessTouches:touches];
        }else{
            [panAndPinchScrapGesture2 blessTouches:touches];
        }
    }
}


#pragma mark - Rotation

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading andX:(CGFloat)xAccel andY:(CGFloat)yAccel andZ:(CGFloat)zAccel{
    [super didUpdateAccelerometerWithReading:currentRawReading];
    [bezelScrapContainer didUpdateAccelerometerWithRawReading:currentRawReading andX:xAccel andY:yAccel andZ:zAccel];
}

#pragma mark - MMScapBubbleContainerViewDelegate

-(void) didAddScrapToBezelSidebar:(MMScrapView *)scrap{
    // noop
}

-(void) didAddScrapBackToPage:(MMScrapView *)scrap{
    // first, find the page to add the scrap to.
    // this will check visible + bezelled pages to see
    // which page should get the scrap, and it'll tell us
    // the center/scale to use
    CGPoint center;
    CGFloat scale;
    MMScrappedPaperView* page = [self pageWouldDropScrap:scrap atCenter:&center andScale:&scale];

    // ok, done, just set it
    [page addScrap:scrap];
    scrap.center = center;
    scrap.scale = scale;
}

-(CGPoint) positionOnScreenToScaleScrapTo:(MMScrapView*)scrap{
    return [visibleStackHolder center];
}

-(CGFloat) scaleOnScreenToScaleScrapTo:(MMScrapView*)scrap givenOriginalScale:(CGFloat)originalScale{
    return originalScale * [visibleStackHolder peekSubview].scale;
}



#pragma mark - List View

-(void) finishedScalingReallySmall:(MMPaperView *)page{
    if(panAndPinchScrapGesture.scrap){
        [panAndPinchScrapGesture cancel];
    }
    if(panAndPinchScrapGesture2.scrap){
        [panAndPinchScrapGesture2 cancel];
    }
    [super finishedScalingReallySmall:page];
}

@end
