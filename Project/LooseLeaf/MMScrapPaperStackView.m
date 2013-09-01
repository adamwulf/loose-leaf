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
        [self addSubview:scrapContainer];
        
        bezelScrapContainer = [[MMScapBubbleContainerView alloc] initWithFrame:self.bounds];
        bezelScrapContainer.delegate = self;
        [self addSubview:bezelScrapContainer];

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
    }
    return self;
}

#pragma mark - Add Page

-(void) addPageButtonTapped:(UIButton*)_button{
    [self forceScrapToScrapContainerDuringGesture];
    [super addPageButtonTapped:_button];
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
    // TODO: https://github.com/adamwulf/loose-leaf/issues/185
    // the problem with picking up scraps during a scaled
    // page is that I'm saving the state in the scrap itself.
    //
    // instead. when the gesture begins, i need to store the
    // absolute scale and position of the scrap in scrapContainer
    // space. Then, whenever the page position or scale changes,
    // or the scrap gesture changes, I can calculate the scrap
    // position in or out of a page starting from the original
    // scale and position, adding the scrap gesture differences,
    // and then converting to the page if needed.
    
    if(gesture.state == UIGestureRecognizerStateBegan){
        CGFloat pageScale = [visibleStackHolder peekSubview].scale;
//        gesture.preGestureScale *= pageScale;
        gesture.preGesturePageScale = pageScale;
        CGPoint centerInPage = CGPointApplyAffineTransform(_panGesture.scrap.center, CGAffineTransformMakeScale(pageScale, pageScale));
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
        scrap.scale = gesture.scale * gesture.preGestureScale;
        if(![scrapContainer.subviews containsObject:scrap]){
            scrap.scale = scrap.scale * [visibleStackHolder peekSubview].scale;
        }
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
            gesture.scrap.scale = scrapScaleInPage / pageToDropScrap.scale;
            gesture.scrap.center = scrapCenterInPage;
        }
        [self isBeginning:gesture.state == UIGestureRecognizerStateBegan toPanAndScaleScrap:gesture.scrap withTouches:gesture.touches];
    }
    if(gesture.state == UIGestureRecognizerStateBegan){
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
        
        BOOL shouldBezel = NO;
        if(gesture.didExitToBezel){
            NSLog(@"did bezel the scrap");
            shouldBezel = YES;
        }else if([scrapContainer.subviews containsObject:gesture.scrap]){
            CGFloat scrapScaleInPage;
            CGPoint scrapCenterInPage;
            NSLog(@"center: %f %f", gesture.scrap.center.x, gesture.scrap.center.y);
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
        if(shouldBezel){
            // TODO: bezel the scrap
            NSLog(@"send scrap to sidebar");
        }
        
        [self finishedPanningAndScalingScrap:gesture.scrap];
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
        
        if(_panGesture.didExitToBezel){
            // if we've bezelled the scrap,
            // add it to the bezel container
            [bezelScrapContainer addScrapAnimated:scrap];
        }
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
    NSMutableArray* pages = [NSMutableArray arrayWithArray:visibleStackHolder.subviews];
    [pages addObjectsFromArray:bezelStackHolder.subviews];
    do{
        // fetch the most visible page
        pageToDropScrap = [pages lastObject];
        [pages removeLastObject];
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


#pragma mark - MMPaperViewDelegate

-(CGRect) isBeginning:(BOOL)beginning toPanAndScalePage:(MMPaperView *)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame withTouches:(NSArray*)touches{
    CGRect ret = [super isBeginning:beginning toPanAndScalePage:page fromFrame:fromFrame toFrame:toFrame withTouches:touches];
    [self panAndScaleScrap:panAndPinchScrapGesture];
    [self panAndScaleScrap:panAndPinchScrapGesture2];
    return ret;
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
    // noop
}

-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture{
    if([gesture isKindOfClass:[MMPanAndPinchScrapGestureRecognizer class]]){
        // only notify of our own gestures
        [[visibleStackHolder peekSubview] ownershipOfTouches:touches isGesture:gesture];
    }
    [panAndPinchScrapGesture ownershipOfTouches:touches isGesture:gesture];
    [panAndPinchScrapGesture2 ownershipOfTouches:touches isGesture:gesture];
}


#pragma mark - Rotation

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading andX:(CGFloat)xAccel andY:(CGFloat)yAccel andZ:(CGFloat)zAccel{
    [super didUpdateAccelerometerWithReading:currentRawReading];
    [bezelScrapContainer didUpdateAccelerometerWithRawReading:currentRawReading andX:xAccel andY:yAccel andZ:zAccel];
}

#pragma mark - MMScapBubbleContainerViewDelegate

-(void) didTapToAddScrapBackToPage:(MMScrapView *)scrap{
    MMScrappedPaperView* page = [visibleStackHolder peekSubview];
    [page addScrap:scrap];
    //
    // TODO:
    // adjust for the page location and scale
    // and also look to see if it should land in a bezel page
    // or the visible stack
}


@end
