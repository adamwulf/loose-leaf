//
//  MMSilhouetteView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/12/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMSilhouetteView.h"
#import "MMDrawingGestureSilhouette.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "UIView+Debug.h"
#import "MMLeftTwoFingerPanSilhouette.h"
#import "MMRightTwoFingerPanSilhouette.h"
#import "MMTouchDotGestureRecognizer.h"
#import "NSThread+BlockAdditions.h"
#import "UITouch+Distance.h"

@implementation MMSilhouetteView{
    MMDrawingGestureSilhouette* pointerFingerHelper;
    MMLeftTwoFingerPanSilhouette* leftTwoFingerHelper;
    MMRightTwoFingerPanSilhouette* rightTwoFingerHelper;
    UISlider* slider;
    CAShapeLayer* rightHandLayer;
    CAShapeLayer* leftHandLayer;
}



-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        
        rightHandLayer = [CAShapeLayer layer];
        rightHandLayer.opacity = .5;
        rightHandLayer.anchorPoint = CGPointZero;
        rightHandLayer.position = CGPointZero;
        rightHandLayer.backgroundColor = [UIColor blackColor].CGColor;
        
        leftHandLayer = [CAShapeLayer layer];
        leftHandLayer.opacity = .5;
        leftHandLayer.anchorPoint = CGPointZero;
        leftHandLayer.position = CGPointZero;
        leftHandLayer.backgroundColor = [UIColor blackColor].CGColor;
        
        
        slider = [[UISlider alloc] initWithFrame:CGRectMake(450, 50, 200, 40)];
        slider.value = 1;
        slider.minimumValue = 0;
        slider.maximumValue = 1;
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
//        [[NSThread mainThread] performBlock:^{
//            [self.window addSubview:slider];
//        } afterDelay:.3];
        
        // setup hand path
        pointerFingerHelper = [[MMDrawingGestureSilhouette alloc] init];
        leftTwoFingerHelper = [[MMLeftTwoFingerPanSilhouette alloc] init];
        rightTwoFingerHelper = [[MMRightTwoFingerPanSilhouette alloc] init];
        
        
        [self.layer addSublayer:leftHandLayer];
        [self.layer addSublayer:rightHandLayer];
    }
    return self;
}

-(void) sliderValueChanged:(UISlider*)_slider{
    [leftTwoFingerHelper openTo:slider.value];
    [rightTwoFingerHelper openTo:slider.value];
    
    [self preventCALayerImplicitAnimation:^{
        leftHandLayer.path = [leftTwoFingerHelper pathForTouches:nil].CGPath;
    }];
}



#pragma mark - Panning a Page

-(void) startPanningPage:(MMPaperView*)page withTouches:(NSArray*)touches{
    leftHandLayer.opacity = .5;
    if([touches count] >= 2){
        CGFloat distance = [[touches firstObject] distanceToTouch:[touches lastObject]];
        [leftTwoFingerHelper setFingerDistance:distance];
        [self preventCALayerImplicitAnimation:^{
            leftHandLayer.path = [leftTwoFingerHelper pathForTouches:nil].CGPath;

            UITouch* touch = [touches firstObject];
            if([[touches lastObject] locationInView:self].x > [touch locationInView:self].x){
                touch = [touches lastObject];
            }
            CGPoint locationOfTouch = [touch locationInView:self.window];
            CGPoint offset = [leftTwoFingerHelper locationOfIndexFingerInPathBoundsForTouches:touches];
            CGPoint finalLocation = CGPointMake(locationOfTouch.x - offset.x, locationOfTouch.y - offset.y);
            leftHandLayer.position = finalLocation;
        }];


        [touches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"start pan: %f %f", [obj locationInView:self.window].x, [obj locationInView:self.window].y);
        }];
    }
}

-(void) continuePanningPage:(MMPaperView*)page withTouches:(NSArray*)touches{
    if([touches count] >= 2){
        CGFloat distance = [[touches firstObject] distanceToTouch:[touches lastObject]];
        [leftTwoFingerHelper setFingerDistance:distance];
        [self preventCALayerImplicitAnimation:^{
            leftHandLayer.path = [leftTwoFingerHelper pathForTouches:nil].CGPath;
            
            UITouch* touch = [touches firstObject];
            if([[touches lastObject] locationInView:self].x > [touch locationInView:self].x){
                touch = [touches lastObject];
            }
            CGPoint locationOfTouch = [touch locationInView:self.window];
            CGPoint offset = [leftTwoFingerHelper locationOfIndexFingerInPathBoundsForTouches:touches];
            CGPoint finalLocation = CGPointMake(locationOfTouch.x - offset.x, locationOfTouch.y - offset.y);
            leftHandLayer.position = finalLocation;
        }];
        [touches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"continue pan: %f %f", [obj locationInView:self.window].x, [obj locationInView:self.window].y);
        }];
    }
}

-(void) endPanningPage:(MMPaperView*)page{
    NSLog(@"end pan");
    leftHandLayer.opacity = 0;
}



#pragma mark - Drawing Events

-(void) startDrawingAtTouch:(UITouch*)touch{
    [self continueDrawingAtTouch:touch];
    rightHandLayer.opacity = .5;
    
    [self preventCALayerImplicitAnimation:^{
        rightHandLayer.path = [pointerFingerHelper pathForTouch:touch].CGPath;
        CGPoint locationOfTouch = [touch locationInView:touch.view];
        CGPoint offset = [pointerFingerHelper locationOfIndexFingerInPathBoundsForTouch:touch];
        CGPoint finalLocation = CGPointMake(locationOfTouch.x - offset.x, locationOfTouch.y - offset.y);
        rightHandLayer.position = finalLocation;
    }];
}
-(void) continueDrawingAtTouch:(UITouch*)touch{
    [self preventCALayerImplicitAnimation:^{
        rightHandLayer.path = [pointerFingerHelper pathForTouch:touch].CGPath;
        CGPoint locationOfTouch = [touch locationInView:touch.view];
        CGPoint offset = [pointerFingerHelper locationOfIndexFingerInPathBoundsForTouch:touch];
        CGPoint finalLocation = CGPointMake(locationOfTouch.x - offset.x, locationOfTouch.y - offset.y);
        rightHandLayer.position = finalLocation;
    }];
}
-(void) endDrawingAtTouch:(UITouch*)touch{
    rightHandLayer.opacity = 0;
}


#pragma mark - Ignore Touches

/**
 * these two methods make sure that touches on this
 * UIView always passthrough to any views underneath it
 */
-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return nil;
}

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return NO;
}



#pragma mark - CALayer Helper

-(void) preventCALayerImplicitAnimation:(void(^)(void))block{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    block();
    [CATransaction commit];
}


@end
