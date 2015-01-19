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
#import "MMVector.h"
#import "MMShadowHand.h"

@implementation MMSilhouetteView{
    MMDrawingGestureSilhouette* pointerFingerHelper;
    MMLeftTwoFingerPanSilhouette* leftTwoFingerHelper;
    MMRightTwoFingerPanSilhouette* rightTwoFingerHelper;
//    UISlider* slider;
    MMShadowHand* rightHandLayer;
    MMShadowHand* leftHandLayer;
}



-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        leftHandLayer = [[MMShadowHand alloc] initForRightHand:NO forView:self.window];
        rightHandLayer = [[MMShadowHand alloc] initForRightHand:YES forView:self.window];
        
        
//        slider = [[UISlider alloc] initWithFrame:CGRectMake(450, 50, 200, 40)];
//        slider.value = 1;
//        slider.minimumValue = 0;
//        slider.maximumValue = 1;
//        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
//        [[NSThread mainThread] performBlock:^{
//            [self.window addSubview:slider];
//        } afterDelay:.3];
        
        // setup hand path
        pointerFingerHelper = [[MMDrawingGestureSilhouette alloc] init];
        leftTwoFingerHelper = [[MMLeftTwoFingerPanSilhouette alloc] init];
        rightTwoFingerHelper = [[MMRightTwoFingerPanSilhouette alloc] init];
        
        
        [self.layer addSublayer:leftHandLayer.layer];
        [self.layer addSublayer:rightHandLayer.layer];
    }
    return self;
}

//-(void) sliderValueChanged:(UISlider*)_slider{
//    [leftTwoFingerHelper openTo:slider.value];
//    [rightTwoFingerHelper openTo:slider.value];
//    
//    [self preventCALayerImplicitAnimation:^{
//        leftHandLayer.path = [leftTwoFingerHelper pathForTouches:nil].CGPath;
//    }];
//}



#pragma mark - Panning a Page


static MMVector* initialVector;

-(void) startPanningObject:(id)obj withTouches:(NSArray*)touches{
    [leftHandLayer startPanningObject:obj withTouches:touches];
}

-(void) continuePanningObject:(id)obj withTouches:(NSArray*)touches{
    [leftHandLayer continuePanningObject:obj withTouches:touches];
}

-(void) endPanningObject:(id)obj{
    [leftHandLayer endPanningObject:obj];
}

#pragma mark - Drawing Events

-(void) startDrawingAtTouch:(UITouch*)touch{
    [leftHandLayer startDrawingAtTouch:touch];
}
-(void) continueDrawingAtTouch:(UITouch*)touch{
    [leftHandLayer continueDrawingAtTouch:touch];
}
-(void) endDrawingAtTouch:(UITouch*)touch{
    [leftHandLayer endDrawingAtTouch:touch];
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
