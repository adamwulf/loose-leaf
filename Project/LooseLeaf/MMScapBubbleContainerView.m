//
//  MMScapBubbleContainerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/31/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScapBubbleContainerView.h"
#import "MMScrapBubbleButton.h"
#import "NSThread+BlockAdditions.h"

@implementation MMScapBubbleContainerView{
    CGFloat lastRotationReading;
}

@synthesize delegate;

-(void) addScrapAnimated:(MMScrapView *)scrap{
    // exit the scrap to the bezel!
    CGRect rect = CGRectMake(668, 240, 80, 80);
    if([self.subviews count]){
        // put it below the most recent bubble
        // each bubble is ordered in subviews most recent -> least recent
        rect.origin.y += 80 * [self.subviews count];
    }
    MMScrapBubbleButton* bubble = [[MMScrapBubbleButton alloc] initWithFrame:rect];
    [bubble addTarget:self action:@selector(bubbleTapped:) forControlEvents:UIControlEventTouchUpInside];
    bubble.originalScrapScale = scrap.scale;
    [self insertSubview:bubble atIndex:0];
    [self insertSubview:scrap aboveSubview:bubble];
    // keep the scrap in the bezel container during the animation, then
    // push it into the bubble
    bubble.alpha = 0;
    bubble.rotation = lastRotationReading;
    bubble.scale = .9;
    CGFloat animationDuration = 0.5;
    [UIView animateWithDuration:animationDuration * .51 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate the scrap into position
        bubble.alpha = 1;
        scrap.transform = CGAffineTransformConcat([MMScrapBubbleButton idealTransformForScrap:scrap], CGAffineTransformMakeScale(bubble.scale, bubble.scale));
        scrap.center = bubble.center;
    } completion:^(BOOL finished){
        // add it to the bubble and bounce
        bubble.scrap = scrap;
        [UIView animateWithDuration:animationDuration * .2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // scrap "hits" the bubble and pushes it down a bit
            bubble.scale = .8;
        } completion:^(BOOL finished){
            [UIView animateWithDuration:animationDuration * .2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                // bounce back
                bubble.scale = 1.1;
            } completion:^(BOOL finished){
                [UIView animateWithDuration:animationDuration * .16 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    // and done
                    bubble.scale = 1.0;
                } completion:nil];
            }];
        }];
        
    }];
}

#pragma mark - Button Tap

-(void) bubbleTapped:(MMScrapBubbleButton*)bubble{
    MMScrapView* scrap = bubble.scrap;
    CGPoint centerInSelf = [self convertPoint:scrap.center fromView:scrap.superview];
    [self addSubview:scrap];
    scrap.center = centerInSelf;
    scrap.rotation += (bubble.rotation - bubble.rotationAdjustment);
    scrap.transform = CGAffineTransformConcat([MMScrapBubbleButton idealTransformForScrap:scrap], CGAffineTransformMakeScale(bubble.scale, bubble.scale));
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        scrap.center = self.center;
        [scrap setScale:bubble.originalScrapScale andRotation:scrap.rotation - .25];
        bubble.alpha = 0;
    } completion:^(BOOL finished){
        [bubble removeFromSuperview];
        [self.delegate didTapToAddScrapBackToPage:scrap];
    }];
}


#pragma mark - Rotation

-(CGFloat) sidebarButtonRotationForReading:(CGFloat)currentReading{
    return -(currentReading + M_PI/2);
}

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading andX:(CGFloat)xAccel andY:(CGFloat)yAccel andZ:(CGFloat)zAccel{
    if(1 - ABS(zAccel) > .03){
        [NSThread performBlockOnMainThread:^{
            lastRotationReading = [self sidebarButtonRotationForReading:currentRawReading];
            for(MMScrapBubbleButton* bubble in self.subviews){
                if([bubble isKindOfClass:[MMScrapBubbleButton class]]){
                    // during an animation, the scrap will also be a subview,
                    // so we need to make sure that we're rotating only the
                    // bubble button
                    bubble.rotation = [self sidebarButtonRotationForReading:currentRawReading];
                }
            }
        }];
    }
}


#pragma mark - Ignore Touches

/**
 * these two methods make sure that the ruler view
 * can never intercept any touch input. instead it will
 * effectively pass through this view to the views behind it
 */
-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    for(MMScrapBubbleButton* bubble in self.subviews){
        if([bubble isKindOfClass:[MMScrapBubbleButton class]]){
            UIView* output = [bubble hitTest:[self convertPoint:point toView:bubble] withEvent:event];
            if(output) return output;
        }
    }
    return nil;
}

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    for(MMScrapBubbleButton* bubble in self.subviews){
        if([bubble isKindOfClass:[MMScrapBubbleButton class]]){
            if([bubble pointInside:[self convertPoint:point toView:bubble] withEvent:event]){
                return YES;
            }
        }
    }
    return NO;
}


@end
