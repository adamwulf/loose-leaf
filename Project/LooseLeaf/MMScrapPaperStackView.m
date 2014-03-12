//
//  MMScrapPaperStackView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/29/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapPaperStackView.h"
#import "MMScrapContainerView.h"
#import "MMScrapBubbleButton.h"
#import "MMScrapBubbleContainerView.h"
#import "MMDebugDrawView.h"
#import "MMTouchVelocityGestureRecognizer.h"
#import "MMStretchScrapGestureRecognizer.h"
#import <JotUI/AbstractBezierPathElement-Protected.h>

@implementation MMScrapPaperStackView{
    MMScrapBubbleContainerView* bezelScrapContainer;
    MMScrapContainerView* scrapContainer;
    // we get two gestures here, so that we can support
    // grabbing two scraps at the same time
    MMPanAndPinchScrapGestureRecognizer* panAndPinchScrapGesture;
    MMPanAndPinchScrapGestureRecognizer* panAndPinchScrapGesture2;
    MMStretchScrapGestureRecognizer* stretchScrapGesture;

    // this is the initial transform of a scrap
    // before it's started to be stretched.
    CATransform3D startSkewTransform;
    
    NSTimer* debugTimer;
    NSTimer* drawTimer;
}


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        
        debugTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                                  target:self
                                                                selector:@selector(timerDidFire:)
                                                                userInfo:nil
                                                                 repeats:YES];

        
//        drawTimer = [NSTimer scheduledTimerWithTimeInterval:.5
//                                                      target:self
//                                                    selector:@selector(drawTimerDidFire:)
//                                                    userInfo:nil
//                                                     repeats:YES];

        
        scrapContainer = [[MMScrapContainerView alloc] initWithFrame:self.bounds];
        [self insertSubview:scrapContainer belowSubview:addPageSidebarButton];
        
        bezelScrapContainer = [[MMScrapBubbleContainerView alloc] initWithFrame:self.bounds];
        bezelScrapContainer.delegate = self;
        [self insertSubview:bezelScrapContainer belowSubview:addPageSidebarButton];

        panAndPinchScrapGesture = [[MMPanAndPinchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(panAndScaleScrap:)];
        panAndPinchScrapGesture.bezelDirectionMask = MMBezelDirectionRight;
        panAndPinchScrapGesture.scrapDelegate = self;
        panAndPinchScrapGesture.cancelsTouchesInView = NO;
        panAndPinchScrapGesture.delegate = self;
        [self addGestureRecognizer:panAndPinchScrapGesture];
        
        panAndPinchScrapGesture2 = [[MMPanAndPinchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(panAndScaleScrap:)];
        panAndPinchScrapGesture2.bezelDirectionMask = MMBezelDirectionRight;
        panAndPinchScrapGesture2.scrapDelegate = self;
        panAndPinchScrapGesture2.cancelsTouchesInView = NO;
        panAndPinchScrapGesture2.delegate = self;
        [self addGestureRecognizer:panAndPinchScrapGesture2];
        
        stretchScrapGesture = [[MMStretchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(stretchGesture:)];
        stretchScrapGesture.scrapDelegate = self;
        stretchScrapGesture.pinchScrapGesture1 = panAndPinchScrapGesture;
        stretchScrapGesture.pinchScrapGesture2 = panAndPinchScrapGesture2;
        stretchScrapGesture.delegate = self;
        [self addGestureRecognizer:stretchScrapGesture];
        
        // make sure sidebar buttons hide the scrap menu
        for(MMSidebarButton* possibleSidebarButton in self.subviews){
            if([possibleSidebarButton isKindOfClass:[MMSidebarButton class]]){
                [possibleSidebarButton addTarget:self action:@selector(anySidebarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    
//        UIButton* drawLongElementButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 200, 60)];
//        [drawLongElementButton addTarget:self action:@selector(drawLine) forControlEvents:UIControlEventTouchUpInside];
//        [drawLongElementButton setTitle:@"Draw Line" forState:UIControlStateNormal];
//        drawLongElementButton.backgroundColor = [UIColor whiteColor];
//        drawLongElementButton.layer.borderColor = [UIColor blackColor].CGColor;
//        drawLongElementButton.layer.borderWidth = 1;
//        [self addSubview:drawLongElementButton];
    }
    return self;
}


static int numLines = 0;
BOOL skipOnce = NO;
int skipAll = NO;

-(void) drawTimerDidFire:(NSTimer*)timer{
    if(skipOnce){
        skipOnce = NO;
        return;
    }
    
    MMEditablePaperView* page = [visibleStackHolder peekSubview];
    
    MoveToPathElement* moveTo = [MoveToPathElement elementWithMoveTo:CGPointMake(rand() % (int) page.bounds.size.width, rand() % (int) page.bounds.size.height)];
    moveTo.width = 3;
    moveTo.color = [UIColor blackColor];
    
    CurveToPathElement* curveTo = [CurveToPathElement elementWithStart:moveTo.startPoint
                                                             andLineTo:CGPointMake(rand() % (int) page.bounds.size.width, rand() % (int) page.bounds.size.height)];
    curveTo.width = 3;
    curveTo.color = [UIColor blackColor];
    
    NSArray* shortLine = [NSArray arrayWithObjects:
                          moveTo,
                          curveTo,
                          nil];
    
    [page.drawableView addElements:shortLine];
    
    [page saveToDisk];
    
    numLines++;
    
    
    CGFloat strokesPerPage = 15;
    
    if(numLines % (int)strokesPerPage == 12){
        [[visibleStackHolder peekSubview] completeScissorsCutWithPath:[UIBezierPath bezierPathWithRect:CGRectMake(300, 300, 200, 200)]];
    }
    if(numLines % (int)strokesPerPage == 0){
        [self addPageButtonTapped:nil];
        skipOnce = YES;
    }
    
    NSLog(@"auto-lines: %d   pages: %d", numLines, (int) floor(numLines / strokesPerPage));
}


-(void) timerDidFire:(NSTimer*)timer{

    NSLog(@" ");
    NSLog(@" ");
    NSLog(@" ");
    NSLog(@"begin");
    
    NSLog(@"page being panned %d", [setOfPagesBeingPanned count]);
    for(MMPaperView* page in setOfPagesBeingPanned){
        if([visibleStackHolder containsSubview:page]){
            NSLog(@"  1 page in visible stack");
        }else if([bezelStackHolder containsSubview:page]){
            NSLog(@"  1 page in bezel stack");
        }else if([hiddenStackHolder containsSubview:page]){
            NSLog(@"  1 page in hidden stack");
        }
    }
    

    for(UIGestureRecognizer* gesture in self.gestureRecognizers){
        UIGestureRecognizerState st = gesture.state;
        NSLog(@"%@ %d", NSStringFromClass([gesture class]), st);
        if([gesture respondsToSelector:@selector(validTouches)]){
            NSLog(@"   validTouches: %d", [[gesture performSelector:@selector(validTouches)] count]);
        }
        if([gesture respondsToSelector:@selector(touches)]){
            NSLog(@"   touches: %d", [[gesture performSelector:@selector(touches)] count]);
        }
        if([gesture respondsToSelector:@selector(possibleTouches)]){
            NSLog(@"   possibleTouches: %d", [[gesture performSelector:@selector(possibleTouches)] count]);
        }
        if([gesture respondsToSelector:@selector(ignoredTouches)]){
            NSLog(@"   ignoredTouches: %d", [[gesture performSelector:@selector(ignoredTouches)] count]);
        }
    }
    NSLog(@"velocity gesture sees: %d", [[MMTouchVelocityGestureRecognizer sharedInstace] numberOfActiveTouches]);
    
    NSLog(@"done");
}

-(void) drawLine{
    NSLog(@"drawing");
    [[[visibleStackHolder peekSubview] drawableView] drawLongLine];
    
}

#pragma mark - Add Page

-(void) addPageButtonTapped:(UIButton*)_button{
    NSLog(@"Add Button Tapped");
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
    [self ownershipOfTouches:[NSSet setWithArray:bezelGesture.touches] isGesture:bezelGesture];
    [super isBezelingInLeftWithGesture:bezelGesture];
    [self forceScrapToScrapContainerDuringGesture];
}

-(void) isBezelingInRightWithGesture:(MMBezelInRightGestureRecognizer *)bezelGesture{
    [self ownershipOfTouches:[NSSet setWithArray:bezelGesture.touches] isGesture:bezelGesture];
    [super isBezelingInRightWithGesture:bezelGesture];
    [self forceScrapToScrapContainerDuringGesture];
}


#pragma mark - Panning Scraps

-(void) panAndScaleScrap:(MMPanAndPinchScrapGestureRecognizer*)_panGesture{
    MMPanAndPinchScrapGestureRecognizer* gesture = (MMPanAndPinchScrapGestureRecognizer*)_panGesture;

    if(_panGesture.paused){
        return;
    }
    // TODO:
    // the first time the gesture comes back unpaused,
    // we need to make sure the scrap is in the correct place

    //
    BOOL didReset = NO;
    if(gesture.shouldReset){
        gesture.shouldReset = NO;
        didReset = YES;
    }
    
    if(gesture.scrap && (gesture.scrap != stretchScrapGesture.scrap)){
        
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
        
        if(gesture.isShaking){
            // if the gesture is shaking, then pull the scrap to the top if
            // it's not already. otherwise send it to the back
            if([pageToDropScrap isEqual:[visibleStackHolder peekSubview]] &&
               ![pageToDropScrap hasScrap:scrap]){
                [pageToDropScrap addScrap:scrap];
                [gesture.scrap.superview insertSubview:gesture.scrap atIndex:0];
            }else if(gesture.scrap == [gesture.scrap.superview.subviews lastObject]){
                [gesture.scrap.superview insertSubview:gesture.scrap atIndex:0];
            }else{
                [gesture.scrap.superview addSubview:gesture.scrap];
            }
        }
        
        
        [self isBeginning:gesture.state == UIGestureRecognizerStateBegan toPanAndScaleScrap:gesture.scrap withTouches:gesture.validTouches];
    }
    
    MMScrapView* scrapViewIfFinished = nil;
    
    BOOL shouldBezel = NO;
    if(gesture.scrap && didReset){
        // glow blue
        gesture.scrap.selected = YES;
    }else if(gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateCancelled){
        // turn off glow
        if(!stretchScrapGesture.scrap){
            // only if that scrap isn't being stretched
            gesture.scrap.selected = NO;
        }
        
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
            CGFloat scrapScaleInPage;
            CGPoint scrapCenterInPage;
            MMScrappedPaperView* pageToDropScrap;
            if(gesture.state == UIGestureRecognizerStateCancelled){
                pageToDropScrap = [visibleStackHolder peekSubview];
                [self scaledCenter:&scrapCenterInPage andScale:&scrapScaleInPage forScrap:gesture.scrap onPage:pageToDropScrap];
            }else{
                pageToDropScrap = [self pageWouldDropScrap:gesture.scrap atCenter:&scrapCenterInPage andScale:&scrapScaleInPage];
            }
            if(pageToDropScrap){
                [pageToDropScrap addScrap:gesture.scrap];
                gesture.scrap.scale = scrapScaleInPage;
                gesture.scrap.center = scrapCenterInPage;
            }else{
                // couldn't find a page to catch it
                shouldBezel = YES;
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
            [bezelScrapContainer addScrapToBezelSidebar:scrap animated:YES];
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
        [self scaledCenter:scrapCenterInPage andScale:scrapScaleInPage forScrap:scrap onPage:pageToDropScrap];
        // bounds respects the transform, so we need to scale the
        // bounds of the page too to see if the scrap is landing inside
        // of it
        pageBounds = pageToDropScrap.bounds;
        CGFloat pageScale = pageToDropScrap.scale;
        CGAffineTransform reverseScaleTransform = CGAffineTransformMakeScale(1/pageScale, 1/pageScale);
        pageBounds = CGRectApplyAffineTransform(pageBounds, reverseScaleTransform);

//        if(CGRectContainsPoint(pageBounds, scrapCenterInPage)){
//            NSLog(@"page %@ contains scrap center", pageToDropScrap.uuid);
//        }
        indexNum -= 1;
    }while(!CGRectContainsPoint(pageBounds, *scrapCenterInPage));
    
    return pageToDropScrap;
}

-(void) scaledCenter:(CGPoint*)scrapCenterInPage andScale:(CGFloat*)scrapScaleInPage forScrap:(MMScrapView*)scrap onPage:(MMScrappedPaperView*)pageToDropScrap{
    CGFloat pageScale = pageToDropScrap.scale;
    CGAffineTransform reverseScaleTransform = CGAffineTransformMakeScale(1/pageScale, 1/pageScale);
    *scrapScaleInPage = scrap.scale;
    *scrapCenterInPage = scrap.center;
    *scrapScaleInPage = *scrapScaleInPage / pageScale;
    *scrapCenterInPage = [pageToDropScrap convertPoint:*scrapCenterInPage fromView:scrapContainer];
    *scrapCenterInPage = CGPointApplyAffineTransform(*scrapCenterInPage, reverseScaleTransform);
}

#pragma mark - MMStretchScrapGestureRecognizer

-(void) stretchGesture:(MMStretchScrapGestureRecognizer*)gesture{
    if(gesture.scrap){
        if(!CGPointEqualToPoint(gesture.scrap.layer.anchorPoint, CGPointZero)){
            // the anchor point can get reset by the pan/pinch gesture ending,
            // so we need to force it back to our 0,0 for the stretch
            // TODO: handle the pan gesture during stetch better
            [UIView setAnchorPoint:CGPointMake(0, 0) forView:gesture.scrap];
        }
        [self isBeginning:gesture.state == UIGestureRecognizerStateBegan toPanAndScaleScrap:gesture.scrap withTouches:gesture.validTouches];
        // generate the actual transform between the two quads
        gesture.scrap.layer.transform = CATransform3DConcat(startSkewTransform, [gesture skewTransform]);
    }
}



CGPoint scrapAnchorAtStretchStart;
CGPoint scrapLocationAtStretchStart;
CGPoint scrapLocationAtStretchEnd;

CGPoint gestureLocationAtStretchStart;
CGPoint gestureLocationAtStretchEnd;

CGPoint scrapLocationAfterAnimation;
CGPoint gestureLocationAfterAnimation;

-(CGPoint) beginStretchForScrap:(MMScrapView*)scrap{
    
    // when a scrap is beginning to be stretched, we need to
    // track it's anchor point before we begin the stretch.
    // this will be the anchor of the pan gesture.
    // TODO: what happens if i grab this scrap with 4 fingers immediately
    // the scrap.center will be calcualted based on this
    // gesture specific anchor point
    scrapAnchorAtStretchStart = scrap.layer.anchorPoint;
    
    // to calculate the initial position and transform we
    // need to have the anchor in the center
    MMPanAndPinchScrapGestureRecognizer* gesture = panAndPinchScrapGesture.scrap == scrap ? panAndPinchScrapGesture : panAndPinchScrapGesture2;
    scrapLocationAtStretchStart = scrap.center;
    gestureLocationAtStretchStart = CGPointMake(gesture.translation.x + gesture.preGestureCenter.x,
                                                gesture.translation.y + gesture.preGestureCenter.y);
    
    
    // now, for our stretch gesture, we need the anchor point
    // to be at the 0,0 point of the scrap so that the transform
    // works properly to stretch the scrap.
    [UIView setAnchorPoint:CGPointMake(0, 0) forView:scrap];
    // the user has just now begun to hold a scrap
    // with four fingers and is stretching it.
    // set the anchor point to 0,0 for the skew transform
    // and keep our initial scale/rotate transform so
    // we can animate back to it when we're done
    scrap.selected = YES;
    startSkewTransform = scrap.layer.transform;
    //
    // keep the pan gestures alive, just pause them from
    // updating until after the stretch gesture so we can
    // handoff the newly stretched/moved/adjusted scrap
    // seemlessly
    [panAndPinchScrapGesture pause];
    [panAndPinchScrapGesture2 pause];
    return [scrap convertPoint:scrap.bounds.origin toView:visibleStackHolder];
}

-(void) endStretchForScrap:(MMScrapView*)scrap{
    // now that the scrap has finished a stretch, we can recalculate
    // where the center is for it's currently stretched out state.
    // these values will help inform us to build a new transform that
    // we'll use to bounce animate the scrap into position.
    [UIView setAnchorPoint:scrapAnchorAtStretchStart forView:scrap];
    MMPanAndPinchScrapGestureRecognizer* gesture = panAndPinchScrapGesture.scrap == scrap ? panAndPinchScrapGesture : panAndPinchScrapGesture2;
    scrapLocationAtStretchEnd = scrap.center;
    gestureLocationAtStretchEnd = CGPointMake(gesture.translation.x + gesture.preGestureCenter.x,
                                                gesture.translation.y + gesture.preGestureCenter.y);
    
    // now that we've calcualted the current position for our
    // reference anchor point, we should now adjust our anchor
    // back to 0,0 during the next transforms to bounce
    // the scrap back to its new place.
    [UIView setAnchorPoint:CGPointMake(0, 0) forView:scrap];

    
    // kill the blue highlight
    // TODO: don't kill highlight if its going to be held
    // by a pan scrap gesture
    scrap.selected = NO;
    
    // these calculations help us determine a bounce scale that'll keep
    // the bounce to 10px on every side of the scrap (20px total)
    CGFloat maxDim = MAX(scrap.bounds.size.width, scrap.bounds.size.height);
    CGFloat smallScale = maxDim > 200 ? (maxDim - 20) / maxDim : .9;
    CGFloat largeScale = maxDim > 200 ? (maxDim + 20) / maxDim : 1.1;
    
    // these two transforms will be used to
    // bounce the scrap back to its initial position
    // TODO: since these transforms run with the anchor set to 0,0,
    // the bounce isn't centered in the scrap. an alternative would be to
    // use the firstQ to generate new scaled Quads and create transforms
    // from those instead of trying to scale the initial unstretched transform.
    CATransform3D smallTransform = CATransform3DConcat(startSkewTransform, CATransform3DMakeScale(smallScale, smallScale, 1));
    CATransform3D largeTransform = CATransform3DConcat(startSkewTransform, CATransform3DMakeScale(largeScale, largeScale, 1));
    
    // i need to keep the anchor point at 0,0 during
    // the transition back to the normal scale/rotate
    // transform. after that i can recenter it and then
    // complete the bounce.
    //
    // TODO: get figure out how to animate the scrap
    // into the new position to hand it off to the
    // pinch gesture
    [UIView animateWithDuration:.2 animations:^{
        scrap.layer.transform = smallTransform;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:.1 animations:^{
            scrap.layer.transform = largeTransform;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:.1 animations:^{
                scrap.layer.transform = startSkewTransform;
            } completion:^(BOOL finished){
                // reset the anchor point to the scrap pan gesture's anchor
                [UIView setAnchorPoint:scrapAnchorAtStretchStart forView:scrap];
                
                // calcualte our scrap center. for now, this will be the
                // exact center that the scrap was at before we started
                // to stretch it.
                // TODO: this center should be the new location of the pan
                // gesture so that the scrap is handed off seemlessly.
                // i'll need to handle what happens if the gesture has moved during
                // animation. perhaps i should calculate a new anchorpoint
                // etc for the gesture so that any gesture movement would
                // "stick" only after the animation is complete.
                scrapLocationAfterAnimation = scrap.center;
                gestureLocationAfterAnimation = CGPointMake(gesture.translation.x + gesture.preGestureCenter.x,
                                                          gesture.translation.y + gesture.preGestureCenter.y);
                
                NSLog(@"scrapAnchorAtStretchStart: %f %f", scrapAnchorAtStretchStart.x, scrapAnchorAtStretchStart.y);
                NSLog(@"scrapLocationAtStretchStart:   %f %f", scrapLocationAtStretchStart.x, scrapLocationAtStretchStart.y);
                NSLog(@"scrapLocationAtStretchEnd:     %f %f", scrapLocationAtStretchEnd.x, scrapLocationAtStretchEnd.y);
                NSLog(@"scrapLocationAfterAnimation:   %f %f", scrapLocationAfterAnimation.x, scrapLocationAfterAnimation.y);
                NSLog(@"gestureLocationAtStretchStart: %f %f", gestureLocationAtStretchStart.x, gestureLocationAtStretchStart.y);
                NSLog(@"gestureLocationAtStretchEnd:   %f %f", gestureLocationAtStretchEnd.x, gestureLocationAtStretchEnd.y);
                NSLog(@"gestureLocationAfterAnimation: %f %f", gestureLocationAfterAnimation.x, gestureLocationAfterAnimation.y);
                
                NSLog(@"beginning pinch again");
                [panAndPinchScrapGesture begin];
                [panAndPinchScrapGesture2 begin];
            }];
        }];
    }];
}


#pragma mark - MMPanAndPinchScrapGestureRecognizerDelegate

-(NSArray*) scraps{
    return [[visibleStackHolder peekSubview] scraps];
}

-(BOOL) panScrapRequiresLongPress{
    return rulerButton.selected;
}

-(CGFloat) topVisiblePageScale{
    return [visibleStackHolder peekSubview].scale;
}

-(CGPoint) convertScrapCenterToScrapContainerCoordinate:(CGPoint)scrapCenter{
    CGFloat pageScale = [self topVisiblePageScale];
    // because the page uses a transform to scale itself, the scrap center will always
    // be in page scale = 1.0 form. if the user picks up a scrap while also scaling the page,
    // then we need to transform that coordinate into the visible scale of the zoomed page.
    scrapCenter = CGPointApplyAffineTransform(scrapCenter, CGAffineTransformMakeScale(pageScale, pageScale));
    // now that the coordinate is in the visible scale, we can convert that directly to the
    // scapContainer's coodinate system
    return [[visibleStackHolder peekSubview] convertPoint:scrapCenter toView:scrapContainer];
}


#pragma mark - MMPaperViewDelegate

-(CGRect) isBeginning:(BOOL)beginning toPanAndScalePage:(MMPaperView *)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame withTouches:(NSArray*)touches{
    if(beginning){
        NSLog(@"panning page");
    }
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
        [scissor cancelPolygonForTouch:touch];
    }
}

-(void) finishedPanningAndScalingScrap:(MMScrapView*)scrap{
    // save page if we're not holding any scraps
    if(!panAndPinchScrapGesture.scrap && !panAndPinchScrapGesture2.scrap && !stretchScrapGesture.scrap){
        [[visibleStackHolder peekSubview] saveToDisk];
    }
}

-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture{
    [super ownershipOfTouches:touches isGesture:gesture];
    if([gesture isKindOfClass:[MMPanAndPinchScrapGestureRecognizer class]]){
        // only notify of our own gestures
        [[visibleStackHolder peekSubview] ownershipOfTouches:touches isGesture:gesture];
    }
    [panAndPinchScrapGesture ownershipOfTouches:touches isGesture:gesture];
    [panAndPinchScrapGesture2 ownershipOfTouches:touches isGesture:gesture];
    [stretchScrapGesture ownershipOfTouches:touches isGesture:gesture];
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
        [stretchScrapGesture blessTouches:touches];
    }
}


#pragma mark - Rotation

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading andX:(CGFloat)xAccel andY:(CGFloat)yAccel andZ:(CGFloat)zAccel{
    if(1 - ABS(zAccel) > .03){
        [NSThread performBlockOnMainThread:^{
            [super didUpdateAccelerometerWithReading:currentRawReading];
            [bezelScrapContainer didUpdateAccelerometerWithRawReading:currentRawReading andX:xAccel andY:yAccel andZ:zAccel];
            [[visibleStackHolder peekSubview] didUpdateAccelerometerWithRawReading:currentRawReading];
        }];
    }
}

#pragma mark - MMScapBubbleContainerViewDelegate

-(void) didAddScrapToBezelSidebar:(MMScrapView *)scrap{
    // noop
    NSLog(@"added a scrap to bezel");
    [bezelScrapContainer saveToDisk];
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
    [bezelScrapContainer saveToDisk];
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


#pragma mark - MMStretchScrapGestureRecognizerDelegate

// return all touches that fall within the input scrap's boundary
// and don't fall within any scrap above the input scrap
-(NSSet*) setOfTouchesFrom:(NSOrderedSet *)touches inScrap:(MMScrapView *)scrap{
    return nil;
}

@end
