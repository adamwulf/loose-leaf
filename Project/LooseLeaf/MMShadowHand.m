//
//  MMShadowHand.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/19/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMShadowHand.h"
#import "MMVector.h"
#import "UITouch+Distance.h"
#import "MMDrawingGestureShadow.h"
#import "MMTwoFingerPanShadow.h"
#import "MMDrawingGestureShadow.h"

@implementation MMShadowHand{
    UIView* relativeView;
    
    BOOL isRight;
    CAShapeLayer* layer;
    MMVector* initialVector;
    
    MMDrawingGestureShadow* pointerFingerHelper;
    MMTwoFingerPanShadow* twoFingerHelper;
    
    BOOL hasStartedToBezel;
}

@synthesize layer;


-(id) initForRightHand:(BOOL)_isRight forView:(UIView*)_relativeView{
    if(self = [super init]){
        isRight = _isRight;
        relativeView = _relativeView;
        
        layer = [CAShapeLayer layer];
        layer.opacity = .5;
        layer.anchorPoint = CGPointZero;
        layer.position = CGPointZero;
        layer.backgroundColor = [UIColor blackColor].CGColor;

        
        pointerFingerHelper = [[MMDrawingGestureShadow alloc] initForRightHand:isRight];
        twoFingerHelper = [[MMTwoFingerPanShadow alloc] initForRightHand:isRight];
    }
    return self;
}

#pragma mark - Bezeling Pages

-(void) startBezelingInFromRight:(BOOL)fromRight withTouches:(NSArray*)touches{
    hasStartedToBezel = YES;
    layer.opacity = .5;
    [self continueBezelingInFromRight:fromRight withTouches:touches];
}

-(void) continueBezelingInFromRight:(BOOL)fromRight withTouches:(NSArray*)touches{
    if(!hasStartedToBezel){
        [self startBezelingInFromRight:fromRight withTouches:touches];
        return;
    }
    UITouch* indexFingerTouch = [touches firstObject];
    if(!isRight && [[touches lastObject] locationInView:relativeView].x > [indexFingerTouch locationInView:relativeView].x){
        indexFingerTouch = [touches lastObject];
    }else if(isRight && [[touches lastObject] locationInView:relativeView].x < [indexFingerTouch locationInView:relativeView].x){
        indexFingerTouch = [touches lastObject];
    }
    UITouch* middleFingerTouch = [touches firstObject] == indexFingerTouch ? [touches lastObject] : [touches firstObject];

    CGPoint indexFingerLocation = [indexFingerTouch locationInView:relativeView];
    CGPoint middleFingerLocation = [middleFingerTouch locationInView:relativeView];
    if([touches count] == 1){
        // only 1 touch, so we need to fake the middle finger
        // being off the edge of the screen
        if(fromRight){
            if(isRight){
                // find the right-hand edge of the screen
                middleFingerLocation = CGPointMake(relativeView.bounds.size.width + 15, indexFingerLocation.y);
            }else{
                // find the right-hand edge of the screen
                indexFingerLocation = CGPointMake(relativeView.bounds.size.width + 15, indexFingerLocation.y);
            }
        }else{
            if(isRight){
                // find the left-hand edge of the screen
                indexFingerLocation = CGPointMake(-15, indexFingerLocation.y);
            }else{
                // find the left-hand edge of the screen
                middleFingerLocation = CGPointMake(-15, indexFingerLocation.y);
            }
        }
    }
    
    [self continuePanningWithIndexFinger:indexFingerLocation
                         andMiddleFinger:middleFingerLocation];
    
}

-(void) endBezelingInFromRight:(BOOL)fromRight withTouches:(NSArray*)touches{
    if(hasStartedToBezel){
        layer.opacity = 0;
        hasStartedToBezel = NO;
    }
}

#pragma mark - Panning a Page


-(void) startPanningWithTouches:(NSArray*)touches{
    layer.opacity = .5;
    [self continuePanningWithTouches:touches];
}

-(void) continuePanningWithTouches:(NSArray*)touches{
    if([touches count] >= 2){
        UITouch* indexFingerTouch = [touches firstObject];
        if(!isRight && [[touches lastObject] locationInView:relativeView].x > [indexFingerTouch locationInView:relativeView].x){
            indexFingerTouch = [touches lastObject];
        }else if(isRight && [[touches lastObject] locationInView:relativeView].x < [indexFingerTouch locationInView:relativeView].x){
            indexFingerTouch = [touches lastObject];
        }
        UITouch* middleFingerTouch = [touches firstObject] == indexFingerTouch ? [touches lastObject] : [touches firstObject];

        [self continuePanningWithIndexFinger:[indexFingerTouch locationInView:relativeView]
                             andMiddleFinger:[middleFingerTouch locationInView:relativeView]];
    }
}

-(void) endPanning{
    layer.opacity = 0;
}



#pragma mark - Drawing Events

-(void) startDrawingAtTouch:(UITouch*)touch{
    [self continueDrawingAtTouch:touch];
    layer.opacity = .5;
    
    [self preventCALayerImplicitAnimation:^{
        layer.path = [pointerFingerHelper pathForTouch:touch].CGPath;
        CGPoint locationOfTouch = [touch locationInView:relativeView];
        CGPoint offset = [pointerFingerHelper locationOfIndexFingerInPathBoundsForTouch:touch];
        CGPoint finalLocation = CGPointMake(locationOfTouch.x - offset.x, locationOfTouch.y - offset.y);
        layer.position = finalLocation;
    }];
}
-(void) continueDrawingAtTouch:(UITouch*)touch{
    [self preventCALayerImplicitAnimation:^{
        layer.path = [pointerFingerHelper pathForTouch:touch].CGPath;
        CGPoint locationOfTouch = [touch locationInView:relativeView];
        CGPoint offset = [pointerFingerHelper locationOfIndexFingerInPathBoundsForTouch:touch];
        CGPoint finalLocation = CGPointMake(locationOfTouch.x - offset.x, locationOfTouch.y - offset.y);
        layer.position = finalLocation;
    }];
}
-(void) endDrawingAtTouch:(UITouch*)touch{
    layer.opacity = 0;
}







#pragma mark - Two Finger Gesture Helper

-(void) continuePanningWithIndexFinger:(CGPoint)indexFingerLocation andMiddleFinger:(CGPoint)middleFingerLocation{
    CGFloat distance = [MMShadowHand distanceBetweenPoint:indexFingerLocation andPoint:middleFingerLocation];
    [twoFingerHelper setFingerDistance:distance];
    [self preventCALayerImplicitAnimation:^{
        layer.path = [twoFingerHelper pathForTouches:nil].CGPath;

        MMVector* currVector = [MMVector vectorWithPoint:indexFingerLocation
                                                andPoint:middleFingerLocation];
        if(!isRight){
            currVector = [currVector flip];
        }
        CGFloat theta = [[MMVector vectorWithX:1 andY:0] angleBetween:currVector];
        CGPoint offset = [twoFingerHelper locationOfIndexFingerInPathBounds];
        CGPoint finalLocation = CGPointMake(indexFingerLocation.x - offset.x, indexFingerLocation.y - offset.y);
        layer.position = finalLocation;
        layer.affineTransform = CGAffineTransformTranslate(CGAffineTransformRotate(CGAffineTransformMakeTranslation(offset.x, offset.y), theta), -offset.x, -offset.y);
    }];
}






#pragma mark - CALayer Helper

-(void) preventCALayerImplicitAnimation:(void(^)(void))block{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    block();
    [CATransaction commit];
}

+(CGFloat) distanceBetweenPoint:(const CGPoint) p1 andPoint:(const CGPoint) p2 {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
}

@end
