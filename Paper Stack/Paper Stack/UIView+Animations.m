//
//  UIView+Animations.m
//  scratchpaper
//
//  Created by Adam Wulf on 6/27/12.
//
//

#import "UIView+Animations.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Animations)

-(void) removeAllAnimationsAndPreservePresentationFrame{
    // look at the presentation of the view (as would be seen during animation)
    CGRect lFrame = [self.layer.presentationLayer frame];
    // look at the view frame to compare
    CGRect vFrame = self.frame;
    if(!CGRectEqualToRect(lFrame, vFrame)){
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
