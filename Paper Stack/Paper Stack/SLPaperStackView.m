//
//  SLPaperStackView.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLPaperStackView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+SubviewStacks.h"
#import "Constants.h"

@implementation SLPaperStackView

@synthesize stackHolder = visibleStackHolder;

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
    setOfPagesBeingPanned = [[NSMutableSet alloc] init]; // use this as a quick cache of pages being panned
    visibleStackHolder = [[UIView alloc] initWithFrame:self.bounds];
    hiddenStackHolder = [[UIView alloc] initWithFrame:self.bounds];
    CGRect frameOfHiddenStack = hiddenStackHolder.frame;
    frameOfHiddenStack.origin.x += hiddenStackHolder.bounds.size.width;
    hiddenStackHolder.frame = frameOfHiddenStack;
    
    //
    // icons for moving and panning pages
    [self addSubview:visibleStackHolder];
    [self addSubview:hiddenStackHolder];
    papersIcon = [[SLPapersIcon alloc] initWithFrame:CGRectMake(600, 460, 80, 80)];
    [self addSubview:papersIcon];
    paperIcon = [[SLPaperIcon alloc] initWithFrame:CGRectMake(600, 460, 80, 80)];
    [self addSubview:paperIcon];
    plusIcon = [[SLPlusIcon alloc] initWithFrame:CGRectMake(540, 476, 46, 46)];
    [self addSubview:plusIcon];
    leftArrow = [[SLLeftArrow alloc] initWithFrame:CGRectMake(540, 476, 46, 46)];
    [self addSubview:leftArrow];
    rightArrow = [[SLRightArrow alloc] initWithFrame:CGRectMake(680, 476, 46, 46)];
    [self addSubview:rightArrow];
    papersIcon.alpha = 0;
    paperIcon.alpha = 0;
    leftArrow.alpha = 0;
    rightArrow.alpha = 0;
    plusIcon.alpha = 0;
    
    //
    // bezel gesture
    fromRightBezelGesture = [[SLBezelInGestureRecognizer alloc] initWithTarget:self action:@selector(bezelIn:)];
    [fromRightBezelGesture setBezelDirectionMask:SLBezelDirectionFromRightBezel];
    [fromRightBezelGesture setMinimumNumberOfTouches:2];
    [self addGestureRecognizer:fromRightBezelGesture];
}

-(SLPaperView*) ensureTopPageInHiddenStack{
    SLPaperView* page = [hiddenStackHolder peekSubview];
    if(!page){
        page = [[SLPaperView alloc] initWithFrame:hiddenStackHolder.bounds];
        page.isBrandNewPage = YES;
        page.delegate = self;
        [hiddenStackHolder addSubviewToBottomOfStack:page];
    }
    return page;
}

-(void) bezelIn:(SLBezelInGestureRecognizer*)bezelGesture{
    SLPaperView* page = [self ensureTopPageInHiddenStack];
    CGPoint translation = [bezelGesture translationInView:self];

    if(bezelGesture.state == UIGestureRecognizerStateBegan){
        [[visibleStackHolder peekSubview] disableAllGestures];
        [UIView animateWithDuration:.2 animations:^{
            CGRect newFrame = CGRectMake(hiddenStackHolder.bounds.origin.x + translation.x - kFingerWidth,
                                         hiddenStackHolder.bounds.origin.y,
                                         hiddenStackHolder.bounds.size.width,
                                         hiddenStackHolder.bounds.size.height);
            page.frame = newFrame;
        }];
    }else if(bezelGesture.state == UIGestureRecognizerStateCancelled ||
       bezelGesture.state == UIGestureRecognizerStateFailed){
        [self animateBackToHiddenStack:page withDelay:0];
        [[visibleStackHolder peekSubview] enableAllGestures];
    }else if(bezelGesture.state == UIGestureRecognizerStateEnded &&
             ((bezelGesture.panDirection & SLBezelDirectionLeft) == SLBezelDirectionLeft)){
        [[visibleStackHolder peekSubview] enableAllGestures];
        [self popTopPageOfHiddenStack]; 
    }else if(bezelGesture.state == UIGestureRecognizerStateEnded){
        [self animateBackToHiddenStack:page withDelay:0];
        [[visibleStackHolder peekSubview] enableAllGestures];
    }else{
        CGRect newFrame = CGRectMake(hiddenStackHolder.bounds.origin.x + translation.x - kFingerWidth,
                                     hiddenStackHolder.bounds.origin.y,
                                     hiddenStackHolder.bounds.size.width,
                                     hiddenStackHolder.bounds.size.height);
        page.frame = newFrame;
        
        // in some cases, the top page on the visible stack will
        // think it's also being panned at the same time as this bezel
        // gesture
        //
        // double check and cancel it if needbe.
        SLPaperView* topPage = [visibleStackHolder peekSubview];
        if([topPage isBeingPannedAndZoomed]){
            [topPage cancelAllGestures];
        }
    }
    [self updateIconAnimations];
}


-(void) popTopPageOfHiddenStack{
    [self ensureTopPageInHiddenStack];
    SLPaperView* page = [hiddenStackHolder peekSubview];
    page.isBrandNewPage = NO;
    [self popHiddenStackUntilPage:[self getPageBelow:page]]; 
}



/**
 * adds the page to the bottom of the stack
 * and adds to the bottom of the subviews
 */
-(void) addPaperToBottomOfStack:(SLPaperView*)page{
    page.isBrandNewPage = NO;
    page.delegate = self;
    [page enableAllGestures];
    [visibleStackHolder addSubviewToBottomOfStack:page];
}

-(void) sendPageToHiddenStack:(SLPaperView*)page{
    if([visibleStackHolder.subviews containsObject:page]){
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
    if([visibleStackHolder.subviews containsObject:page] || page == nil){
        CGFloat delay = 0;
        NSArray* pages = [visibleStackHolder peekSubviewFromSubview:page];
        for(SLPaperView* pageToPop in [pages reverseObjectEnumerator]){
            [self animateBackToHiddenStack:pageToPop withDelay:delay];
            delay += .1;
        }
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
    if([hiddenStackHolder.subviews containsObject:page] || page == nil){
        CGFloat delay = 0;
        while([hiddenStackHolder peekSubview] != page && [hiddenStackHolder.subviews count]){
            //
            // since we're manually popping the stack outside of an
            // animation, we need to make sure the page still exists
            // inside a stack.
            //
            // when the animation completes, it'll validate which stack
            // it's in anyways
            SLPaperView* aPage = [hiddenStackHolder peekSubview];
            //
            // this push will also pop it off the visible stack, and adjust the frame
            // correctly
            [aPage enableAllGestures];
            [visibleStackHolder pushSubview:aPage];
            [self animatePageToFullScreen:aPage withDelay:delay withBounce:YES];
            delay += .1;
        }
    }
}


-(SLPaperView*) getPageBelow:(SLPaperView*)page{
    if([visibleStackHolder.subviews containsObject:page]){
        NSInteger index = [visibleStackHolder.subviews indexOfObject:page];
        if(index != 0){
            return [visibleStackHolder.subviews objectAtIndex:index-1];
        }
    }
    if([hiddenStackHolder.subviews containsObject:page]){
        NSInteger index = [hiddenStackHolder.subviews indexOfObject:page];
        if(index != 0){
            return [hiddenStackHolder.subviews objectAtIndex:index-1];
        }
    }
    return nil;
}


#pragma mark - SLPaperViewDelegate

/**
 * let's only allow scaling the top most page
 */
-(BOOL) allowsScaleForPage:(SLPaperView*)page{
    return [visibleStackHolder peekSubview] == page;
}

/**
 * we need to update the icons that are visible
 * depending on the locations of the pages that are
 * currently being panned and scaled
 */
-(void) updateIconAnimations{
    BOOL bezelingFromRight = fromRightBezelGesture.state == UIGestureRecognizerStateBegan || fromRightBezelGesture.state == UIGestureRecognizerStateChanged;
    BOOL showLeftArrow = NO;
    BOOL topPageIsExitingBezel = [[visibleStackHolder peekSubview] willExitBezel];
    BOOL nonTopPageIsExitingBezel = inProgressOfBezeling != [visibleStackHolder peekSubview] && [inProgressOfBezeling willExitBezel];
    NSInteger numberOfVisiblePagesThatAreNotAligned = 0;
    for(int i=[visibleStackHolder.subviews count]-1; i>=0 && i>[visibleStackHolder.subviews count]-4;i--){
        SLPaperView* page = [visibleStackHolder.subviews objectAtIndex:i];
        if(!CGRectEqualToRect(page.frame, visibleStackHolder.bounds) || [page isBeingPannedAndZoomed]){
            numberOfVisiblePagesThatAreNotAligned ++;
        }
    }
    if(nonTopPageIsExitingBezel){
        debug_NSLog(@"exiting non-top page");
    }
    BOOL showRightArrow = [setOfPagesBeingPanned count] > 1 || topPageIsExitingBezel || nonTopPageIsExitingBezel;
    
    if(bezelingFromRight){
        if((fromRightBezelGesture.panDirection & SLBezelDirectionLeft) == SLBezelDirectionLeft){
            showLeftArrow = YES;
        }else if((fromRightBezelGesture.panDirection & SLBezelDirectionRight) == SLBezelDirectionRight){
            showRightArrow = YES;
        }
    }
    
    for(SLPaperView* page in setOfPagesBeingPanned){
        if(page == [visibleStackHolder peekSubview]){
            if([self shouldPushPageOntoVisibleStack:page withFrame:page.frame]){
                showLeftArrow = YES;
            }
            if([self shouldPopPageFromVisibleStack:page withFrame:page.frame]){
                showRightArrow = YES;
            }
        }
    }
    if((showLeftArrow || showRightArrow) && 
       ((!paperIcon.alpha && [setOfPagesBeingPanned count] == 1) ||
        (!papersIcon.alpha && [setOfPagesBeingPanned count] > 1) ||
        (!paperIcon.alpha && topPageIsExitingBezel) ||
        (!paperIcon.alpha && nonTopPageIsExitingBezel) ||
        bezelingFromRight)){
        [UIView animateWithDuration:0.2
                              delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             if([setOfPagesBeingPanned count] > 1 && !nonTopPageIsExitingBezel){
                                 //
                                 // user is holding the top page
                                 // plus at least 1 other
                                 papersIcon.alpha = numberOfVisiblePagesThatAreNotAligned > 2 ? 1 : 0;
                                 paperIcon.alpha = numberOfVisiblePagesThatAreNotAligned > 2 ? 0 : 1;
                                 plusIcon.alpha = 0;
                                 leftArrow.alpha = 0;
                                 rightArrow.alpha = 1;
                                 return;
                             }
                             
                             //
                             // ok, we're dealing with only
                             // panning teh top most page
                             papersIcon.alpha = 0;
                             paperIcon.alpha = 1;
                             
                             if(showLeftArrow && [hiddenStackHolder.subviews count] && ![hiddenStackHolder peekSubview].isBrandNewPage){
                                 leftArrow.alpha = 1;
                                 plusIcon.alpha = 0;
                             }else if(showLeftArrow){
                                 leftArrow.alpha = 0;
                                 plusIcon.alpha = 1;
                             }else if(!showLeftArrow){
                                 leftArrow.alpha = 0;
                                 plusIcon.alpha = 0;
                             }
                             if(showRightArrow){
                                 rightArrow.alpha = 1;
                             }else{
                                 rightArrow.alpha = 0;
                             }
                         }
                         completion:nil];
    }else if(!showLeftArrow && !showRightArrow && (paperIcon.alpha || papersIcon.alpha)){
        [UIView animateWithDuration:0.3 
                              delay:0 
                            options:UIViewAnimationOptionBeginFromCurrentState 
                         animations:^{
                             papersIcon.alpha = 0;
                             paperIcon.alpha = 0;
                             leftArrow.alpha = 0;
                             plusIcon.alpha = 0;
                             rightArrow.alpha = 0;
                         } 
                         completion:nil];
    }
}

/**
 * during a pan, we'll need to show different icons
 * depending on where they drag a page
 */
-(CGRect) isPanningAndScalingPage:(SLPaperView*)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame{
    if([page willExitBezel]){
        inProgressOfBezeling = page;
    }
    [setOfPagesBeingPanned addObject:page];
    [self updateIconAnimations];
    return toFrame;
}

/**
 * the user has completed their panning / scaling gesture
 * on a page. they may still be panning / scaling other pages,
 * so this function will take into account two scenarios:
 *
 * a) user bezel'd a page
 * b) user is done with top page
 * c) user is done with non-top page
 */
-(void) finishedPanningAndScalingPage:(SLPaperView*)page
                            intoBezel:(SLBezelDirection)bezelDirection
                            fromFrame:(CGRect)fromFrame
                              toFrame:(CGRect)toFrame
                         withVelocity:(CGPoint)velocity{
    [setOfPagesBeingPanned removeObject:page];
    [self updateIconAnimations];
    if((bezelDirection & SLBezelDirectionRight) == SLBezelDirectionRight){
        inProgressOfBezeling = nil;
        BOOL shouldResetVisibleStack = [visibleStackHolder peekSubview] == page;
        //
        // a) first, check if they panned the page into the bezel
        [self sendPageToHiddenStack:page];
        
        //
        // also need to handle any pages that are left un-ordered
        // from a previous multi-pan
        if(shouldResetVisibleStack){
            for(SLPaperView* aPage in [[visibleStackHolder.subviews copy] autorelease]){
                if(aPage != page){
                    // don't adjust the page we just dropped
                    // obviously :)
                    if([aPage isBeingPannedAndZoomed]){
                        [self popStackUntilPage:aPage];
                        return;
                    }else{
                        if(!CGRectEqualToRect(aPage.frame, self.bounds)){
                            [self animatePageToFullScreen:aPage withDelay:0 withBounce:NO];
                        }
                    }
                }
            }
        }
        return;
    }else if(page != [visibleStackHolder peekSubview]){
        //
        // b) next, check if they're done with a non-top page
        SLPaperView* topPage = [visibleStackHolder peekSubview];
        if([topPage isBeingPannedAndZoomed]){
            return;
        }
    }

    //
    // c) ok, this means we're working with the top page
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
    if([setOfPagesBeingPanned count]){
        //
        // first check for pages that are still panning,
        // and pop to them
        for(SLPaperView* page in [[[visibleStackHolder.subviews copy] autorelease] reverseObjectEnumerator]){
            if(page != [visibleStackHolder peekSubview]){
                if([page isBeingPannedAndZoomed]){
                    [self popStackUntilPage:page];
                    return;
                }
            }
        }
    }

    //
    // if nothing is still being panned, then
    // realign the location of the pages.
    for(SLPaperView* page in [[visibleStackHolder.subviews copy] autorelease]){
        if(page != [visibleStackHolder peekSubview]){
            if(!CGRectEqualToRect(page.frame, self.bounds)){
                [self animatePageToFullScreen:page withDelay:0 withBounce:NO];
            }
        }
    }
    
    if([hiddenStackHolder.subviews containsObject:page]){
        debug_NSLog(@"oh no!");
        [visibleStackHolder pushSubview:page];
        [page enableAllGestures];
    }
    
    if(page == [visibleStackHolder peekSubview] && [self shouldPopPageFromVisibleStack:page withFrame:toFrame]){
        [self popStackUntilPage:[self getPageBelow:page]];
    }else if(page == [visibleStackHolder peekSubview] && [self shouldPushPageOntoVisibleStack:page withFrame:toFrame]){
        [self animatePageToFullScreen:page withDelay:0.1 withBounce:NO];
        [self popTopPageOfHiddenStack];
    }else if(page.scale <= 1){
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
    return page.frame.origin.x > self.frame.size.width - kGutterWidthToDragPages;
}
-(BOOL) shouldPushPageOntoVisibleStack:(SLPaperView*)page withFrame:(CGRect)frame{
    return page.frame.origin.x + page.frame.size.width < kGutterWidthToDragPages;
}


#pragma mark - Page Animations

/**
 * this function is used when the user flicks a page
 * and its momentum will carry the page to the edge of
 * the screen.
 *
 * in this case, we want to animate the page to the edge
 * then bounce it like a scrollview would
 */
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
    
    void(^finishedBlock)(BOOL finished)  = ^(BOOL finished){
        if(finished){
            [page enableAllGestures];
            if(![visibleStackHolder containsSubview:page]){
                [visibleStackHolder pushSubview:page];
            }
        }
    };
    
    [page enableAllGestures];
    if(bounce){
        //
        // we also need to animate the shadow so that it doesn't "pop"
        // into place. it's not taken care of automatically in the
        // UIView animationWithDuration call...
        CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        theAnimation.duration = 0.3;
        theAnimation.fromValue = (id) [UIBezierPath bezierPathWithRect:CGRectMake(-10.0, -10.0, 50.0, 50.0)].CGPath;
        theAnimation.toValue = (id) [UIBezierPath bezierPathWithRect:CGRectMake(-10.0, -10.0, 50.0, 50.0)].CGPath;
        [page.layer addAnimation:theAnimation forKey:@"animateShadowPath"];
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
                                                  } completion:finishedBlock];
                             }
                         }];
    }else{
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionAllowUserInteraction
                         animations:^(void){
                             page.frame = self.bounds;
                             page.scale = 1;
                         } completion:finishedBlock];
    }
}



/**
 * this will animate a page onto the hidden stack
 * after the input delay, if any
 */
-(void) animateBackToHiddenStack:(SLPaperView*)page withDelay:(CGFloat)delay{
    //
    // the page may be sent to the hidden stack from ~90px away vs ~760px away
    // this math makes the speed of the exit look more consistent
    CGRect frInVisibleStack = [visibleStackHolder convertRect:page.frame fromView:page.superview];
    CGFloat dist =  MAX((visibleStackHolder.frame.size.width - frInVisibleStack.origin.x), visibleStackHolder.frame.size.width / 2);
    [UIView animateWithDuration:0.2 * (dist / visibleStackHolder.frame.size.width) delay:delay options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         page.frame = [hiddenStackHolder containsSubview:page] ? hiddenStackHolder.bounds : hiddenStackHolder.frame;
                         page.scale = 1;
                     } completion:^(BOOL finished){
                         if(finished){
                             [page disableAllGestures];
                             [hiddenStackHolder pushSubview:page];
                         }
                     }];
}


@end
