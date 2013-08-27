//
//  MMScrappedPaperView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/23/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrappedPaperView.h"
#import "PolygonToolDelegate.h"
#import "UIColor+ColorWithHex.h"
#import "MMScrapView.h"
#import "MMScrapContainerView.h"
#import "NSThread+BlockAdditions.h"
#import "NSArray+Extras.h"


@implementation MMScrappedPaperView{
    NSMutableArray* scraps;
    UIView* scrapContainerView;
    MMPanAndPinchScrapGestureRecognizer* panAndPinchScrapGesture;
}

- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid{
    self = [super initWithFrame:frame andUUID:_uuid];
    if (self) {
        // Initialization code
        scraps = [NSMutableArray array];
        scrapContainerView = [[MMScrapContainerView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:scrapContainerView];
        // anchor the view to the top left,
        // so that when we scale down, the drawable view
        // stays in place
        scrapContainerView.layer.anchorPoint = CGPointMake(0,0);
        scrapContainerView.layer.position = CGPointMake(0,0);

        panAndPinchScrapGesture = [[MMPanAndPinchScrapGestureRecognizer alloc] initWithTarget:self action:@selector(panAndScaleScrap:)];
        
        [panAndPinchScrapGesture requireGestureRecognizerToFail:longPress];
        [panAndPinchScrapGesture requireGestureRecognizerToFail:tap];
        panAndPinchScrapGesture.scrapDelegate = self;
        [self addGestureRecognizer:panAndPinchScrapGesture];
        
        panGesture.scrapDelegate = self;
    }
    return self;
}


#pragma mark - Scraps

/**
 * the input path contains the offset
 * and size of the new scrap from its
 * bounds
 */
-(void) addScrapWithPath:(UIBezierPath*)path{
    UIView* newScrap = [[MMScrapView alloc] initWithBezierPath:path];
    [scraps addObject:newScrap];
    [scrapContainerView addSubview:newScrap];
}

-(NSArray*) scraps{
    return [scrapContainerView.subviews reverseArray];
}

#pragma mark - Pinch and Zoom

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    CGFloat _scale = frame.size.width / self.superview.frame.size.width;
    scrapContainerView.transform = CGAffineTransformMakeScale(_scale, _scale);
}

#pragma mark - Pan and Scale Scraps

-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture{
    [panGesture ownershipOfTouches:touches isGesture:gesture];
    [panAndPinchScrapGesture ownershipOfTouches:touches isGesture:gesture];
}


-(void) panAndScale:(MMPanAndPinchGestureRecognizer *)_panGesture{
    [super panAndScale:_panGesture];
}

-(void) panAndScaleScrap:(MMPanAndPinchScrapGestureRecognizer*)_panGesture{
    MMPanAndPinchScrapGestureRecognizer* gesture = (MMPanAndPinchScrapGestureRecognizer*)_panGesture;
    
    if(gesture.scrap){
        // handle the scrap
        MMScrapView* scrap = gesture.scrap;
        scrap.center = CGPointMake(gesture.translation.x + gesture.preGestureCenter.x,
                                   gesture.translation.y + gesture.preGestureCenter.y);
        scrap.scale = gesture.scale * gesture.preGestureScale;
        scrap.rotation = gesture.rotation + gesture.preGestureRotation;
        [self.delegate isBeginning:(gesture.state == UIGestureRecognizerStateBegan) toPanAndScaleScrap:gesture.scrap withTouches:gesture.touches];
    }
    if(gesture.scrap && gesture.state == UIGestureRecognizerStateEnded){
        // after possibly rotating the scrap, we need to reset it's anchor point
        // and position, so that we can consistently determine it's position with
        // the center property
        [_panGesture setAnchorPoint:CGPointMake(.5, .5) forView:gesture.scrap];
    }
}


#pragma mark - MMRotationManagerDelegate

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading{
    for(MMScrapView* scrap in scraps){
        [scrap didUpdateAccelerometerWithRawReading:-currentRawReading];
    }
}

#pragma mark - PolygonToolDelegate

-(void) beginShapeAtPoint:(CGPoint)point{
    // send touch event to the view that
    // will display the drawn polygon line
//    NSLog(@"begin");
    [polygonDebugView clear];
    
    [polygonDebugView addTouchPoint:point];
}

-(void) continueShapeAtPoint:(CGPoint)point{
    // noop for now
    // send touch event to the view that
    // will display the drawn polygon line
    [polygonDebugView addTouchPoint:point];
}

-(void) finishShapeAtPoint:(CGPoint)point{
    // send touch event to the view that
    // will display the drawn polygon line
    //
    // and also process the touches into the new
    // scrap polygon shape, and add that shape
    // to the page
//    NSLog(@"finish");
    [polygonDebugView addTouchPoint:point];
    NSArray* shapes = [polygonDebugView complete];
    
    [polygonDebugView clear];

    for(UIBezierPath* shape in shapes){
//        if([scraps count]){
//            [[scraps objectAtIndex:0] intersect:shape];
//        }else{
            [self addScrapWithPath:[shape copy]];
//        }
    }
    
}

-(void) cancelShapeAtPoint:(CGPoint)point{
    // we've cancelled the polygon (possibly b/c
    // it was a pan/pinch instead), so clear
    // the drawn polygon and reset.
//    NSLog(@"cancel");
    [polygonDebugView clear];
}




@end
