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
    NSMutableOrderedSet* scrapsBeingHeld;
    MMScrapContainerView* scrapContainer;
    MMPanAndPinchScrapGestureRecognizer* panAndPinchScrapGesture;
}


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        scrapsBeingHeld = [NSMutableOrderedSet orderedSet];
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
    [[visibleStackHolder peekSubview] panAndScaleScrap:_panGesture];
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
    if(isBeginningGesture){
        [scrapsBeingHeld addObject:scrap];
    }
    if(![scrapContainer.subviews containsObject:scrap]){
        CGPoint containerCenter = [[visibleStackHolder peekSubview] convertPoint:scrap.center toView:scrapContainer];
        [scrapContainer addSubview:scrap];
        scrap.center = containerCenter;
    }
    return [super isBeginning:isBeginningGesture toPanAndScaleScrap:scrap withTouches:touches];
}

-(void) finishedPanningAndScalingScrap:(MMScrapView*)scrap{
    CGPoint containerCenter = [[visibleStackHolder peekSubview] convertPoint:scrap.center fromView:scrapContainer];
    [[visibleStackHolder peekSubview] addScrap:scrap];
    scrap.center = containerCenter;
    [super finishedPanningAndScalingScrap:scrap];
}

-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture{
    if([gesture isKindOfClass:[MMPanAndPinchScrapGestureRecognizer class]]){
        // only notify of our own gestures
        [[visibleStackHolder peekSubview] ownershipOfTouches:touches isGesture:gesture];
    }
    [panAndPinchScrapGesture ownershipOfTouches:touches isGesture:gesture];
}



@end
