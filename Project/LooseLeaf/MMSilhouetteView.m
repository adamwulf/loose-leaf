//
//  MMSilhouetteView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/12/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMSilhouetteView.h"
#import "MMHandPathHelper.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "UIView+Debug.h"
#import "MMTouchDotGestureRecognizer.h"

@implementation MMSilhouetteView{
    MMHandPathHelper* handPathHelper;
    MMTouchDotGestureRecognizer* touchGesture;
    CAShapeLayer* handLayer;
}



-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        // noop
        handPathHelper = [[MMHandPathHelper alloc] init];
        
        touchGesture = [MMTouchDotGestureRecognizer sharedInstace];
        [touchGesture setTouchDelegate:self];
        [self.window addGestureRecognizer:touchGesture];
        
        
        
        UIBezierPath* handPath = handPathHelper.pointerFingerPath;
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        
        
        handLayer = [CAShapeLayer layer];
        handLayer.opacity = 0;
        handLayer.anchorPoint = CGPointZero;
        handLayer.position = CGPointZero;
        handLayer.backgroundColor = [UIColor blackColor].CGColor;
        handLayer.path = handPath.CGPath;
        
        NSLog(@"size of path: %f %f %f %f", handPath.bounds.origin.x, handPath.bounds.origin.y,
              handPath.bounds.size.width, handPath.bounds.size.height);
        NSLog(@"size of layer: %f %f %f %f", handLayer.bounds.origin.x, handLayer.bounds.origin.y,
              handLayer.bounds.size.width, handLayer.bounds.size.height);
        
        self.layer.backgroundColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:handLayer];
        
        // change properties here without animation
        [CATransaction commit];

    }
    return self;
}



-(void) moveHandToTouch:(UITouch*)touch{
    
}

#pragma mark - MMTouchDotGestureRecognizerDelegate

-(void) dotTouchesBegan:(NSSet *)touches{
    handLayer.opacity = .5;
}

-(void) dotTouchesMoved:(NSSet *)touches{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

    CGPoint locationOfTouch = [[touches anyObject] locationInView:self];
    CGPoint offset = handPathHelper.currentOffset;
    CGPoint finalLocation = CGPointMake(locationOfTouch.x - offset.x, locationOfTouch.y - offset.y);
    handLayer.position = finalLocation;
    
    [CATransaction commit];
}

-(void) dotTouchesEnded:(NSSet *)touches{
    handLayer.opacity = 0;
}

-(void) dotTouchesCancelled:(NSSet *)touches{
    
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


@end
