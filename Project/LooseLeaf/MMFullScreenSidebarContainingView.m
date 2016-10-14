//
//  MMSlidingSidebarView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMFullScreenSidebarContainingView.h"
#import "UIView+Animations.h"
#import "Constants.h"

#define kAnimationDuration 0.3


@implementation MMFullScreenSidebarContainingView {
    UIButton* dismissButton;
    BOOL directionIsFromLeft;
}

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton*)_button animateFromLeft:(BOOL)fromLeft {
    self = [super initWithFrame:frame];
    if (self) {
        // this direction controls if the sidebar will slide from the left or right
        directionIsFromLeft = fromLeft;

        // this button is full screen and invisible, and will
        // handle any touches not in the sidebar
        dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissButton.frame = self.bounds;
        [dismissButton addTarget:self action:@selector(sidebarCloseButtonWasTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dismissButton];

        // the sidebar content view will hold all of the content and menus
        CGRect imagePickerBounds = [self defaultSidebarFrame];
        slidingSidebarView = [[MMSlidingSidebarView alloc] initWithFrame:imagePickerBounds forButton:_button animateFromLeft:directionIsFromLeft];
        slidingSidebarView.delegate = self;
        [self addSubview:slidingSidebarView];

        // a few properties on the view for clarity
        self.clipsToBounds = YES;
        self.opaque = NO;

        // set the anchor to 0,0 for the sliding animations
        [UIView setAnchorPoint:CGPointZero forView:slidingSidebarView];

        // init the view positions
        [self hide:NO onComplete:nil];
    }
    return self;
}

- (void)setDelegate:(NSObject<MMSlidingSidebarContainerViewDelegate>*)_delegate {
    delegate = _delegate;
    slidingSidebarView.delegate = self;
}

#pragma mark - Show and Hide

// YES if we're showing the sidebar menu,
// NO otherwise
- (BOOL)isVisible {
    return (BOOL)dismissButton.alpha;
}

// hide the sidebar and optionally
// animate the change
- (void)hide:(BOOL)animated onComplete:(void (^)(BOOL finished))onComplete {
    // ignore if we're hidden
    if (![self isVisible]) {
        if (onComplete)
            onComplete(YES);
        return;
    }

    void (^realComplete)(BOOL) = ^(BOOL finished) {
        if (finished) {
            CGRect fr = slidingSidebarView.frame;
            if (directionIsFromLeft) {
                fr.origin.x = -fr.size.width;
                slidingSidebarView.frame = fr;
            } else {
                fr.origin.x = self.bounds.size.width;
                slidingSidebarView.frame = fr;
            }
            [slidingSidebarView didHide];
        }
        if (onComplete)
            onComplete(finished);
    };

    [delegate sidebarWillHide:self];
    // keep our property changes in a block
    // to pass to UIView or just run
    void (^hideBlock)(void) = ^{
        // this button's alpha determines our
        // visibility property
        dismissButton.alpha = 0;
        // animate the position of the sidebar offscreen
        CGRect imagePickerBounds = [self defaultSidebarFrame];
        if (directionIsFromLeft) {
            imagePickerBounds.origin.x = -imagePickerBounds.size.width / 4.0;
        } else {
            imagePickerBounds.origin.x = self.bounds.size.width - imagePickerBounds.size.width * 3.0 / 4.0;
        }
        slidingSidebarView.frame = imagePickerBounds;
        slidingSidebarView.alpha = 0;
        [slidingSidebarView hideAnimation];
    };

    if (animated) {
        [UIView animateWithDuration:kAnimationDuration animations:hideBlock completion:realComplete];
    } else {
        hideBlock();
        realComplete(YES);
    }
}

- (void)show:(BOOL)animated {
    // ignore if we're already visible
    if ([self isVisible])
        return;

    [delegate sidebarWillShow:self];

    if (animated) {
        CGRect fr = slidingSidebarView.frame;
        if (directionIsFromLeft) {
            fr.origin = CGPointMake(-slidingSidebarView.frame.size.width, 0);
        } else {
            fr.origin = CGPointMake(self.bounds.size.width, 0);
        }
        slidingSidebarView.frame = fr;


        slidingSidebarView.alpha = 0;
        [slidingSidebarView willShow];

        [CATransaction begin];

        ////////////////////////////////////////////////////////
        // Animate the sidebar!

        CAKeyframeAnimation* bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        bounceAnimation.removedOnCompletion = YES;
        bounceAnimation.keyTimes = [NSArray arrayWithObjects:
                                                [NSNumber numberWithFloat:0.0],
                                                [NSNumber numberWithFloat:0.7],
                                                [NSNumber numberWithFloat:1.0], nil];
        if (directionIsFromLeft) {
            bounceAnimation.values = [NSArray arrayWithObjects:
                                                  [NSValue valueWithCGPoint:CGPointMake(-slidingSidebarView.frame.size.width, 0)],
                                                  [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                                                  [NSValue valueWithCGPoint:CGPointMake(-kBounceWidth, 0)], nil];
        } else {
            bounceAnimation.values = [NSArray arrayWithObjects:
                                                  [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width, 0)],
                                                  [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width - slidingSidebarView.frame.size.width, 0)],
                                                  [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width - slidingSidebarView.frame.size.width + kBounceWidth, 0)], nil];
        }
        bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
                                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], nil];
        [bounceAnimation setDuration:kAnimationDuration];

        CABasicAnimation* opacityAnimation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation2.removedOnCompletion = YES;
        [opacityAnimation2 setFromValue:[NSNumber numberWithFloat:0.0]];
        [opacityAnimation2 setToValue:[NSNumber numberWithFloat:1.0]];
        [opacityAnimation2 setDuration:kAnimationDuration * 2.0 / 3.0];

        CAAnimationGroup* gr = [CAAnimationGroup animation];
        gr.animations = @[bounceAnimation, opacityAnimation2];
        gr.duration = kAnimationDuration;


        ////////////////////////////////////////////////////////
        // Animate opacity of the full screen dismiss button!

        CABasicAnimation* opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.removedOnCompletion = YES;
        [opacityAnimation setFromValue:[NSNumber numberWithFloat:1.0]];
        [opacityAnimation setToValue:[NSNumber numberWithFloat:0.0]];
        [opacityAnimation setDuration:kAnimationDuration];

        ///////////////////////////////////////////////
        // Add the animations to the layers
        [slidingSidebarView.layer addAnimation:gr forKey:@"showImagePicker"];

        [dismissButton.layer addAnimation:opacityAnimation forKey:@"alpha"];

        [slidingSidebarView showForDuration:kAnimationDuration];

        [CATransaction commit];
    }

    // set all of the properties. if we're animating
    // these will affect only take effect after the
    // animation completes. notice the removedOnCompletion
    // on the animations
    slidingSidebarView.alpha = 1;
    dismissButton.alpha = 1;
    CGRect fr = slidingSidebarView.frame;
    if (directionIsFromLeft) {
        fr.origin = CGPointMake(-kBounceWidth, 0);
    } else {
        fr.origin = CGPointMake(self.bounds.size.width - slidingSidebarView.frame.size.width + kBounceWidth, 0);
    }
    slidingSidebarView.frame = fr;
}


#pragma mark - Helper Methods

- (CGRect)defaultSidebarFrame {
    CGRect imagePickerBounds = self.bounds;
    CGFloat imagePickerWidth = MIN(CGRectGetWidth(imagePickerBounds), 768);
    imagePickerBounds.size.width = ceilf(imagePickerWidth / 2) + 2 * kBounceWidth;
    return imagePickerBounds;
}

#pragma mark - Ignore Touches

/**
 * these two methods make sure that the ruler view
 * can never intercept any touch input. instead it will
 * effectively pass through this view to the views behind it
 */
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
    if (![self isVisible]) {
        return nil;
    }
    return [super hitTest:point withEvent:event];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    if (![self isVisible]) {
        return NO;
    }
    return [super pointInside:point withEvent:event];
}

#pragma mark - MMSidebarImagePickerDelegate

- (void)sidebarCloseButtonWasTapped {
    if ([self isVisible]) {
        [self hide:YES onComplete:nil];
        [self.delegate sidebarCloseButtonWasTapped:self];
    }
}

- (UIView*)viewForBlur {
    return delegate.viewForBlur;
}

@end
