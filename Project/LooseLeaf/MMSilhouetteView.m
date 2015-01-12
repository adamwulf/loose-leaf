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
#import "MMTouchDotGestureRecognizer.h"

@implementation MMSilhouetteView{
    MMDrawingGestureSilhouette* pointerFingerHelper;
}



-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        // setup hand path
        pointerFingerHelper = [[MMDrawingGestureSilhouette alloc] init];
        [self.layer addSublayer:pointerFingerHelper.handLayer];
    }
    return self;
}



#pragma mark - incoming drawing events

-(void) startDrawingAtTouch:(UITouch*)touch{
    [self continueDrawingAtTouch:touch];
    pointerFingerHelper.handLayer.opacity = .5;
}
-(void) continueDrawingAtTouch:(UITouch*)touch{
    [pointerFingerHelper moveToTouch:touch];
}
-(void) endDrawingAtTouch:(UITouch*)touch{
    pointerFingerHelper.handLayer.opacity = 0;
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
