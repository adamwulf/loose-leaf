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
    MMHandPathHelper* pointerFingerHelper;
    MMTouchDotGestureRecognizer* touchGesture;
}



-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        
        // setup hand path
        pointerFingerHelper = [[MMHandPathHelper alloc] init];
        [self.layer addSublayer:pointerFingerHelper.handLayer];
        
        
        
        // to refactor
        touchGesture = [MMTouchDotGestureRecognizer sharedInstace];
        [touchGesture setTouchDelegate:self];
        [self.window addGestureRecognizer:touchGesture];
    }
    return self;
}



-(void) moveHandToTouch:(UITouch*)touch{
    
}

#pragma mark - MMTouchDotGestureRecognizerDelegate

-(void) dotTouchesBegan:(NSSet *)touches{
    pointerFingerHelper.handLayer.opacity = .5;
}

-(void) dotTouchesMoved:(NSSet *)touches{
    [pointerFingerHelper moveToTouch:[touches anyObject]];
}

-(void) dotTouchesEnded:(NSSet *)touches{
    pointerFingerHelper.handLayer.opacity = 0;
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
