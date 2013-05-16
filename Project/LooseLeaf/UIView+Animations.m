//
//  UIView+Animations.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/27/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "UIView+Animations.h"
#import <QuartzCore/QuartzCore.h>
#import "MMShadowedView.h"

@implementation UIView (Animations)

-(void) removeAllAnimationsAndPreservePresentationFrame{
    // look at the presentation of the view (as would be seen during animation)
    CGRect lFrame = [self.layer.presentationLayer frame];
    // look at the view frame to compare
    CGRect vFrame = self.frame;
    if([self isKindOfClass:[MMShadowedView class]]){
        vFrame = [MMShadowedView expandFrame:vFrame];
    }
    if(!CGRectEqualToRect(lFrame, vFrame) && !CGRectEqualToRect(lFrame, CGRectZero)){
        // if they're not equal, then remove all animations
        // and set the frame to the presentation layer's frame
        // so that the gesture will pick up in the middle
        // of the animation instead of immediately reset to
        // its end state
        self.frame = lFrame;
    }
    [self.layer removeAllAnimations];

}


@end
