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
#import "MMScrapBubbleView.h"

@implementation MMScrapPaperStackView{
    MMScrapContainerView* bezelScrapContainer;
    MMScrapContainerView* scrapContainer;
    // we get two gestures here, so that we can support
    // grabbing two scraps at the same time
    MMPanAndPinchScrapGestureRecognizer* panAndPinchScrapGesture;
    MMPanAndPinchScrapGestureRecognizer* panAndPinchScrapGesture2;
    MMShakeScrapGestureRecognizer* shakeScrapGesture;
    
    NSMutableArray* bezelledScraps;
}


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        scrapContainer = [[MMScrapContainerView alloc] initWithFrame:self.bounds];
        [self addSubview:scrapContainer];
        
        bezelScrapContainer = [[MMScrapContainerView alloc] initWithFrame:self.bounds];
        [self addSubview:bezelScrapContainer];

        panAndPinchScrapGesture = [[MMPanAndPinchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(panAndScaleScrap:)];
        panAndPinchScrapGesture.bezelDirectionMask = MMBezelDirectionRight;
        panAndPinchScrapGesture.scrapDelegate = self;
        [self addGestureRecognizer:panAndPinchScrapGesture];
        
//        shakeScrapGesture = [[MMShakeScrapGestureRecognizer alloc] initWithTarget:self action:@selector(shakeScrap:)];
//        [self addGestureRecognizer:shakeScrapGesture];
        
        panAndPinchScrapGesture2 = [[MMPanAndPinchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(panAndScaleScrap:)];
        panAndPinchScrapGesture2.bezelDirectionMask = MMBezelDirectionRight;
        panAndPinchScrapGesture2.scrapDelegate = self;
        [self addGestureRecognizer:panAndPinchScrapGesture2];
        
        bezelledScraps = [NSMutableArray array];
    }
    return self;
}



#pragma mark - Bezel Gestures

-(void) isBezelingInLeftWithGesture:(MMBezelInLeftGestureRecognizer*)bezelGesture{
    [super isBezelingInLeftWithGesture:bezelGesture];
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

-(void) isBezelingInRightWithGesture:(MMBezelInRightGestureRecognizer *)bezelGesture{
    [super isBezelingInRightWithGesture:bezelGesture];
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


#pragma mark - Panning Scraps

-(void) panAndScaleScrap:(MMPanAndPinchScrapGestureRecognizer*)_panGesture{
    MMPanAndPinchScrapGestureRecognizer* gesture = (MMPanAndPinchScrapGestureRecognizer*)_panGesture;
    
    if(gesture.state == UIGestureRecognizerStateBegan){
        CGFloat pageScale = [visibleStackHolder peekSubview].scale;
        gesture.preGestureScale *= pageScale;
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
            [bezelledScraps addObject:gesture.scrap];
        }
        
        [self finishedPanningAndScalingScrap:gesture.scrap];
    }
    if(gesture.scrap && (gesture.state == UIGestureRecognizerStateEnded ||
                         gesture.state == UIGestureRecognizerStateFailed ||
                         gesture.state == UIGestureRecognizerStateCancelled)){
        // after possibly rotating the scrap, we need to reset it's anchor point
        // and position, so that we can consistently determine it's position with
        // the center property
        
        MMScrapView* scrap = gesture.scrap;
        
        [gesture giveUpScrap];
        
        if(_panGesture.didExitToBezel){
            // exit the scrap to the bezel!
            CGRect rect = CGRectMake(668, 240, 80, 80);
            if([bezelScrapContainer.subviews count]){
                // put it below the most recent bubble
                // each bubble is ordered in subviews most recent -> least recent
                rect = [[bezelScrapContainer.subviews firstObject] frame];
                rect = CGRectOffset(rect, 0, 80);
            }
            MMScrapBubbleView* bubble = [[MMScrapBubbleView alloc] initWithFrame:rect];
            [bezelScrapContainer insertSubview:bubble atIndex:0];
            [bezelScrapContainer insertSubview:scrap aboveSubview:bubble];
            // keep the scrap in the bezel container during the animation, then
            // push it into the bubble
            bubble.alpha = 0;
            bubble.transform = CGAffineTransformMakeScale(.9, .9);

            CGFloat animationDuration = .5;
            [UIView animateWithDuration:animationDuration * .51 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                // animate the scrap into position
                bubble.alpha = 1;
                scrap.transform = CGAffineTransformConcat([MMScrapBubbleView idealTransformForScrap:scrap], bubble.transform);
                scrap.center = bubble.center;
            } completion:^(BOOL finished){
                // add it to the bubble and bounce
                bubble.scrap = scrap;
                [UIView animateWithDuration:animationDuration * .2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    // scrap "hits" the bubble and pushes it down a bit
                    bubble.transform = CGAffineTransformMakeScale(.8, .8);
                } completion:^(BOOL finished){
                    [UIView animateWithDuration:animationDuration * .2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        // bounce back
                        bubble.transform = CGAffineTransformMakeScale(1.1, 1.1);
                    } completion:^(BOOL finished){
                        [UIView animateWithDuration:animationDuration * .16 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            // and done
                            bubble.transform = CGAffineTransformIdentity;
                        } completion:nil];
                    }];
                }];
                
            }];
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



@end
