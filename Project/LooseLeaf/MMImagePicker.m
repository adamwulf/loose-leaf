//
//  MMImagePicker.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMImagePicker.h"
#import "UIView+Animations.h"

#define kAnimationDuration .3

@implementation MMImagePicker{
    MMSidebarImagePicker* sidebar;
    UIButton* dismissButton;
    BOOL directionIsFromLeft;
}

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton*)_button animateFromLeft:(BOOL)fromLeft{
    self = [super initWithFrame:frame];
    if (self) {
        
        directionIsFromLeft = fromLeft;
        
        // Initialization code
        dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissButton.frame = self.bounds;
        [dismissButton addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dismissButton];
        
        CGRect imagePickerBounds = self.bounds;
        imagePickerBounds.size.width = ceilf(imagePickerBounds.size.width / 2) + 2*kBounceWidth;
        sidebar = [[MMSidebarImagePicker alloc] initWithFrame:imagePickerBounds forButton:_button animateFromLeft:directionIsFromLeft];
        sidebar.delegate = self;
        [self addSubview:sidebar];
        
        self.clipsToBounds = YES;
        
        [UIView setAnchorPoint:CGPointZero forView:sidebar];
        
        [self hide:NO];
    }
    return self;
}

#pragma mark - Show and Hide

-(BOOL) isVisible{
    return (BOOL) dismissButton.alpha;
}

-(void) hide:(BOOL)animated{
    if(![self isVisible]) return;
    void (^hideBlock)(void) = ^{
        dismissButton.alpha = 0;
        CGRect imagePickerBounds = self.bounds;
        imagePickerBounds.size.width = ceilf(imagePickerBounds.size.width / 2) + 2*kBounceWidth;
        if(directionIsFromLeft){
            imagePickerBounds.origin.x = -imagePickerBounds.size.width;
        }else{
            imagePickerBounds.origin.x = self.bounds.size.width;
        }
        sidebar.frame = imagePickerBounds;
    };
    
    if(animated){
        [UIView animateWithDuration:kAnimationDuration animations:hideBlock];
    }else{
        hideBlock();
    }
}

-(void) show:(BOOL)animated{
    if([self isVisible]) return;
    void (^hideBlock)(void) = ^{
        dismissButton.alpha = 1;
    };
    
    if(animated){
        [CATransaction begin];
        
        ////////////////////////////////////////////////////////
        // Animate the sidebar!

        CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        bounceAnimation.removedOnCompletion = YES;
        bounceAnimation.keyTimes = [NSArray arrayWithObjects:
                                    [NSNumber numberWithFloat:0.0],
                                    [NSNumber numberWithFloat:0.7],
                                    [NSNumber numberWithFloat:.90], nil];
        if(directionIsFromLeft){
            bounceAnimation.values = [NSArray arrayWithObjects:
                                      [NSValue valueWithCGPoint:CGPointMake(-sidebar.frame.size.width, 0)],
                                      [NSValue valueWithCGPoint:CGPointMake(0, 0)],
                                      [NSValue valueWithCGPoint:CGPointMake(-kBounceWidth, 0)], nil];
        }else{
            bounceAnimation.values = [NSArray arrayWithObjects:
                                      [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width, 0)],
                                      [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width-sidebar.frame.size.width, 0)],
                                      [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width-sidebar.frame.size.width+kBounceWidth, 0)], nil];
        }
        bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
                                           [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                           [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], nil];
        [bounceAnimation setDuration:kAnimationDuration];

        
        ////////////////////////////////////////////////////////
        // Animate opacity of the full screen dismiss button!
        
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.removedOnCompletion = YES;
        [opacityAnimation setToValue:[NSNumber numberWithFloat:0.0]];
        [opacityAnimation setDuration:kAnimationDuration];

        ////////////////////////////////////////////////////////
        // Animate bounce of sidebar button
        
        [sidebar bounceAnimationForButtonWithDuration:kAnimationDuration];
        
        ///////////////////////////////////////////////
        // Add the animations to the layers
        [sidebar.layer addAnimation:bounceAnimation forKey:@"showImagePicker"];
        
        [dismissButton.layer addAnimation:opacityAnimation forKey:@"alpha"];
        
        
        [CATransaction commit];
        
    }
    hideBlock();
    
    CGRect fr = sidebar.frame;
    if(directionIsFromLeft){
        fr.origin = CGPointMake(-kBounceWidth, 0);
    }else{
        fr.origin = CGPointMake(self.bounds.size.width-sidebar.frame.size.width+kBounceWidth, 0);
    }
    sidebar.frame = fr;
}



#pragma mark - Ignore Touches

/**
 * these two methods make sure that the ruler view
 * can never intercept any touch input. instead it will
 * effectively pass through this view to the views behind it
 */
-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if(![self isVisible]){
        return nil;
    }
    return [super hitTest:point withEvent:event];
}

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if(![self isVisible]){
        return NO;
    }
    return [super pointInside:point withEvent:event];
}

#pragma mark - MMSidebarImagePickerDelegate

-(void) sidebarCloseButtonWasTapped{
    [self hide:YES];
}


@end
