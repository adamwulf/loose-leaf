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
        
        CGPoint containerCenter = [[visibleStackHolder peekSubview] convertPoint:gesture.scrap.center fromView:scrapContainer];
        [[visibleStackHolder peekSubview] addScrap:gesture.scrap];
        gesture.scrap.scale = gesture.scrap.scale / [visibleStackHolder peekSubview].scale;
        CGFloat scale = [visibleStackHolder peekSubview].scale;
        containerCenter = CGPointApplyAffineTransform(containerCenter, CGAffineTransformMakeScale(1/scale, 1/scale));
        gesture.scrap.center = containerCenter;
        
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
