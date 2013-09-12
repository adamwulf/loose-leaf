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
#import "DrawKit-iOS.h"
#import <JotUI/JotUI.h>
#import <JotUI/AbstractBezierPathElement-Protected.h>
#import "MMDebugDrawView.h"


@implementation MMScrappedPaperView{
    UIView* scrapContainerView;
}

- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid{
    self = [super initWithFrame:frame andUUID:_uuid];
    if (self) {
        // Initialization code
        scrapContainerView = [[MMScrapContainerView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:scrapContainerView];
        // anchor the view to the top left,
        // so that when we scale down, the drawable view
        // stays in place
        scrapContainerView.layer.anchorPoint = CGPointMake(0,0);
        scrapContainerView.layer.position = CGPointMake(0,0);

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
    [scrapContainerView addSubview:newScrap];
    
    newScrap.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.03, 1.03);
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        newScrap.transform = CGAffineTransformIdentity;
    } completion:nil];

    [path closePath];
}

-(void) addScrap:(MMScrapView*)scrap{
    [scrapContainerView addSubview:scrap];
}

-(BOOL) hasScrap:(MMScrapView*)scrap{
    return [[self scraps] containsObject:scrap];
}

/**
 * returns all subviews in back-to-front
 * order
 */
-(NSArray*) scraps{
    // we'll be calling this method quite often,
    // so don't create a new auto-released array
    // all the time. instead, just return our subview
    // array, so that if the caller just needs count
    // or to iterate on the main thread, we don't
    // spend unnecessary resources copying a potentially
    // long array.
    return scrapContainerView.subviews;
}

#pragma mark - Pinch and Zoom

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    CGFloat _scale = frame.size.width / self.superview.frame.size.width;
    scrapContainerView.transform = CGAffineTransformMakeScale(_scale, _scale);
}

#pragma mark - Pan and Scale Scraps

/**
 * this is an important method to ensure that panning scraps and panning pages
 * don't step on each other.
 *
 * when panning, single touches are held as "possible" touches for both panning
 * gestures. once two possible touches exist in the pan gestures, then one of the
 * two gestures will own it.
 *
 * when a pan gesture takes ownership of a pair of touches, it needs to notify
 * the other pan gestures that it owns it. Since the PanPage gesture is owned
 * by the page and the PanScrap gesture is owned by the stack, we need these
 * delegate calls to be passed from gesture -> the gesture delegate -> page or stack
 * without causing an infinite loop of delegate calls.
 *
 * in this way, each gesture will notify its own delegate, either the stack or page.
 * the stack and page will notify each other *only* of touch ownerships from gestures
 * that they own. so the page will notify about PanPage ownership, and the stack
 * will notify of PanScrap ownership
 */
-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture{
    [panGesture ownershipOfTouches:touches isGesture:gesture];
    if([gesture isKindOfClass:[MMPanAndPinchGestureRecognizer class]]){
        // only notify of our own gestures
        [self.delegate ownershipOfTouches:touches isGesture:gesture];
    }
}

-(BOOL) panScrapRequiresLongPress{
    return [self.delegate panScrapRequiresLongPress];
}

-(void) panAndScale:(MMPanAndPinchGestureRecognizer *)_panGesture{
    [[MMDebugDrawView sharedInstace] clear];
    
    [super panAndScale:_panGesture];
}

#pragma mark - JotViewDelegate



-(NSArray*) willAddElementsToStroke:(NSArray *)elements fromPreviousElement:(AbstractBezierPathElement*)previousElement{
    NSArray* strokes = [super willAddElementsToStroke:elements fromPreviousElement:previousElement];
    
    if(![self.scraps count]){
        return strokes;
    }
    
    
    
    NSMutableArray* strokesToCrop = [NSMutableArray arrayWithArray:strokes];
    
    for(MMScrapView* scrap in self.scraps){
        // find the bounding box of the scrap, so we can determine
        // quickly if they even possibly intersect
        
        UIBezierPath* scrapPath = [scrap.bezierPath copy];

        // when we pick up a scrap with a two finger gesture, we also
        // change the position and anchor (which change the center), so
        // that it rotates underneath the gesture correctly.
        //
        // we need to re-caculate the true center of the scrap as if it
        // was not being held, so that we can position our path correctly
        // over it.
        CGPoint actualScrapCenter = CGPointMake( CGRectGetMidX(scrap.frame), CGRectGetMidY(scrap.frame));

        // first, align the center of the scrap to the center of the path
        [scrapPath applyTransform:CGAffineTransformMakeTranslation(actualScrapCenter.x - scrapPath.center.x, actualScrapCenter.y - scrapPath.center.y)];
        // now we need to rotate the path around it's new center
        CGPoint scrapPathCenter = scrapPath.center;
        CGAffineTransform rotateAndScale = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-scrapPathCenter.x, -scrapPathCenter.y),
                                                                   CGAffineTransformConcat(CGAffineTransformMakeRotation(scrap.rotation),CGAffineTransformMakeScale(scrap.scale, scrap.scale)));
        rotateAndScale = CGAffineTransformConcat(rotateAndScale, CGAffineTransformMakeTranslation(scrapPathCenter.x, scrapPathCenter.y));
        rotateAndScale = CGAffineTransformConcat(rotateAndScale, CGAffineTransformMake(1, 0, 0, -1, 0, self.bounds.size.height));
        [scrapPath applyTransform:rotateAndScale];
        
        CGRect boundsOfScrap = scrapPath.bounds;
        
        NSMutableArray* newStrokesToScrop = [NSMutableArray array];
        for(AbstractBezierPathElement* element in strokesToCrop){
            if(!CGRectIntersectsRect(element.bounds, boundsOfScrap)){
                [newStrokesToScrop addObject:element];
            }else if([element isKindOfClass:[CurveToPathElement class]]){
                CurveToPathElement* curveElement = (CurveToPathElement*)element;

                UIBezierPath* strokePath = [UIBezierPath bezierPath];
                [strokePath moveToPoint:curveElement.startPoint];
                [strokePath addCurveToPoint:curveElement.endPoint controlPoint1:curveElement.ctrl1 controlPoint2:curveElement.ctrl2];

                NSArray* output = [strokePath clipToClosedPath:scrapPath];
                UIBezierPath* diff = [output lastObject];
                
                __block CGPoint previousEndpoint = strokePath.firstPoint;
                [diff iteratePathWithBlock:^(CGPathElement pathEle){
                    AbstractBezierPathElement* newElement = nil;
                    if(pathEle.type == kCGPathElementAddCurveToPoint){
                        // curve
                        newElement = [CurveToPathElement elementWithStart:previousEndpoint
                                                               andCurveTo:pathEle.points[2]
                                                              andControl1:pathEle.points[0]
                                                              andControl2:pathEle.points[1]];
                        previousEndpoint = pathEle.points[2];
                    }else if(pathEle.type == kCGPathElementMoveToPoint){
                        newElement = [MoveToPathElement elementWithMoveTo:pathEle.points[0]];
                        previousEndpoint = pathEle.points[0];
                    }else if(pathEle.type == kCGPathElementAddLineToPoint){
                        newElement = [CurveToPathElement elementWithStart:previousEndpoint andLineTo:pathEle.points[0]];
                        previousEndpoint = pathEle.points[0];
                    }
                    if(newElement){
                        // be sure to set color/width/etc
                        newElement.color = element.color;
                        newElement.width = element.width;
                        newElement.rotation = element.rotation;
                        [newStrokesToScrop addObject:newElement];
                    }
                }];
            }else{
                [newStrokesToScrop addObject:element];
            }
        }
        
        strokesToCrop = newStrokesToScrop;
    }
    
    return strokesToCrop;
}


#pragma mark - MMRotationManagerDelegate

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading{
    for(MMScrapView* scrap in self.scraps){
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

-(BOOL) continueShapeAtPoint:(CGPoint)point{
    // noop for now
    // send touch event to the view that
    // will display the drawn polygon line
    if([polygonDebugView addTouchPoint:point]){
        [self complete];
        return NO;
    }
    return YES;
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
    [self complete];
}

-(void) complete{
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
