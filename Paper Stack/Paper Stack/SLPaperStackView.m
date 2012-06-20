//
//  SLPaperStackView.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLPaperStackView.h"
#import <QuartzCore/QuartzCore.h>

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
    
    frameOfHiddenStack = self.bounds;
    frameOfHiddenStack.origin.x += self.bounds.size.width;
    
    fromRightBezelGesture = [[SLBezelInGestureRecognizer alloc] initWithTarget:self action:@selector(bezelIn:)];
    [fromRightBezelGesture setBezelDirectionMask:SLBezelDirectionFromRightBezel];
    [fromRightBezelGesture setMinimumNumberOfTouches:2];
    [self addGestureRecognizer:fromRightBezelGesture];
}

-(void) bezelIn:(SLBezelInGestureRecognizer*)bezelGesture{
    SLPaperView* page = [hiddenStack peek];
    if(!page){
        page = [[SLPaperView alloc] initWithFrame:frameOfHiddenStack];
        page.delegate = self;
        [stackHolder addSubview:page];
        [hiddenStack addToBottomOfStack:page];
    }
    CGPoint translation = [bezelGesture translationInView:self];
    if([self.subviews lastObject] != [hiddenStack peek]){
        // make sure the top of the hidden stack is the front most view
        // in our stack ui, so that it'll show up when we scroll it on top
        // of the visible stack
        [stackHolder addSubview:[hiddenStack peek]];
    }
    
    if(bezelGesture.state == UIGestureRecognizerStateBegan){
        [[visibleStack peek] disableAllGestures];
    }else if(bezelGesture.state == UIGestureRecognizerStateCancelled ||
       bezelGesture.state == UIGestureRecognizerStateFailed){
        [self animateBackToHiddenStack:page withDelay:0];
        [[visibleStack peek] enableAllGestures];
    }else if(bezelGesture.state == UIGestureRecognizerStateEnded &&
             ((bezelGesture.panDirection & SLBezelDirectionLeft) == SLBezelDirectionLeft)){
        [[visibleStack peek] enableAllGestures];
        [self popHiddenStackUntilPage:[self getPageBelow:page]]; 
    }else if(bezelGesture.state == UIGestureRecognizerStateEnded){
        [self animateBackToHiddenStack:page withDelay:0];
        [[visibleStack peek] enableAllGestures];
    }else{
        CGRect newFrame = CGRectMake(frameOfHiddenStack.origin.x + translation.x,
                                     frameOfHiddenStack.origin.y,
                                     frameOfHiddenStack.size.width,
                                     frameOfHiddenStack.size.height);
        page.frame = newFrame;
        
        // in some cases, the top page on the visible stack will
        // think it's also being panned at the same time as this bezel
        // gesture
        //
        // double check and cancel it if needbe.
        SLPaperView* topPage = [visibleStack peek];
        if([topPage isBeingPannedAndZoomed]){
            [topPage cancelAllGestures];
        }
    }
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

-(void) sendPageToHiddenStack:(SLPaperView*)page{
    if([visibleStack containsObject:page]){
        [page disableAllGestures];
        [hiddenStack push:page];
        [visibleStack removeObject:page];
        [self animateBackToHiddenStack:page withDelay:0];
    }
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
    if([visibleStack containsObject:page] || page == nil){
        while([visibleStack peek] != page && [visibleStack count]){
            [pagesToAnimate addObject:[visibleStack pop]];
        }
    }
    CGFloat delay = 0;
    for(SLPaperView* aPage in pagesToAnimate){
        [aPage disableAllGestures];
        [hiddenStack push:aPage];
        [self animateBackToHiddenStack:aPage withDelay:delay];
        delay += .1;
    }
}

/**
 * the input is a page in the visible stack,
 * and we pop all pages above but not including
 * the input page
 *
 * these pages will be pushed over to the invisible stack
 */
-(void) popHiddenStackUntilPage:(SLPaperView*)page{
    NSMutableArray* pagesToAnimate = [NSMutableArray array];
    if([hiddenStack containsObject:page] || page == nil){
        while([hiddenStack peek] != page && [hiddenStack count]){
            [pagesToAnimate addObject:[hiddenStack pop]];
        }
    }
    CGFloat delay = 0;
    for(SLPaperView* aPage in pagesToAnimate){
        [visibleStack push:aPage];
        [aPage enableAllGestures];
        [self animatePageToFullScreen:aPage withDelay:delay withBounce:YES];
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
                            intoBezel:(SLBezelDirection)bezelDirection
                            fromFrame:(CGRect)fromFrame
                              toFrame:(CGRect)toFrame
                         withVelocity:(CGPoint)velocity{

    //
    // first, check if they panned the page into the bezel
    if((bezelDirection & SLBezelDirectionRight) == SLBezelDirectionRight){
        [self sendPageToHiddenStack:page];
        return;
    }

    //
    // next, check if the page is the top of the visible stack or not
    if(page == [visibleStack peek]){
        //
        // if they finished panning the page on the top of the stack,
        // then we need to reset any pages that they had moved below
        // that top most page.
        //
        //
        // if they are still panning and scaling a page that's /below/
        // the top page they just released, then we need to pop every
        // page up to that page they're still holding on to.
        //
        // otherwise, we need to just reset all pages in the stack
        // to be neatly stacked instead of spread out wherever the user
        // may have put them
        for(SLPaperView* page in [[visibleStack copy] autorelease]){
            if(page != [visibleStack peek]){
                if([page isBeingPannedAndZoomed]){
                    // TODO
                    //                    debug_NSLog(@"pop stack until i see this page");
                    [self popStackUntilPage:page];
                    return;
                }else{
                    if(!CGRectEqualToRect(page.frame, self.bounds)){
                        //                        debug_NSLog(@"moving a page back into stack");
                        page.frame = self.bounds;
                    }
                }
            }
        }
    }else{
        SLPaperView* topPage = [visibleStack peek];
        if([topPage isBeingPannedAndZoomed]){
            return;
        }
    }
    
    if(page.scale <= 1){
        //
        // bounce it back to full screen
        [self animatePageToFullScreen:page withDelay:0 withBounce:YES];
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
-(void) animatePageToFullScreen:(SLPaperView*)page withDelay:(CGFloat)delay withBounce:(BOOL)bounce{
    if(bounce){
        [UIView animateWithDuration:.15 delay:delay options:UIViewAnimationOptionAllowUserInteraction
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
    }else{
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionAllowUserInteraction
                         animations:^(void){
                             page.frame = self.bounds;
                             page.scale = 1;
                         } completion:nil];
    }
}



/**
 * this will animate a page onto the hidden stack
 * after the input delay, if any
 */
-(void) animateBackToHiddenStack:(SLPaperView*)page withDelay:(CGFloat)delay{
    [UIView animateWithDuration:0.2 delay:delay options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         page.frame = frameOfHiddenStack;
                         page.scale = 1;
                     } completion:^(BOOL finished){
                         [stackHolder insertSubview:page belowSubview:[self getPageBelow:page]];
                     }];
}


@end
