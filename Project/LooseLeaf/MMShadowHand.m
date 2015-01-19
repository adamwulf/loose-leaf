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
#import "MMDrawingGestureSilhouette.h"
#import "MMLeftTwoFingerPanSilhouette.h"
#import "MMRightTwoFingerPanSilhouette.h"


@implementation MMShadowHand{
    UIView* relativeView;
    
    BOOL isRight;
    CAShapeLayer* layer;
    id relatedObject;
    MMVector* initialVector;
    
    MMDrawingGestureSilhouette* pointerFingerHelper;
    MMLeftTwoFingerPanSilhouette* twoFingerHelper;
}

@synthesize layer;
@synthesize relatedObject;


-(id) initForRightHand:(BOOL)_isRight forView:(UIView*)_relativeView{
    if(self = [super init]){
        isRight = _isRight;
        relativeView = _relativeView;
        
        layer = [CAShapeLayer layer];
        layer.opacity = .5;
        layer.anchorPoint = CGPointZero;
        layer.position = CGPointZero;
        layer.backgroundColor = [UIColor blackColor].CGColor;

        pointerFingerHelper = [[MMDrawingGestureSilhouette alloc] init];
        if(isRight){
            twoFingerHelper = [[MMRightTwoFingerPanSilhouette alloc] init];
        }else{
            twoFingerHelper = [[MMLeftTwoFingerPanSilhouette alloc] init];
        }
    }
    return self;
}


#pragma mark - Panning a Page


-(void) startPanningObject:(id)obj withTouches:(NSArray*)touches{
    relatedObject = obj;
    layer.opacity = .5;
    if([touches count] >= 2){
        CGFloat distance = [[touches firstObject] distanceToTouch:[touches lastObject]];
        initialVector = [MMVector vectorWithPoint:[[touches firstObject] locationInView:relativeView]
                                         andPoint:[[touches lastObject] locationInView:relativeView]];
        [twoFingerHelper setFingerDistance:distance];
        [self preventCALayerImplicitAnimation:^{
            layer.path = [twoFingerHelper pathForTouches:nil].CGPath;
            
            UITouch* touch = [touches firstObject];
            if([[touches lastObject] locationInView:relativeView].x > [touch locationInView:relativeView].x){
                touch = [touches lastObject];
            }
            CGPoint locationOfTouch = [touch locationInView:relativeView];
            CGPoint offset = [twoFingerHelper locationOfIndexFingerInPathBoundsForTouches:touches];
            CGPoint finalLocation = CGPointMake(locationOfTouch.x - offset.x, locationOfTouch.y - offset.y);
            layer.position = finalLocation;
        }];
    }
}

-(void) continuePanningObject:(id)obj withTouches:(NSArray*)touches{
    if([touches count] >= 2){
        MMVector* currVector = [MMVector vectorWithPoint:[[touches firstObject] locationInView:relativeView]
                                                andPoint:[[touches lastObject] locationInView:relativeView]];
        CGFloat theta = [initialVector angleBetween:currVector];
        CGFloat distance = [[touches firstObject] distanceToTouch:[touches lastObject]];
        [twoFingerHelper setFingerDistance:distance];
        [self preventCALayerImplicitAnimation:^{
            layer.affineTransform = CGAffineTransformIdentity;
            UIBezierPath* handPath = [twoFingerHelper pathForTouches:nil];
            layer.path = handPath.CGPath;
            
            UITouch* touch = [touches firstObject];
            if([[touches lastObject] locationInView:relativeView].x > [touch locationInView:relativeView].x){
                touch = [touches lastObject];
            }
            CGPoint locationOfTouch = [touch locationInView:relativeView];
            CGPoint offset = [twoFingerHelper locationOfIndexFingerInPathBoundsForTouches:touches];
            CGPoint finalLocation = CGPointMake(locationOfTouch.x - offset.x, locationOfTouch.y - offset.y);
            layer.position = finalLocation;
            
            layer.affineTransform = CGAffineTransformTranslate(CGAffineTransformRotate(CGAffineTransformMakeTranslation(offset.x, offset.y), theta), -offset.x, -offset.y);
        }];
    }
}

-(void) endPanningObject:(id)obj{
    layer.opacity = 0;
    relatedObject = nil;
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
    if(!relatedObject){
        layer.opacity = 0;
    }
}



#pragma mark - CALayer Helper

-(void) preventCALayerImplicitAnimation:(void(^)(void))block{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    block();
    [CATransaction commit];
}

@end
