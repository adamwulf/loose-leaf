//
//  MMScrapPaperStackView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/29/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapPaperStackView.h"
#import "MMScrapContainerView.h"

@implementation MMScrapPaperStackView{
    MMScrapContainerView* scrapContainer;
    MMPanAndPinchScrapGestureRecognizer* panAndPinchScrapGesture;
}


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        scrapContainer = [[MMScrapContainerView alloc] initWithFrame:self.bounds];
        [self addSubview:scrapContainer];

        panAndPinchScrapGesture = [[MMPanAndPinchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(panAndScaleScrap:)];
        panAndPinchScrapGesture.bezelDirectionMask = MMBezelDirectionRight;
//        [panAndPinchScrapGesture requireGestureRecognizerToFail:longPress];
//        [panAndPinchScrapGesture requireGestureRecognizerToFail:tap];
        panAndPinchScrapGesture.scrapDelegate = self;
        [self addGestureRecognizer:panAndPinchScrapGesture];
        
    }
    return self;
}

-(void) panAndScaleScrap:(MMPanAndPinchScrapGestureRecognizer*)_panGesture{
    MMPanAndPinchScrapGestureRecognizer* gesture = (MMPanAndPinchScrapGestureRecognizer*)_panGesture;
    
    if(gesture.state == UIGestureRecognizerStateBegan){
        CGFloat pageScale = [visibleStackHolder peekSubview].scale;
        gesture.preGestureScale *= pageScale;
        CGPoint centerInPage = CGPointApplyAffineTransform(_panGesture.scrap.center, CGAffineTransformMakeScale(pageScale, pageScale));
        gesture.preGestureCenter = [[visibleStackHolder peekSubview] convertPoint:centerInPage toView:scrapContainer];
    }
    
    if(gesture.scrap){
        // handle the scrap
        MMScrapView* scrap = gesture.scrap;
        scrap.center = CGPointMake(gesture.translation.x + gesture.preGestureCenter.x,
                                   gesture.translation.y + gesture.preGestureCenter.y);
        scrap.scale = gesture.scale * gesture.preGestureScale;
        scrap.rotation = gesture.rotation + gesture.preGestureRotation;
        if(![scrapContainer.subviews containsObject:scrap]){
            [scrapContainer addSubview:scrap];
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
        // my original idea was to see if the center of the scrap is inside the page, and if so
        // then I'd add it. otherwise, i'd look behind it and add it to whatever page contained
        // the center point.
        //
        // the problem is that if the scrap is moved "off" the page but still had ~30% of its
        // shape inside the top page, then should it fall to the page behind or should it
        // fall onto the top page since some visible content is still there.
        //
        // if i let the top page keep the scrap b/c some scrap is visible, then how much
        // scrap is enough?
        //
        // one thought: maybe i use the location of the /gesture/ instead of the location of the scrap
        // since the gesture location has to be inside the bounds of the scrap, then dropping the scrap
        // on a page will work.
        
        MMScrappedPaperView* pageToDropScrap = nil;
        CGFloat scrapScaleInPage;
        CGPoint scrapCenterInPage;
        CGRect pageBounds;
        do{
            if(!pageToDropScrap){
                pageToDropScrap = [visibleStackHolder peekSubview];
            }else{
                pageToDropScrap = [visibleStackHolder getPageBelow:pageToDropScrap];
                if(!pageToDropScrap){
                    break;
                }
            }
            CGFloat pageScale = pageToDropScrap.scale;
            scrapScaleInPage = gesture.scrap.scale / pageScale;
            
            scrapCenterInPage = [pageToDropScrap convertPoint:gesture.scrap.center fromView:scrapContainer];
            CGAffineTransform reverseScaleTransform = CGAffineTransformMakeScale(1/pageScale, 1/pageScale);
            scrapCenterInPage = CGPointApplyAffineTransform(scrapCenterInPage, reverseScaleTransform);
            
            // bounds respects the transform, so we need to scale the
            // bounds of the page too to see if the scrap is landing inside
            // of it
            pageBounds = pageToDropScrap.bounds;
            pageBounds = CGRectApplyAffineTransform(pageBounds, reverseScaleTransform);
            if(CGRectContainsPoint(pageBounds, scrapCenterInPage)){
                NSLog(@"page %@ contains scrap center", pageToDropScrap.uuid);
            }
        }while(!CGRectContainsPoint(pageBounds, scrapCenterInPage));

        if(pageToDropScrap){
            NSLog(@"page %@ contains scrap center", pageToDropScrap.uuid);
            [pageToDropScrap addScrap:gesture.scrap];
            gesture.scrap.scale = scrapScaleInPage;
            gesture.scrap.center = scrapCenterInPage;
        }else{
            NSLog(@"send scrap to sidebar");
            [[visibleStackHolder peekSubview] addScrap:gesture.scrap];
            gesture.scrap.scale = scrapScaleInPage;
            gesture.scrap.center = [visibleStackHolder peekSubview].center;
        }
        
        [self finishedPanningAndScalingScrap:gesture.scrap];
    }
    if(gesture.scrap && gesture.state == UIGestureRecognizerStateEnded){
        // after possibly rotating the scrap, we need to reset it's anchor point
        // and position, so that we can consistently determine it's position with
        // the center property
        [gesture giveUpScrap];
        
        if(_panGesture.didExitToBezel){
            NSLog(@"exit to bezel!");
        }else{
            NSLog(@"didn't exit to bezel!");
        }
    }
}

#pragma mark - MMPanAndPinchScrapGestureRecognizerDelegate

-(NSArray*) scraps{
    return [[visibleStackHolder peekSubview] scraps];
}


#pragma mark - MMPaperViewDelegate

-(CGRect) isBeginning:(BOOL)isBeginningGesture toPanAndScalePage:(MMPaperView *)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame withTouches:(NSArray*)touches{
    return [super isBeginning:isBeginningGesture toPanAndScalePage:page fromFrame:fromFrame toFrame:toFrame withTouches:touches];
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
}



@end
