//
//  MMSilhouetteView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/12/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMShadowHandView.h"
#import "MMDrawingGestureShadow.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "UIView+Debug.h"
#import "MMTwoFingerPanShadow.h"
#import "MMTouchDotGestureRecognizer.h"
#import "NSThread+BlockAdditions.h"
#import "UITouch+Distance.h"
#import "MMVector.h"
#import "MMShadowHand.h"

@implementation MMShadowHandView{
    MMDrawingGestureShadow* pointerFingerHelper;
//    UISlider* slider;
    MMShadowHand* rightHand;
    MMShadowHand* leftHand;
}



-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        leftHand = [[MMShadowHand alloc] initForRightHand:NO forView:self];
        rightHand = [[MMShadowHand alloc] initForRightHand:YES forView:self];
        
        
//        slider = [[UISlider alloc] initWithFrame:CGRectMake(450, 50, 200, 40)];
//        slider.value = 1;
//        slider.minimumValue = 0;
//        slider.maximumValue = 1;
//        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
//        [[NSThread mainThread] performBlock:^{
//            [self.window addSubview:slider];
//        } afterDelay:.3];
        
        
        [self.layer addSublayer:leftHand.layer];
        [self.layer addSublayer:rightHand.layer];
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

-(void) startBezelingInFromRight:(BOOL)fromRight withTouches:(NSArray*)touches{
    [leftHand startBezelingInFromRight:fromRight withTouches:touches];
}

-(void) continueBezelingInFromRight:(BOOL)fromRight withTouches:(NSArray*)touches{
    [leftHand continueBezelingInFromRight:fromRight withTouches:touches];
}

-(void) endBezelingInFromRight:(BOOL)fromRight withTouches:(NSArray*)touches{
    [leftHand endBezelingInFromRight:fromRight withTouches:touches];
}


#pragma mark - Panning a Page

-(void) startPanningObject:(id)obj withTouches:(NSArray*)touches{
    [leftHand startPanningObject:obj withTouches:touches];
}

-(void) continuePanningObject:(id)obj withTouches:(NSArray*)touches{
    [leftHand continuePanningObject:obj withTouches:touches];
}

-(void) endPanningObject:(id)obj{
    [leftHand endPanningObject:obj];
}

#pragma mark - Drawing Events

-(void) startDrawingAtTouch:(UITouch*)touch{
    [rightHand startDrawingAtTouch:touch];
}
-(void) continueDrawingAtTouch:(UITouch*)touch{
    [rightHand continueDrawingAtTouch:touch];
}
-(void) endDrawingAtTouch:(UITouch*)touch{
    [rightHand endDrawingAtTouch:touch];
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
