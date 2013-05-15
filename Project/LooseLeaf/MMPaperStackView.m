//
//  MMPaperStackView.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperStackView.h"
#import <QuartzCore/QuartzCore.h>
#import "MMShadowManager.h"
#import "NSThread+BlockAdditions.h"

@implementation MMPaperStackView

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
    bezelStackHolder = [[UIView alloc] initWithFrame:self.bounds];

    
    CGRect frameOfHiddenStack = hiddenStackHolder.frame;
    frameOfHiddenStack.origin.x += hiddenStackHolder.bounds.size.width + 1;
    hiddenStackHolder.frame = frameOfHiddenStack;
    bezelStackHolder.frame = frameOfHiddenStack;
    
    hiddenStackHolder.clipsToBounds = YES;
    visibleStackHolder.clipsToBounds = YES;
    bezelStackHolder.clipsToBounds = NO;
    
    //
    // icons for moving and panning pages
    [self addSubview:visibleStackHolder];
    [self addSubview:hiddenStackHolder];
    [self addSubview:bezelStackHolder];
    papersIcon = [[MMPapersIcon alloc] initWithFrame:CGRectMake(600, 460, 80, 80)];
    [self addSubview:papersIcon];
    paperIcon = [[MMPaperIcon alloc] initWithFrame:CGRectMake(600, 460, 80, 80)];
    [self addSubview:paperIcon];
    plusIcon = [[MMPlusIcon alloc] initWithFrame:CGRectMake(540, 476, 46, 46)];
    [self addSubview:plusIcon];
    leftArrow = [[MMLeftArrow alloc] initWithFrame:CGRectMake(540, 476, 46, 46)];
    [self addSubview:leftArrow];
    rightArrow = [[MMRightArrow alloc] initWithFrame:CGRectMake(680, 476, 46, 46)];
    [self addSubview:rightArrow];
    papersIcon.alpha = 0;
    paperIcon.alpha = 0;
    leftArrow.alpha = 0;
    rightArrow.alpha = 0;
    plusIcon.alpha = 0;
    
    fromRightBezelGesture = [[MMBezelInRightGestureRecognizer alloc] initWithTarget:self action:@selector(bezelIn:)];
    [self addGestureRecognizer:fromRightBezelGesture];
}

#pragma mark - Future Model Methods

/**
 * this function makes sure there's at least numberOfPagesToEnsure pages
 * in the hidden stack, and returns the top page
 */
-(void) ensureAtLeast:(NSInteger)numberOfPagesToEnsure pagesInStack:(UIView*)stackView{
    while([stackView.subviews count] < numberOfPagesToEnsure){
        MMPaperView* page = [[MMPaperView alloc] initWithFrame:stackView.bounds];
        page.isBrandNewPage = YES;
        page.delegate = self;
        [stackView addSubviewToBottomOfStack:page];
    }
}

/**
 * adds the page to the bottom of the stack
 * and adds to the bottom of the subviews
 */
-(void) addPaperToBottomOfStack:(MMPaperView*)page{
    page.isBrandNewPage = NO;
    page.delegate = self;
    [page enableAllGestures];
    [visibleStackHolder addSubviewToBottomOfStack:page];
}

/**
 * adds the page to the bottom of the stack
 * and adds to the bottom of the subviews
 */
-(void) addPaperToBottomOfHiddenStack:(MMPaperView*)page{
    page.isBrandNewPage = YES;
    page.delegate = self;
    [page disableAllGestures];
    [hiddenStackHolder addSubviewToBottomOfStack:page];
}


#pragma mark - Pan and Bezel Icons

/**
 * we need to update the icons that are visible
 * depending on the locations of the pages that are
 * currently being panned and scaled
 *
 * this is the + <= => icons on the right side of the screen
 * when a page is being panned
 */
-(void) updateIconAnimations{
    // YES if we're pulling pages in from the hidden stack, NO otherwise
    BOOL bezelingFromRight = fromRightBezelGesture.state == UIGestureRecognizerStateBegan || fromRightBezelGesture.state == UIGestureRecognizerStateChanged;
    // YES if the top page will bezel right, NO otherwise
    BOOL topPageWillBezelRight = [[visibleStackHolder peekSubview] willExitToBezel:MMBezelDirectionRight];
    // YES if the top page will bezel right, NO otherwise
    BOOL topPageWillBezelLeft = [[visibleStackHolder peekSubview] willExitToBezel:MMBezelDirectionLeft];
    // number of times the top page has been bezeled
    NSInteger numberOfTimesTheTopPageHasExitedBezel = [[visibleStackHolder peekSubview] numberOfTimesExitedBezel];
    // YES if a non top page is will exit bezel
    BOOL nonTopPageWillExitBezel = inProgressOfBezeling != [visibleStackHolder peekSubview] && ([inProgressOfBezeling numberOfTimesExitedBezel] > 0);
    // YES if we should show the right arrow (push pages to hidden stack)
    BOOL showRightArrow = NO;
    if([setOfPagesBeingPanned count] > 1 ||
       (topPageWillBezelRight && numberOfTimesTheTopPageHasExitedBezel > 0) ||
       nonTopPageWillExitBezel){
        showRightArrow  = YES;
    }
    // YES if we should show the left arrow (pulling pages in from hidden stack)
    BOOL showLeftArrow = NO;
    if(topPageWillBezelLeft && numberOfTimesTheTopPageHasExitedBezel > 0){
        showLeftArrow = YES;
    }
    if(bezelingFromRight){
        if((fromRightBezelGesture.panDirection & MMBezelDirectionLeft) == MMBezelDirectionLeft){
            showLeftArrow = YES;
        }else if((fromRightBezelGesture.panDirection & MMBezelDirectionRight) == MMBezelDirectionRight){
            showRightArrow = YES;
        }
    }
    
    for(MMPaperView* page in setOfPagesBeingPanned){
        if(page == [visibleStackHolder peekSubview]){
            if([self shouldPushPageOntoVisibleStack:page withFrame:page.frame]){
                showLeftArrow = YES;
            }
            if([self shouldPopPageFromVisibleStack:page withFrame:page.frame]){
                showRightArrow = YES;
            }
        }
    }
    
    
    if([visibleStackHolder peekSubview].scale < kMinPageZoom){
        //
        // ok, we're in zoomed out mode, looking at the list
        // of all the pages, so hide all the icons
        showLeftArrow = NO;
        showRightArrow = NO;
    }
    
    
    //
    //
    // now all the variables are set, we know our state
    //
    // so update the actual icons
    if((showLeftArrow || showRightArrow) &&
       ((!showLeftArrow && leftArrow.alpha) ||
        (!showRightArrow && rightArrow.alpha) ||
        (!paperIcon.alpha && [setOfPagesBeingPanned count] == 1) ||
        (!papersIcon.alpha && [setOfPagesBeingPanned count] > 1) ||
        (!paperIcon.alpha && topPageWillBezelRight && numberOfTimesTheTopPageHasExitedBezel > 0) ||
        (!paperIcon.alpha && nonTopPageWillExitBezel) ||
        bezelingFromRight)){
           [UIView animateWithDuration:0.2
                                 delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                            animations:^{
                                if(([setOfPagesBeingPanned count] > 1 && !nonTopPageWillExitBezel)){
                                    //
                                    // user is holding the top page
                                    // plus at least 1 other
                                    //
                                    // calculate the number of pages that will be sent
                                    // to the hidden stack if the user stops panning
                                    // the top page
                                    NSInteger numberToShowOnPagesIconIfNeeded = 0;
                                    for(MMPaperView* page in [[visibleStackHolder.subviews copy] reverseObjectEnumerator]){
                                        if([page isBeingPannedAndZoomed] && page != [visibleStackHolder peekSubview]){
                                            break;
                                        }else{
                                            numberToShowOnPagesIconIfNeeded++;
                                        }
                                    }
                                    
                                    //
                                    // update the icons as necessary
                                    papersIcon.alpha = numberToShowOnPagesIconIfNeeded > 1 ? 1 : 0;
                                    paperIcon.alpha = numberToShowOnPagesIconIfNeeded > 1 ? 0 : 1;
                                    papersIcon.numberToShowIfApplicable = numberToShowOnPagesIconIfNeeded;
                                    
                                    //
                                    // show right arrow since this gesture can only send pages
                                    // to the hidden stack
                                    plusIcon.alpha = 0;
                                    leftArrow.alpha = 0;
                                    rightArrow.alpha = 1;
                                    return;
                                }
                                
                                if(bezelingFromRight && fromRightBezelGesture.numberOfRepeatingBezels > 1){
                                    //
                                    // show the number of pages that the user
                                    // is bezeling in
                                    papersIcon.numberToShowIfApplicable = fromRightBezelGesture.numberOfRepeatingBezels;
                                    papersIcon.alpha = 1;
                                    paperIcon.alpha = 0;
                                }else if(numberOfTimesTheTopPageHasExitedBezel > 1){
                                    //
                                    // show pages icon w/ numbers if the user is exiting
                                    // bezel more than once
                                    papersIcon.numberToShowIfApplicable = numberOfTimesTheTopPageHasExitedBezel;
                                    papersIcon.alpha = 1;
                                    paperIcon.alpha = 0;
                                }else{
                                    //
                                    // ok, we're dealing with only
                                    // panning the top most page
                                    papersIcon.alpha = 0;
                                    paperIcon.alpha = 1;
                                }
                                
                                if(showLeftArrow && bezelingFromRight && ![bezelStackHolder peekSubview].isBrandNewPage){
                                    leftArrow.alpha = 1;
                                    plusIcon.alpha = 0;
                                }else if(showLeftArrow && [hiddenStackHolder.subviews count] && ![hiddenStackHolder peekSubview].isBrandNewPage){
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

#pragma mark - MMBezelInRightGestureRecognizer

/**
 * this is the event handler for the MMBezelInRightGestureRecognizer
 *
 * this handles pulling pages from the hidden stack onto the visible
 * stack. either one at a time, or multiple if the gesture is repeated
 * without interruption.
 */
-(void) bezelIn:(MMBezelInRightGestureRecognizer*)bezelGesture{
    // make sure there's a page to bezel
    [self ensureAtLeast:1 pagesInStack:hiddenStackHolder];
    CGPoint translation = [bezelGesture translationInView:self];
    
    if(bezelGesture.state == UIGestureRecognizerStateBegan){
        //
        // ok, the user is beginning the drag two fingers from the
        // right hand bezel. we need to push a page from the hidden
        // stack onto the bezel stack, and then we'll move that bezel
        // stack with the user's fingers
        if([bezelStackHolder.subviews count]){
            // uh oh, we still have views in the bezel gesture
            // that haven't compeleted their animation.
            //
            // we need to cancel all of their animations
            // and move them immediately to the hidden view
            // being sure to maintain proper order
            while([bezelStackHolder.subviews count]){
                MMPaperView* page = [bezelStackHolder peekSubview];
                [page.layer removeAllAnimations];
                [hiddenStackHolder pushSubview:page];
                page.frame = hiddenStackHolder.bounds;
            }
        }
        [[visibleStackHolder peekSubview] disableAllGestures];
        [bezelStackHolder pushSubview:[hiddenStackHolder peekSubview]];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            CGRect newFrame = CGRectMake(hiddenStackHolder.frame.origin.x + translation.x - kFingerWidth,
                                         hiddenStackHolder.frame.origin.y,
                                         hiddenStackHolder.frame.size.width,
                                         hiddenStackHolder.frame.size.height);
            bezelStackHolder.frame = newFrame;
            [bezelStackHolder peekSubview].frame = bezelStackHolder.bounds;
        } completion:nil];
    }else if(bezelGesture.state == UIGestureRecognizerStateCancelled ||
             bezelGesture.state == UIGestureRecognizerStateFailed ||
             (bezelGesture.state == UIGestureRecognizerStateEnded && ((bezelGesture.panDirection & MMBezelDirectionLeft) != MMBezelDirectionLeft))){
        //
        // they cancelled the bezel. so push all the views from the bezel back
        // onto the hidden stack, then animate them back into position.
        //
        // during the animation, all of the views are still inside the bezelStackHolder
        // until the animation for that page completes. they're not re-added to the
        // hidden stack until their animation completes.
        //
        // this is handled in the UIGestureRecognizerStateBegan state, if the user
        // begins a new bezel gesture but the animations for the previous bezel
        // haven't completed.
        [self emptyBezelStackToHiddenStackAnimated:YES onComplete:nil];
        [[visibleStackHolder peekSubview] enableAllGestures];
    }else if(bezelGesture.state == UIGestureRecognizerStateEnded &&
             ((bezelGesture.panDirection & MMBezelDirectionLeft) == MMBezelDirectionLeft)){
        //
        // ok, the user has completed a bezel gesture, so we should take all
        // the pages in the bezel view and push them onto the visible stack
        //
        // to do that, we'll move them back onto the hidden frame (and retain their visible frame)
        // and then use our animation functions to pop them off the hidden stack onto
        // the visible stack
        //
        // this'll let us move the bezel frame back to its hidden place above the hidden stack
        // immediately
        [[visibleStackHolder peekSubview] enableAllGestures];
        while([bezelStackHolder.subviews count]){
            // this will translate the frame from the bezel stack to the
            // hidden stack, so that the pages appear in the same place
            // to the user, the pop calls next will animate them to the
            // visible stack
            [hiddenStackHolder pushSubview:[bezelStackHolder peekSubview]];
        }
        void(^finishedBlock)(BOOL finished)  = ^(BOOL finished){
            bezelStackHolder.frame = hiddenStackHolder.frame;
        };
        [self popHiddenStackForPages:bezelGesture.numberOfRepeatingBezels onComplete:finishedBlock];
        
        //
        // successful gesture complete, so reset the gesture count
        // we only reset on the successful gesture, not a cancelled gesture
        //
        // that way, if the user moves their entire 2 fingers off bezel and
        // immediately back on bezel, then it'll increment count correctly
        [bezelGesture resetPageCount];
    }else{
        //
        // we're in progress of a bezel gesture from the right
        //
        // let's:
        // a) make sure we're bezeling the correct number of pages
        // b) make sure that (a) animates them to the correct place
        // c) add correct number of pages to the bezelStackHolder
        // d) update the offset for the bezelStackHolder so they all move in tandem
        while(bezelGesture.numberOfRepeatingBezels != [bezelStackHolder.subviews count] && [hiddenStackHolder.subviews count]){
            //
            // we need to add another page
            [bezelStackHolder pushSubview:[hiddenStackHolder peekSubview]];
            //
            // ok, animate them all into place
            NSInteger numberOfPages = [bezelStackHolder.subviews count];
            CGFloat delta;
            if(numberOfPages < 10){
                delta = 10;
            }else{
                delta = 100 / numberOfPages;
            }
            CGFloat currOffset = 0;
            for(MMPaperView* page in bezelStackHolder.subviews){
                CGRect fr = page.frame;
                if(fr.origin.x != currOffset){
                    fr.origin.x = currOffset;
                    if(page == [bezelStackHolder peekSubview]){
                        [UIView animateWithDuration:.2 animations:^{
                            page.frame = fr;
                        }];
                    }else{
                        page.frame = fr;
                    }
                }
                currOffset += delta;
            }
        }
        CGRect newFrame = CGRectMake(hiddenStackHolder.frame.origin.x + translation.x - kFingerWidth,
                                     hiddenStackHolder.frame.origin.y,
                                     hiddenStackHolder.frame.size.width,
                                     hiddenStackHolder.frame.size.height);
        bezelStackHolder.frame = newFrame;
        
        // in some cases, the top page on the visible stack will
        // think it's also being panned at the same time as this bezel
        // gesture
        //
        // double check and cancel it if needbe.
        MMPaperView* topPage = [visibleStackHolder peekSubview];
        if([topPage isBeingPannedAndZoomed]){
            [topPage cancelAllGestures];
        }
    }
    [self updateIconAnimations];
}

-(void) emptyBezelStackToVisibleStackOnComplete:(void(^)(BOOL finished))completionBlock{
    [bezelStackHolder removeAllAnimationsAndPreservePresentationFrame];
    CGFloat delay = 0;
    while([bezelStackHolder.subviews count]){
        BOOL isLastToAnimate = [bezelStackHolder.subviews count] == 1;
        MMPaperView* aPage = [bezelStackHolder.subviews objectAtIndex:0];
        [aPage removeAllAnimationsAndPreservePresentationFrame];
        [visibleStackHolder pushSubview:aPage];
        [self animatePageToFullScreen:aPage withDelay:delay withBounce:NO onComplete:(isLastToAnimate ? ^(BOOL finished){
            bezelStackHolder.frame = hiddenStackHolder.frame;
            if(completionBlock) completionBlock(finished);
        } : nil)];
        delay += kAnimationDelay;
    }
}
-(void) emptyBezelStackToHiddenStackAnimated:(BOOL)animated onComplete:(void(^)(BOOL finished))completionBlock{
    [bezelStackHolder removeAllAnimationsAndPreservePresentationFrame];
    if(animated){
        CGFloat delay = 0;
        for(MMPaperView* page in [bezelStackHolder.subviews reverseObjectEnumerator]){
            BOOL isLastToAnimate = page == [bezelStackHolder.subviews objectAtIndex:0];
            [self animateBackToHiddenStack:page withDelay:delay onComplete:(isLastToAnimate ? ^(BOOL finished){
                // since we're  moving the bezel frame for the drag animation, be sure to re-hide it
                // above the hidden stack off screen after all the pages animate
                // back to the hidden stack
                bezelStackHolder.frame = hiddenStackHolder.frame;
                if(completionBlock) completionBlock(finished);
            } : nil)];
            delay += kAnimationDelay;
        }
    }else{
        for(MMPaperView* page in [[bezelStackHolder.subviews copy] reverseObjectEnumerator]){
            [page removeAllAnimationsAndPreservePresentationFrame];
            [hiddenStackHolder pushSubview:page];
            page.frame = hiddenStackHolder.bounds;
        }
        bezelStackHolder.frame = hiddenStackHolder.frame;
        if(completionBlock) completionBlock(YES);
    }
}

#pragma mark - MMPaperViewDelegate

/**
 * let's only allow scaling the top most page
 */
-(BOOL) allowsScaleForPage:(MMPaperView*)page{
    return [visibleStackHolder peekSubview] == page;
}

/**
 * during a pan, we'll need to show different icons
 * depending on where they drag a page
 */
-(CGRect) isPanningAndScalingPage:(MMPaperView*)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame{
    
    if(page == [visibleStackHolder.subviews objectAtIndex:0]){
        // they're panning the bottom page in the visible stack,
        // so add another
        [self ensureAtLeast:[visibleStackHolder.subviews count] + 1 pagesInStack:visibleStackHolder];
    }
    
    //
    // resume normal behavior for any pages
    // of normal scale
    BOOL isPanningTopPage = page == [visibleStackHolder peekSubview];
    if([page numberOfTimesExitedBezel] > 0){
        inProgressOfBezeling = page;
    }
    [setOfPagesBeingPanned addObject:page];
    [self updateIconAnimations];
    
    //
    // the user is bezeling a page to the left, which will pop
    // in pages from the hidden stack if they let go
    //
    // let's animate a small pop in
    if(isPanningTopPage && [page willExitToBezel:MMBezelDirectionLeft]){
        //
        // we're in progress of a bezel gesture from the right
        //
        // let's:
        // a) make sure we're bezeling the correct number of pages
        // b) make sure that (a) animates them to the correct place
        // c) add correct number of pages to the bezelStackHolder
        // d) update the offset for the bezelStackHolder so they all move in tandem
        while(page.numberOfTimesExitedBezel > [bezelStackHolder.subviews count]){
            [self ensureAtLeast:1 pagesInStack:hiddenStackHolder];
            //
            // we need to add another page
            [bezelStackHolder pushSubview:[hiddenStackHolder peekSubview]];
            MMPaperView* topPage = [bezelStackHolder peekSubview];
            CGRect topPageFrame = topPage.frame;
            topPageFrame.origin.x = visibleStackHolder.frame.size.width - [bezelStackHolder.layer.presentationLayer frame].origin.x;
            topPage.frame = topPageFrame;
            //
            // ok, animate them all into place
            NSInteger numberOfPages = [bezelStackHolder.subviews count];
            CGFloat delta;
            if(numberOfPages < 10){
                delta = 10;
            }else{
                delta = 100 / numberOfPages;
            }
            CGFloat currOffset = 0;
            for(MMPaperView* page in bezelStackHolder.subviews){
                CGRect fr = page.frame;
                if(fr.origin.x != currOffset){
                    fr.origin.x = currOffset;
                    if(page == [bezelStackHolder peekSubview]){
                        [UIView animateWithDuration:.2 animations:^{
                            page.frame = fr;
                        }];
                    }else{
                        page.frame = fr;
                    }
                }
                currOffset += delta;
            }
        }
        CGRect newFrame = CGRectMake(hiddenStackHolder.frame.origin.x - MIN([bezelStackHolder.subviews count] * 10 + 4, 106),
                                     hiddenStackHolder.frame.origin.y,
                                     hiddenStackHolder.frame.size.width,
                                     hiddenStackHolder.frame.size.height);
        
        if(!CGRectEqualToRect(bezelStackHolder.frame, newFrame) ||
           CGRectEqualToRect(bezelStackHolder.frame, hiddenStackHolder.frame)){
            if(CGRectEqualToRect([bezelStackHolder.layer.presentationLayer frame], hiddenStackHolder.frame)){
                // bounce
                [UIView animateWithDuration:.1 animations:^{
                    CGRect bounceFrame = newFrame;
                    bounceFrame.origin.x -= 10;
                    bezelStackHolder.frame = bounceFrame;
                } completion:^(BOOL finished){
                    if(finished){
                        [UIView animateWithDuration:.2 animations:^{
                            bezelStackHolder.frame = newFrame;
                        }];
                    }
                }];
            }else{
                // expand
                [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    bezelStackHolder.frame = newFrame;
                } completion:nil];
            }
        }
    }else if(isPanningTopPage){
        // ok, the user isn't bezeling left anymore
        [UIView animateWithDuration:.2 delay:.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            bezelStackHolder.frame = hiddenStackHolder.frame;
        } completion:nil];
    }
    
    
    
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
-(void) finishedPanningAndScalingPage:(MMPaperView*)page
                            intoBezel:(MMBezelDirection)bezelDirection
                            fromFrame:(CGRect)fromFrame
                              toFrame:(CGRect)toFrame
                         withVelocity:(CGPoint)velocity{
    // check if we finished the in progress bezel
    if(page == inProgressOfBezeling) inProgressOfBezeling = nil;
    // check if we finished the top page
    BOOL justFinishedPanningTheTopPage = [visibleStackHolder peekSubview] == page;
    // this finished page isn't panned anymore...
    [setOfPagesBeingPanned removeObject:page];
    // ok, update the icons
    [self updateIconAnimations];
    

    
    if(justFinishedPanningTheTopPage && (bezelDirection & MMBezelDirectionLeft) == MMBezelDirectionLeft){
        //
        // CASE 1:
        // left bezel by top page
        // ============================================================================
        //
        // cancel any other gestures going on
        if([setOfPagesBeingPanned count]){
            // need to cancel pages being panned (?)
            for(MMPaperView* aPage in setOfPagesBeingPanned){
                [aPage cancelAllGestures];
            }
        }
        //
        // the bezelStackHolder was been filled during the pan, so add
        // the top page of the visible stack to the bottom of the bezelGestureHolder,
        // then animate
        [self animatePageToFullScreen:page withDelay:0.1 withBounce:NO onComplete:nil];
        [self emptyBezelStackToVisibleStackOnComplete:nil];
        return;
    }else if(justFinishedPanningTheTopPage && [setOfPagesBeingPanned count]){
        //
        // CASE 2:
        // they released the top page, but are still panning
        // other pages
        // ============================================================================
        //
        // find the top most page that we're still panning,
        // and pop until there.
        MMPaperView* popUntil = nil;
        for(MMPaperView* aPage in [visibleStackHolder.subviews reverseObjectEnumerator]){
            if(aPage != page){
                // don't adjust the page we just dropped
                // obviously :)
                if([aPage isBeingPannedAndZoomed]){
                    popUntil = aPage;
                    break;
                }
            }
        }
        [self popStackUntilPage:popUntil onComplete:nil];
        return;
    }else if(!justFinishedPanningTheTopPage && [self shouldPopPageFromVisibleStack:page withFrame:toFrame]){
        //
        // CASE 3:
        // they release a non-top page near the right
        // bezel. send to hidden stack
        // ============================================================================
        [page removeAllAnimationsAndPreservePresentationFrame];
        [self sendPageToHiddenStack:page onComplete:nil];
        return;
    }else if((bezelDirection & MMBezelDirectionRight) == MMBezelDirectionRight){
        //
        // CASE 4:
        // right bezel by any page
        // ============================================================================
        //
        // bezelStackHolder debugging DONE
        //
        // either, i bezeled right the top page and am not bezeling anything else
        // or, i bezeled right a bottom page and am holding the top page
        if(justFinishedPanningTheTopPage){
            //
            // we bezeled right the top page.
            // send as many as necessary to the hidden stack
            if(page.numberOfTimesExitedBezel > 1){
                MMPaperView* pageToPopUntil = page;
                for(int i=0;i<page.numberOfTimesExitedBezel && (![pageToPopUntil isBeingPannedAndZoomed] || pageToPopUntil == page);i++){
                    pageToPopUntil = [visibleStackHolder getPageBelow:pageToPopUntil];
                }
                [self popStackUntilPage:pageToPopUntil onComplete:nil];
            }else{
                [self sendPageToHiddenStack:page onComplete:nil];
            }
            //
            // now that pages are sent to the hidden stack,
            // realign anything left in the visible stack
            [self realignPagesInVisibleStackExcept:page animated:YES];
        }else{
            //
            // they bezeled right a non-top page, just get
            // rid of it
            [page removeAllAnimationsAndPreservePresentationFrame];
            [self sendPageToHiddenStack:page onComplete:nil];
        }
        return;
    }else if(!justFinishedPanningTheTopPage){
        //
        // CASE 5:
        //
        // bezelStackHolder debugging DONE
        //
        // just released a non-top page, but didn't
        // send it anywhere. just exit as long
        // as we're still holding the top page
        // ============================================================================
        MMPaperView* topPage = [visibleStackHolder peekSubview];
        if(![topPage isBeingPannedAndZoomed]){
            //
            // TODO
            //
            // odd, no idea how this happened. but we
            // just released a non-top page and the top
            // page is not being held.
            //
            // i've only seen this happen when touches get
            // confused and gestures are "still on" even
            // though no fingers are touching the screen
            //
            // just realign and log
            debug_NSLog(@"ERROR: released non-top page while top page was not held.");
            [self realignPagesInVisibleStackExcept:nil animated:YES];
        }
        return;
    }

    //
    // CASE 6:
    //
    // bezelStackHolder debugging DONE
    //
    // just relased the top page, and no
    // other pages are being held
    // ============================================================================
    // all the actions below will move the top page only,
    // so it's safe to realign allothers
    [self realignPagesInVisibleStackExcept:page animated:YES];

    if(justFinishedPanningTheTopPage && [self shouldPopPageFromVisibleStack:page withFrame:toFrame]){
        //
        // bezelStackHolder debugging DONE
        // pop the top page, it's close to the right bezel
        [self popStackUntilPage:[visibleStackHolder getPageBelow:page] onComplete:nil];
    }else if(justFinishedPanningTheTopPage && [self shouldPushPageOntoVisibleStack:page withFrame:toFrame]){
        //
        // bezelStackHolder debugging DONE
        //
        // pull a page from the hidden stack, and re-align
        // the top page
        //
        // the user may have bezeled left a lot, but then released
        // the gesture inside the screen (which should only push 1 page).
        //
        // so check the bezelStackHolder
        [self animatePageToFullScreen:page withDelay:0.1 withBounce:NO onComplete:nil];
        if([bezelStackHolder.subviews count]){
            // pull the view onto the visible stack
            MMPaperView* pageToPushToVisible = [bezelStackHolder.subviews objectAtIndex:0];
            [pageToPushToVisible removeAllAnimationsAndPreservePresentationFrame];
            [visibleStackHolder pushSubview:pageToPushToVisible];
            [self animatePageToFullScreen:pageToPushToVisible withDelay:0 withBounce:NO onComplete:nil];
            [bezelStackHolder.subviews makeObjectsPerformSelector:@selector(removeAllAnimationsAndPreservePresentationFrame)];
            [self emptyBezelStackToHiddenStackAnimated:YES onComplete:nil];
        }else{
            [self popTopPageOfHiddenStack];
        }
    }else if(page.scale <= 1){
        //
        // bezelStackHolder debugging DONE
        //
        // bounce it back to full screen
        [bezelStackHolder.subviews makeObjectsPerformSelector:@selector(removeAllAnimationsAndPreservePresentationFrame)];
        [self emptyBezelStackToHiddenStackAnimated:YES onComplete:nil];
        [self animatePageToFullScreen:page withDelay:0 withBounce:YES onComplete:nil];
    }else{
        //
        // bezelStackHolder debugging DONE
        //
        // first, empty the bezelStackHolder, if any
        [bezelStackHolder.subviews makeObjectsPerformSelector:@selector(removeAllAnimationsAndPreservePresentationFrame)];
        [self emptyBezelStackToHiddenStackAnimated:YES onComplete:nil];
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
        
        if([self shouldInterialSlideThePage:page toFrame:intertialFrame]){
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut animations:^(void){
                page.frame = intertialFrame;
            } completion:nil];
        }else{
            // bounce
            [self bouncePageToEdge:page toFrame:toFrame intertialFrame:intertialFrame];
        }
    }
}

-(void) isBeginningToScaleReallySmall:(MMPaperView *)page{
    NSLog(@"isBeginningToScaleReallySmall");
    [self updateIconAnimations];
}

-(void) finishedScalingReallySmall:(MMPaperView *)page{
    NSLog(@"finishedScalingReallySmall");
    [self updateIconAnimations];
}

-(void) cancelledScalingReallySmall:(MMPaperView *)page{
    NSLog(@"cancelledScalingReallySmall");
    [self updateIconAnimations];
}

-(void) finishedScalingBackToPageView:(MMPaperView*)page{
    NSLog(@"finishedScalingBackToPageView");
    [self updateIconAnimations];
}

-(NSInteger) indexOfPageInCompleteStack:(MMPaperView*)page{
    @throw kAbstractMethodException;
}

-(NSInteger) rowInListViewGivenIndex:(NSInteger) indexOfPage{
    @throw kAbstractMethodException;
}

-(NSInteger) columnInListViewGivenIndex:(NSInteger) indexOfPage{
    @throw kAbstractMethodException;
}

-(BOOL) isInVisibleStack:(MMPaperView *)page{
    @throw kAbstractMethodException;
}


#pragma mark - Page Animation and Navigation Helpers

/**
 * returns YES if the page should slide
 * to the target frame as if it had inertia
 *
 * returns NO if the page should just bounce
 * instead
 */
-(BOOL) shouldInterialSlideThePage:(MMPaperView*)page toFrame:(CGRect)frame{
    if(frame.origin.y <= 0 && frame.origin.y + frame.size.height > self.superview.frame.size.height &&
       frame.origin.x <= 0 && frame.origin.x + frame.size.width > self.superview.frame.size.width){
        return YES;
    }
    return NO;
}

/**
 * returns YES if a page should trigger removing
 * a page from the visible stack to the hidden stack.
 *
 * this is used when a user drags a page to the left/right
 */
-(BOOL) shouldPopPageFromVisibleStack:(MMPaperView*)page withFrame:(CGRect)frame{
    return page.frame.origin.x > self.frame.size.width - kGutterWidthToDragPages;
}

/**
 * returns YES if a page should trigger adding
 * a page to the visible stack from the hidden stack.
 *
 * this is used when a user drags a page to the left/right
 */
-(BOOL) shouldPushPageOntoVisibleStack:(MMPaperView*)page withFrame:(CGRect)frame{
    return page.frame.origin.x + page.frame.size.width < kGutterWidthToDragPages;
}

/**
 * this will realign all the pages except the input page
 * to be scale 1 and (0,0) in the visibleStackHolder
 */
-(void) realignPagesInVisibleStackExcept:(MMPaperView*)page animated:(BOOL)animated{
    for(MMPaperView* aPage in [visibleStackHolder.subviews copy]){
        if(aPage != page){
            if(!CGRectEqualToRect(aPage.frame, self.bounds)){
                [aPage cancelAllGestures];
                if(animated){
                    [self animatePageToFullScreen:aPage withDelay:0 withBounce:NO onComplete:nil];
                }else{
                    aPage.frame = self.bounds;
                }
            }
        }
    }
}




#pragma mark - Page Animations

/**
 * immediately animates the page from the visible stack
 * to the hidden stack
 */
-(void) sendPageToHiddenStack:(MMPaperView*)page onComplete:(void(^)(BOOL finished))completionBlock{
    if([visibleStackHolder.subviews containsObject:page]){
        [bezelStackHolder addSubviewToBottomOfStack:page];
        [self emptyBezelStackToHiddenStackAnimated:YES onComplete:completionBlock];
        [self ensureAtLeast:1 pagesInStack:visibleStackHolder];
    }
}

/**
 * will pop just the top of the hidden stack
 * onto the visible stack.
 *
 * if a page does not exist, it will create one
 * so that it has something to pop.
 */
-(void) popTopPageOfHiddenStack{
    [self ensureAtLeast:1 pagesInStack:hiddenStackHolder];
    MMPaperView* page = [hiddenStackHolder peekSubview];
    page.isBrandNewPage = NO;
    [self popHiddenStackUntilPage:[hiddenStackHolder getPageBelow:page] onComplete:nil];
}

/**
 * the input is a page in the visible stack,
 * and we pop all pages above but not including
 * the input page
 *
 * these pages will be pushed over to the invisible stack
 */
-(void) popStackUntilPage:(MMPaperView*)page onComplete:(void(^)(BOOL finished))completionBlock{
    if([visibleStackHolder.subviews containsObject:page] || page == nil){
        // list of pages from bottom to top
        NSArray* pages = [visibleStackHolder peekSubviewFromSubview:page];
        // enumerage backwards, so top pages stay on top,
        // and all are below anything already in the bezelStackHolder
        for(MMPaperView* pageToPop in [pages reverseObjectEnumerator]){
            [pageToPop removeAllAnimationsAndPreservePresentationFrame];
            [bezelStackHolder addSubviewToBottomOfStack:pageToPop];
        }
        [self emptyBezelStackToHiddenStackAnimated:YES onComplete:completionBlock];
        [self ensureAtLeast:1 pagesInStack:visibleStackHolder];
    }
}

/**
 * the input is a page in the visible stack,
 * and we pop all pages above but not including
 * the input page
 *
 * these pages will be pushed over to the invisible stack
 */
-(void) popHiddenStackUntilPage:(MMPaperView*)page onComplete:(void(^)(BOOL finished))completionBlock{
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
            MMPaperView* aPage = [hiddenStackHolder peekSubview];
            aPage.isBrandNewPage = NO;
            //
            // this push will also pop it off the visible stack, and adjust the frame
            // correctly
            [aPage enableAllGestures];
            [visibleStackHolder pushSubview:aPage];
            BOOL hasAnotherToPop = [hiddenStackHolder peekSubview] != page && [hiddenStackHolder.subviews count];
            [self animatePageToFullScreen:aPage withDelay:delay withBounce:YES onComplete:(!hasAnotherToPop ? completionBlock : nil)];
            delay += kAnimationDelay;
        }
    }
}
/**
 * pop numberOfPages off of the hidden stack
 * and call the completionBlock once they're all
 * animated
 */
-(void) popHiddenStackForPages:(NSInteger)numberOfPages onComplete:(void(^)(BOOL finished))completionBlock{
    [self ensureAtLeast:numberOfPages pagesInStack:hiddenStackHolder];
    NSInteger index = [hiddenStackHolder.subviews count] - 1 - numberOfPages;
    if(index >= 0){
        [self popHiddenStackUntilPage:[hiddenStackHolder.subviews objectAtIndex:index] onComplete:completionBlock];
    }else{
        // pop entire stack
        [self popHiddenStackUntilPage:nil onComplete:completionBlock];
    }
}

/**
 * this function is used when the user flicks a page
 * and its momentum will carry the page to the edge of
 * the screen.
 *
 * in this case, we want to animate the page to the edge
 * then bounce it like a scrollview would
 */
-(void) bouncePageToEdge:(MMPaperView*)page toFrame:(CGRect)toFrame intertialFrame:(CGRect)inertialFrame{
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
-(void) animatePageToFullScreen:(MMPaperView*)page withDelay:(CGFloat)delay withBounce:(BOOL)bounce onComplete:(void(^)(BOOL finished))completionBlock{
    
    void(^finishedBlock)(BOOL finished)  = ^(BOOL finished){
        if(finished){
            [page enableAllGestures];
            if(![visibleStackHolder containsSubview:page]){
                [visibleStackHolder pushSubview:page];
            }
        }
        if(completionBlock) completionBlock(finished);
    };
    
    [page enableAllGestures];
    if(bounce){
        CGFloat duration = .3;
        CGFloat bounceHeight = 10;
        //
        // we also need to animate the shadow so that it doesn't "pop"
        // into place. it's not taken care of automatically in the
        // UIView animationWithDuration call...
        CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        theAnimation.duration = duration / 2;
        theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        theAnimation.fromValue = (id) page.contentView.layer.shadowPath;
        theAnimation.toValue = (id) [[MMShadowManager sharedInstace] getShadowForSize:[MMShadowedView expandBounds:self.bounds].size];
        [page.contentView.layer addAnimation:theAnimation forKey:@"animateShadowPath"];
        [UIView animateWithDuration:duration/2 delay:delay options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut
                         animations:^(void){
                             page.scale = 1;
                             CGRect bounceFrame = self.bounds;
                             bounceFrame.origin.x = bounceFrame.origin.x-bounceHeight;
                             bounceFrame.origin.y = bounceFrame.origin.y-bounceHeight;
                             bounceFrame.size.width = bounceFrame.size.width+bounceHeight*2;
                             bounceFrame.size.height = bounceFrame.size.height+bounceHeight*2;
                             page.frame = bounceFrame;
                         } completion:^(BOOL finished){
                             if(finished){
                                 //
                                 // ok, here the page is bounced too large for the screen, so
                                 // complete the bounce and put the zoom at 100% exactly.
                                 // first the shadow, then the frame
                                 CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
                                 theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                                 theAnimation.duration = duration / 2;
                                 theAnimation.fromValue = (id) page.contentView.layer.shadowPath;
                                 theAnimation.toValue = (id) [[MMShadowManager sharedInstace] getShadowForSize:self.bounds.size];
                                 [page.contentView.layer addAnimation:theAnimation forKey:@"animateShadowPath"];
                                 [UIView animateWithDuration:duration/2 delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseIn
                                                  animations:^(void){
                                                      page.frame = self.bounds;
                                                      page.scale = 1;
                                                  } completion:finishedBlock];
                             }
                         }];
    }else{
        CGFloat duration = .15;
        [[NSThread mainThread] performBlock:^{
            //
            // always animate the shadow and the frame
            CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
            theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            theAnimation.duration = duration;
            theAnimation.fromValue = (id) page.contentView.layer.shadowPath;
            theAnimation.toValue = (id) [[MMShadowManager sharedInstace] getShadowForSize:self.bounds.size];
            [page.contentView.layer addAnimation:theAnimation forKey:@"animateShadowPath"];
            [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                                 page.frame = self.bounds;
                                 page.scale = 1;
                             } completion:finishedBlock];
        } afterDelay:delay];
    }
}



/**
 * this will animate a page onto the hidden stack
 * after the input delay, if any
 *
 * if the page is already offscreen, then it won't
 * animate
 */
-(void) animateBackToHiddenStack:(MMPaperView*)page withDelay:(CGFloat)delay onComplete:(void(^)(BOOL finished))completionBlock{
    //
    // the page may be sent to the hidden stack from ~90px away vs ~760px away
    // this math makes the speed of the exit look more consistent
    CGRect frInVisibleStack = [visibleStackHolder convertRect:page.frame fromView:page.superview];
    if(frInVisibleStack.origin.x >= visibleStackHolder.frame.size.width){
        // it's invisible already, just push it on
        debug_NSLog(@"pushing invisible page");
        page.frame = hiddenStackHolder.bounds;
        page.scale = 1;
        [page disableAllGestures];
        [hiddenStackHolder pushSubview:page];
        if(completionBlock) completionBlock(YES);
    }else{
        CGFloat dist =  MAX((visibleStackHolder.frame.size.width - frInVisibleStack.origin.x), visibleStackHolder.frame.size.width / 2);
        [UIView animateWithDuration:0.2 * (dist / visibleStackHolder.frame.size.width) delay:delay options:UIViewAnimationOptionCurveEaseOut
                         animations:^(void){
                             CGRect toFrame = [hiddenStackHolder containsSubview:page] ? hiddenStackHolder.bounds : hiddenStackHolder.frame;
                             toFrame = [page.superview convertRect:hiddenStackHolder.bounds fromView:hiddenStackHolder];
                             page.frame = toFrame;
                             page.scale = 1;
                         } completion:^(BOOL finished){
                             if(finished){
                                 [page disableAllGestures];
                                 [hiddenStackHolder pushSubview:page];
                             }
                             if(completionBlock) completionBlock(finished);
                         }];
    }
}

@end
