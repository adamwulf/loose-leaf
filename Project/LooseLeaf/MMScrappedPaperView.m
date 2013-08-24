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

@implementation MMScrappedPaperView{
    NSMutableArray* scraps;
    UIView* scrapContainerView;
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
    return [NSArray arrayWithArray:scraps];
}

#pragma mark - Pinch and Zoom

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    CGFloat _scale = frame.size.width / self.superview.frame.size.width;
    scrapContainerView.transform = CGAffineTransformMakeScale(_scale, _scale);
}

#pragma mark - Pan and Scale

-(void) panAndScale:(MMPanAndPinchGestureRecognizer*)_panGesture{
    if(_panGesture.state == UIGestureRecognizerStateBegan){
        // ok, we just started, let's decide if we're looking at a scrap
        for(MMScrapView* scrap in scraps){
            BOOL scrapContainsAllTouches = YES;
            for(UITouch* touch in _panGesture.touches){
                // decide if all these touches land in scrap
                scrapContainsAllTouches = scrapContainsAllTouches && [scrap containsTouch:touch];
            }
            if(scrapContainsAllTouches){
                scrap.preGestureScale = scrap.scale;
                scrap.preGestureRotation = scrap.rotation;
                _panGesture.scrap = scrap;
                break;
            }
        }
        
        if(_panGesture.scrap){
            NSLog(@"gotcha!");
        }
    }
    if(_panGesture.scrap){
        // handle the scrap
        MMScrapView* scrap = _panGesture.scrap;
        scrap.scale = _panGesture.scale * scrap.preGestureScale;
        scrap.rotation = _panGesture.rotation + scrap.preGestureRotation;
        [self.delegate isBeginning:(_panGesture.state == UIGestureRecognizerStateBegan) toPanAndScaleScrap:_panGesture.scrap withTouches:_panGesture.touches];
        NSLog(@"center: %f %f", scrap.center.x, scrap.center.y);
    }else{
        [super panAndScale:_panGesture];
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
    NSLog(@"begin");
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
    NSLog(@"finish");
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
    NSLog(@"cancel");
    [polygonDebugView clear];
}




@end
