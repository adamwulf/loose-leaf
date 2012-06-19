//
//  SLPaperStackView.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLPaperStackView.h"

@implementation SLPaperStackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self awakeFromNib];
    }
    return self;
}

-(void) awakeFromNib{
    visibleStack = [[NSMutableArray array] retain]; // use NSMutableArray stack additions
    hiddenStack = [[NSMutableArray array] retain]; // use NSMutableArray stack additions
    stackHolder = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:stackHolder];
    paperIcon = [[SLPaperIcon alloc] initWithFrame:CGRectMake(600, 460, 80, 80)];
    [self addSubview:paperIcon];
    plusIcon = [[SLPlusIcon alloc] initWithFrame:CGRectMake(680, 476, 46, 46)];
    [self addSubview:plusIcon];
    leftArrow = [[SLLeftArrow alloc] initWithFrame:CGRectMake(680, 420, 46, 46)];
    [self addSubview:leftArrow];
    rightArrow = [[SLRightArrow alloc] initWithFrame:CGRectMake(680, 530, 46, 46)];
    [self addSubview:rightArrow];
    
    boundsOfHiddenStack = self.bounds;
    boundsOfHiddenStack.origin.x += self.bounds.size.width;
    
    SLBezelInGestureRecognizer* bezelGesture = [[SLBezelInGestureRecognizer alloc] initWithTarget:self action:@selector(bezelIn:)];
    [bezelGesture setMinimumNumberOfTouches:2];
    [self addGestureRecognizer:bezelGesture];
    
}


-(void) bezelIn:(SLBezelInGestureRecognizer*)bezelGesture{
    debug_NSLog(@"bezel!");
}




/**
 * adds the page to the bottom of the stack
 * and adds to the bottom of the subviews
 */
-(void) addPaperToBottomOfStack:(SLPaperView*)page{
    page.delegate = self;
    if([visibleStack count]){
        [stackHolder insertSubview:page atIndex:0];
    }else{
        [stackHolder addSubview:page];
    }
    [visibleStack addToBottomOfStack:page];
}

/**
 * the input is a page in the visible stack,
 * and we pop all pages above but not including
 * the input page
 *
 * these pages will be pushed over to the invisible stack
 */
-(void) popStackUntilPage:(SLPaperView*)page{
    NSMutableArray* pagesToAnimate = [NSMutableArray array];
    if([visibleStack containsObject:page]){
        while([visibleStack peek] != page){
            [pagesToAnimate addObject:[visibleStack pop]];
        }
    }
    CGFloat delay = 0;
    for(SLPaperView* aPage in pagesToAnimate){
        [hiddenStack push:aPage];
        [UIView animateWithDuration:0.2 delay:delay options:UIViewAnimationOptionAllowUserInteraction
                         animations:^(void){
                             aPage.frame = boundsOfHiddenStack;
                             aPage.scale = 1;
                         } completion:^(BOOL finished){
                             [self insertSubview:aPage belowSubview:[self getPageBelow:aPage]];
                         }];
        delay += .1;
    }
}

-(SLPaperView*) getPageBelow:(SLPaperView*)page{
    if([visibleStack containsObject:page]){
        NSInteger index = [visibleStack indexOfObject:page];
        if(index != 0){
            return [visibleStack objectAtIndex:index-1];
        }
    }
    if([hiddenStack containsObject:page]){
        NSInteger index = [hiddenStack indexOfObject:page];
        if(index != 0){
            return [hiddenStack objectAtIndex:index-1];
        }
    }
    return nil;
}


#pragma mark - SLPaperViewDelegate

-(BOOL) allowsScaleForPage:(SLPaperView*)page{
    return [visibleStack peek] == page;
}

-(CGRect) isPanningAndScalingPage:(SLPaperView*)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame{
    if(page == [visibleStack peek]){
        
    }
    return toFrame;
}

-(void) finishedPanningAndScalingPage:(SLPaperView*)page
                            fromFrame:(CGRect)fromFrame
                              toFrame:(CGRect)toFrame
                         withVelocity:(CGPoint)velocity{
    
    if(page != [visibleStack peek]){
        SLPaperView* topPage = [visibleStack peek];
        if([topPage isBeingPannedAndZoomed]){
            return;
        }
    }else{
        // loop through all pages in stack
        // an pop the ones that aren't in view back to where they should be
        for(SLPaperView* page in [[visibleStack copy] autorelease]){
            if(page != [visibleStack peek]){
                if([page isBeingPannedAndZoomed]){
                    // TODO
                    debug_NSLog(@"pop stack until i see this page");
                    [self popStackUntilPage:page];
                    return;
                }else{
                    if(!CGRectEqualToRect(page.frame, self.bounds)){
                        debug_NSLog(@"moving a page back to where it should be");
                        page.frame = self.bounds;
                    }
                }
            }
        }
    }
    
    if(page.scale <= 1){
        //
        // bounce it back to full screen
        [self bouncePageToFullScreen:page];
    }else{
        //
        // the scale is larger than 1, so we may need
        // to slide the page with some inertia. if the page is
        // to far from an edge, then we need to move it to another stack.
        // if its not far enough to move, then we may need to bounce it
        // back to an edge.
        float inertiaSeconds = .3;
        CGPoint finalOrigin = CGPointMake(toFrame.origin.x + velocity.x * inertiaSeconds, toFrame.origin.y + velocity.y * inertiaSeconds);
        CGRect intertialFrame = toFrame;
        intertialFrame.origin = finalOrigin;

        
        if([self shouldInterialSlideThePage:page withFrame:intertialFrame]){
            
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut animations:^(void){
                page.frame = intertialFrame;
            } completion:nil];

        }else if([self shouldPopPageFromVisibleStack:page withFrame:toFrame]){
            
        }else if([self shouldPushPageOntoVisibleStack:page withFrame:toFrame]){
            
        }else{
            // bounce
            [self bouncePageToEdge:page toFrame:toFrame intertialFrame:intertialFrame];
        }
    }
}




#pragma mark - Page Animation and Navigation Helpers

-(BOOL) shouldInterialSlideThePage:(SLPaperView*)page withFrame:(CGRect)frame{
    if(frame.origin.y <= 0 && frame.origin.y + frame.size.height > self.superview.frame.size.height &&
       frame.origin.x <= 0 && frame.origin.x + frame.size.width > self.superview.frame.size.width){
        return YES;
    }
    return NO;
}

-(BOOL) shouldPopPageFromVisibleStack:(SLPaperView*)page withFrame:(CGRect)frame{
    return NO;
}
-(BOOL) shouldPushPageOntoVisibleStack:(SLPaperView*)page withFrame:(CGRect)frame{
    return NO;
}


#pragma mark - Page Animations


-(void) bouncePageToEdge:(SLPaperView*)page toFrame:(CGRect)toFrame intertialFrame:(CGRect)inertialFrame{
    //
    //
    // first, check to see if the frame is already out of bounds
    // the toFrame represents where the paper is pre-inertia, so if
    // the toFrame is wrong, then just animate it back to an edge straight away
    if(toFrame.origin.x > 0 || toFrame.origin.y > 0 || toFrame.origin.x + toFrame.size.width < self.superview.frame.size.width || toFrame.origin.y + toFrame.size.height < self.superview.frame.size.height){
        CGRect newInertialFrame = inertialFrame;
        if(inertialFrame.origin.x > 0){
            newInertialFrame.origin.x = 0;
        }
        if(inertialFrame.origin.y > 0){
            newInertialFrame.origin.y = 0;
        }
        if(inertialFrame.origin.x + inertialFrame.size.width < self.superview.frame.size.width){
            newInertialFrame.origin.x = self.superview.frame.size.width - toFrame.size.width;
        }
        if(inertialFrame.origin.y + inertialFrame.size.height < self.superview.frame.size.height){
            newInertialFrame.origin.y = self.superview.frame.size.height - toFrame.size.height;
        }
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut animations:^(void){
            page.frame = newInertialFrame;
        } completion:nil];
        return;
    }
    
    //
    // ok, the paper is currently in the correct view, but the inertia
    // will carry it to an invalid location. for this, lets get the inertia
    // to carry it a 10px difference, then bounce it back to the edige
    CGRect newInertiaFrame = inertialFrame;
    CGRect postInertialFrame = inertialFrame;
    if(inertialFrame.origin.x > 10){
        postInertialFrame.origin.x = 0;
        newInertiaFrame.origin.x = 10;
    }
    if(inertialFrame.origin.y > 10){
        postInertialFrame.origin.y = 0;
        newInertiaFrame.origin.y = 10;
    }
    if(inertialFrame.origin.x + inertialFrame.size.width < self.superview.frame.size.width - 10){
        postInertialFrame.origin.x = self.superview.frame.size.width - toFrame.size.width;
        newInertiaFrame.origin.x = postInertialFrame.origin.x - 10;
        
    }
    if(inertialFrame.origin.y + inertialFrame.size.height < self.superview.frame.size.height - 10){
        postInertialFrame.origin.y = self.superview.frame.size.height - toFrame.size.height;
        newInertiaFrame.origin.y = postInertialFrame.origin.y - 10;
    }
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut animations:^(void){
        page.frame = newInertiaFrame;
    } completion:^(BOOL finished){
        if(finished && !CGRectEqualToRect(newInertiaFrame, postInertialFrame)){
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction
                             animations:^(void){
                                 page.frame = postInertialFrame;
                             } completion:nil];
        }
    }];
}


/**
 * this animation will zoom the page back to scale of 1 and match it
 * perfect to the screensize.
 *
 * it'll also add a small bounce to the animation for effect
 *
 * this animation is interruptable
 */
-(void) bouncePageToFullScreen:(SLPaperView*)page{
    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionAllowUserInteraction
                     animations:^(void){
                         page.scale = 1;
                         CGRect bounceFrame = self.bounds;
                         bounceFrame.origin.x = bounceFrame.origin.x-10;
                         bounceFrame.origin.y = bounceFrame.origin.y-10;
                         bounceFrame.size.width = bounceFrame.size.width+10*2;
                         bounceFrame.size.height = bounceFrame.size.height+10*2;
                         page.frame = bounceFrame;
                     } completion:^(BOOL finished){
                         if(finished){
                             [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionAllowUserInteraction
                                              animations:^(void){
                                                  page.frame = self.bounds;
                                                  page.scale = 1;
                                              } completion:nil];
                         }
                     }];
}


@end
