//
//  MMListPaperStackView.m
//  Loose Leaf
//
//  Created by Adam Wulf on 7/3/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMListPaperStackView.h"
#import "UIView+Debug.h"
#import "NSThread+BlockAdditions.h"
#import "MMShadowManager.h"

@implementation MMListPaperStackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        setOfInitialFramesForPagesBeingZoomed = [[NSMutableDictionary alloc] init];
        setOfFinalFramesForPagesBeingZoomed = [[NSMutableDictionary alloc] init];
        [self setScrollEnabled:NO];
        //
        // screen and column constants
        screenWidth = self.frame.size.width;
        screenHeight = self.frame.size.height;
        columnWidth = screenWidth * kListPageZoom;
        rowHeight = columnWidth * screenHeight / screenWidth;
        bufferWidth = columnWidth * kListPageZoom;

        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapScrollView:)];
        [tapGesture setNumberOfTapsRequired:1];
        [tapGesture setNumberOfTouchesRequired:1];
        tapGesture.enabled = NO;
        [self addGestureRecognizer:tapGesture];
        
        pinchGesture = [[MMPanAndPinchFromListViewGestureRecognizer alloc] initWithTarget:self action:@selector(didPinchAPageInListView:)];
        pinchGesture.enabled = NO;
        pinchGesture.pinchDelegate = self;
        [self addGestureRecognizer:pinchGesture];
        
        [NSThread performBlockInBackground:^{
            displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateScrollOffsetDuringDrag)];
            displayLink.paused = YES;
            [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        }];

        // init the add page button in top left of scrollview
        addPageButtonInListView = [[MMListAddPageButton alloc] initWithFrame:CGRectMake(bufferWidth, bufferWidth, columnWidth, rowHeight)];
        addPageButtonInListView.delegate = self;
        addPageButtonInListView.alpha = 0;
        [self addSubview:addPageButtonInListView];
    }
    return self;
}

#pragma mark - Add Button in List View

-(CGRect) frameForAddPageButton{
    NSInteger numberOfPages = [visibleStackHolder.subviews count] + [hiddenStackHolder.subviews count];
    NSInteger maxRow = numberOfPages / kNumberOfColumnsInListView;
    CGRect ret = CGRectMake(0, 0, columnWidth, rowHeight);
    
    NSInteger possibleRemainder = 0;
    while(true){
        if(numberOfPages % kNumberOfColumnsInListView == possibleRemainder){
            ret.origin.x = bufferWidth + bufferWidth * possibleRemainder + columnWidth * possibleRemainder;
            ret.origin.y = bufferWidth + bufferWidth * maxRow + rowHeight * maxRow;
            return ret;
        }
        possibleRemainder++;
    }
}

-(void) moveAddButtonToBottom{
    [self insertSubview:addPageButtonInListView atIndex:0];
}
-(void) moveAddButtonToTop{
    [self addSubview:addPageButtonInListView];
}

-(void) didTapAddButtonInListView{
    //
    // this'll determine the resolution of the canvas too
    MMEditablePaperView* paper = [[MMEditablePaperView alloc] initWithFrame:self.bounds];
    // now size it for display
    paper.frame = addPageButtonInListView.frame;
    [self addPaperToBottomOfHiddenStack:paper];
    [self ensurePageIsAtTopOfVisibleStack:paper];
    [self immediatelyAnimateFromListViewToFullScreenView];
}

#pragma mark - Local Frame Cache

//
// for any given gesture, the frameForListViewForPage: for any page
// will be the same, so let's cache that for this gesture
-(CGRect) frameForListViewForPage:(MMPaperView*)page{
    NSValue* finalFrame = [setOfFinalFramesForPagesBeingZoomed objectForKey:page.uuid];
    if(finalFrame){
        return [finalFrame CGRectValue];
    }
    
    //
    // fetching the index of a page can be moderately expensive,
    // so do this once and then generate the row/column from that.
    // instead of using the row/column getters on the page object
    NSInteger indexOfPage = [self indexOfPageInCompleteStack:page];
    NSInteger column = [self columnInListViewGivenIndex:indexOfPage];
    NSInteger row = [self rowInListViewGivenIndex:indexOfPage];
    CGRect frameOfPage = CGRectZero;
    frameOfPage.origin.x = bufferWidth + bufferWidth * column + columnWidth * column;
    frameOfPage.origin.y = bufferWidth + bufferWidth * row + rowHeight * row;
    frameOfPage.size.width = columnWidth;
    frameOfPage.size.height = rowHeight;
    
    [setOfFinalFramesForPagesBeingZoomed setObject:[NSValue valueWithCGRect:frameOfPage] forKey:page.uuid];
    return frameOfPage;
}
-(void) clearFrameCacheForPage:(MMPaperView*)page{
    [setOfFinalFramesForPagesBeingZoomed removeObjectForKey:page.uuid];
}

-(NSInteger) rowInListViewGivenIndex:(NSInteger) indexOfPage{
    NSInteger rowOfPage = floor(indexOfPage / kNumberOfColumnsInListView);
    return rowOfPage;
}

-(NSInteger) columnInListViewGivenIndex:(NSInteger) indexOfPage{
    NSInteger columnOfPage = indexOfPage % kNumberOfColumnsInListView;
    return columnOfPage;
}




#pragma mark - List View Enable / Disable Helper Methods

/**
 * the user is beginning to transition between list/page view
 * and is starting from the Page view
 */
-(void) beginUITransitionFromPageView{
    // clear our cache of frame locations
    [setOfFinalFramesForPagesBeingZoomed removeAllObjects];
    // ok, now we can get offset
    initialScrollOffsetFromTransitionToListView = [self offsetNeededToShowPage:[visibleStackHolder peekSubview]];
    // from offset/height, we know which views will be visible
    pagesThatWillBeVisibleAfterTransitionToListView = [self findPagesInVisibleRowsOfListViewGivenOffset:initialScrollOffsetFromTransitionToListView];
    // bezeling in from right is no longer allowed
    [fromRightBezelGesture setEnabled:NO];
    [hiddenStackHolder setClipsToBounds:NO];
    [visibleStackHolder setClipsToBounds:NO];
    [self setScrollEnabled:NO];
    [tapGesture setEnabled:NO];
    [pinchGesture setEnabled:NO];
    [self moveAddButtonToBottom];
    //
    // ok, we're about to zoom out to list view, so save the frames
    // of all the pages in the visible stack
    //
    // first check the pagse in the visible stack
    for(MMPaperView* aPage in [visibleStackHolder.subviews reverseObjectEnumerator]){
        // all these if statements are a bit wonky,
        // but the gist is that we need to only save
        // interesting frames, and ignore any that match
        // the bounds.
        //
        // also make sure to disable gestures for all but the top
        // page
        if(!CGRectEqualToRect(aPage.frame, visibleStackHolder.bounds)){
            [setOfInitialFramesForPagesBeingZoomed setObject:[NSValue valueWithCGRect:aPage.frame] forKey:aPage.uuid];
        }
        if(aPage != [visibleStackHolder peekSubview]){
            [aPage disableAllGestures];
        }
        if(CGRectEqualToRect(aPage.frame, visibleStackHolder.bounds)){
            break;
        }
    }
    for(MMPaperView* aPage in pagesThatWillBeVisibleAfterTransitionToListView){
        if(!CGRectEqualToRect(aPage.frame, hiddenStackHolder.bounds)){
            [setOfInitialFramesForPagesBeingZoomed setObject:[NSValue valueWithCGRect:aPage.frame] forKey:aPage.uuid];
        }
        if(aPage != [visibleStackHolder peekSubview]){
            [aPage disableAllGestures];
        }
    }
}

/**
 * the user is beginning to transition between list/page view
 * and is starting from the List view
 */
-(void) beginUITransitionFromListView{
    if(!tapGesture.enabled && !fromRightBezelGesture.enabled && !hiddenStackHolder.clipsToBounds && !visibleStackHolder.clipsToBounds){
        // already began transition
        return;
    }
    // clear our cache of frame locations
    [setOfFinalFramesForPagesBeingZoomed removeAllObjects];
    // ok, now we can get offset
    initialScrollOffsetFromTransitionToListView = self.contentOffset;
    // from offset/height, we know which views will be visible
    pagesThatWillBeVisibleAfterTransitionToListView = [self findPagesInVisibleRowsOfListViewGivenOffset:initialScrollOffsetFromTransitionToListView];
    // bezeling in from right is no longer allowed
    [fromRightBezelGesture setEnabled:NO];
    [hiddenStackHolder setClipsToBounds:NO];
    [visibleStackHolder setClipsToBounds:NO];
    [self setScrollEnabled:NO];
    [tapGesture setEnabled:NO];
    if(!pinchGesture.pinchedPage){
        [pinchGesture setEnabled:NO];
    }
    [self moveAddButtonToBottom];
    [visibleStackHolder.superview insertSubview:visibleStackHolder aboveSubview:hiddenStackHolder];
}

/**
 * the user has confirmed that they want to complete the
 * transition into list view from the transition state
 */
-(void) finishUITransitionToListView{
    [setOfInitialFramesForPagesBeingZoomed removeAllObjects];
    [fromRightBezelGesture setEnabled:NO];
    [visibleStackHolder setClipsToBounds:NO];
    [hiddenStackHolder setClipsToBounds:NO];
    [self setScrollEnabled:YES];
    [tapGesture setEnabled:YES];
    [pinchGesture setEnabled:YES];
    pagesThatWillBeVisibleAfterTransitionToListView = nil;
    [self moveAddButtonToTop];
}

/**
 * the user has confirmed that they want to complete the
 * transition into page view from the transition state
 */
-(void) finishUITransitionToPageView{
    for(MMPaperView* aPage in [visibleStackHolder.subviews reverseObjectEnumerator]){
        if(aPage != [visibleStackHolder peekSubview]){
            [aPage enableAllGestures];
        }
        NSValue* possibleCachedLocation = [setOfInitialFramesForPagesBeingZoomed objectForKey:aPage.uuid];
        if(possibleCachedLocation){
            aPage.frame = [possibleCachedLocation CGRectValue];
        }else{
            aPage.frame = visibleStackHolder.bounds;
        }
    }
    [setOfInitialFramesForPagesBeingZoomed removeAllObjects];
    [fromRightBezelGesture setEnabled:YES];
    [visibleStackHolder setClipsToBounds:YES];
    [hiddenStackHolder setClipsToBounds:YES];
    [self setScrollEnabled:NO];
    [tapGesture setEnabled:NO];
    [pinchGesture setEnabled:NO];
    pagesThatWillBeVisibleAfterTransitionToListView = nil;
    [visibleStackHolder.superview insertSubview:visibleStackHolder belowSubview:hiddenStackHolder];
    [self moveAddButtonToBottom];
    [self didChangeTopPage];
}



#pragma mark - MMPaperViewDelegate

/**
 * this is a delegate method that's called when the page is being actively panned
 * by the user. this page pan is only when we are in PAGE view. when panning a page
 * in LIST view - this is NOT called, it is a different gesture.
 *
 * when a page is being panned, we need to handle the case where the user begins to
 * zoom out far enough to transition into list view
 *
 * when that happens, we start to also move pages below the panned page to show that
 * transition animation
 */
-(CGRect) isBeginning:(BOOL)beginning toPanAndScalePage:(MMPaperView *)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame{
    if([visibleStackHolder peekSubview].scale < kMinPageZoom && [visibleStackHolder peekSubview] == page){
        // make sure we're the top page being panned,
        // and that we're zooming into list view
        
        CGRect fr = [self frameForAddPageButton];
        fr.origin.y -= initialScrollOffsetFromTransitionToListView.y;
        addPageButtonInListView.frame = fr;
        addPageButtonInListView.alpha = 0;
        [self moveAddButtonToBottom];
        //
        // once the zoom is below kMinPageZoom and still above kZoomToListPageZoom,
        // then we need to adjust the frames of all the pages so that they zoom
        // into their list view frames correctly
        if([bezelStackHolder.subviews count]){
            // bezelStackHolder still has pages being animated, so hold off on any list animations for now
            //
            // while we wait for the bezel to empty, we'll just return the toFrame
            return toFrame;
        }
        
        //
        // ok, the top page is the only page that's being panned.
        // and it's zoom is below the min page zoom, so we should
        // start to move it's frame toward its resting place, and also
        // move all the top two rows of pages to their resting place as well
        //
        // how close are we to list view? 1 is not close at all, 0 is list view
        CGFloat percentageToTrustToFrame = [visibleStackHolder peekSubview].scale / kMinPageZoom;
        
        
        //
        // start to move the hidden frame to overlap the visible frame
        CGFloat percentageToMoveHiddenFrame = percentageToTrustToFrame;
        percentageToMoveHiddenFrame += .1;
        CGFloat amountToMoveHiddenFrame = visibleStackHolder.frame.size.width - percentageToMoveHiddenFrame * visibleStackHolder.frame.size.width;
        CGFloat amountToMoveHiddenFrameFromCachedPosition = visibleStackHolder.frame.size.width - percentageToTrustToFrame * visibleStackHolder.frame.size.width;
        
        //
        // ok, move all the soon to be visible pages into their
        // position
        CGFloat transitionDelay = 0;
        for(MMPaperView* aPage in pagesThatWillBeVisibleAfterTransitionToListView){
            if(aPage != page){
                CGRect oldFrame = hiddenStackHolder.bounds;
                NSValue* possibleCachedOriginalLocation = [setOfInitialFramesForPagesBeingZoomed objectForKey:aPage.uuid];
                if(possibleCachedOriginalLocation){
                    // https://github.com/adamwulf/loose-leaf/issues/18
                    // the user may have been panning pages behind the top page
                    // so use that as its original location if we can
                    oldFrame = [possibleCachedOriginalLocation CGRectValue];
                }
                CGRect newFrame = [self framePositionDuringTransitionForPage:aPage originalFrame:oldFrame withTrust:percentageToTrustToFrame + transitionDelay];
                if(![self isInVisibleStack:aPage] && !possibleCachedOriginalLocation){
                    //
                    // this helps the hidden pages to show coming in from
                    // the right, but only if their position wasn't saved
                    // frome the bezel location
                    newFrame.origin.x -= amountToMoveHiddenFrame;
                }else if(![self isInVisibleStack:aPage]){
                    newFrame.origin.x -= amountToMoveHiddenFrameFromCachedPosition;
                }
                aPage.frame = newFrame;
                
                //
                // transitionDelay makes sure that each page is not /exactly/ lined up
                // with its neighboring pages. just gives a bit of texture to the
                // transition
                transitionDelay += .017;
            }
        }
        
        //
        // the user has zoomed out far enough for us to take over
        // with animations. cancel the gesture.
        //
        // the cancelled state will be caught in MMPaperStackView, so
        // the frame is not adjusted after we animate the page to
        // it's resting place
        if([visibleStackHolder peekSubview].scale < kZoomToListPageZoom){
            [[visibleStackHolder peekSubview] cancelAllGestures];
            return fromFrame;
        }
        return [self framePositionDuringTransitionForPage:page originalFrame:toFrame withTrust:percentageToTrustToFrame];
    }
    return [super isBeginning:beginning toPanAndScalePage:page fromFrame:fromFrame toFrame:toFrame];
}

/**
 * the user has scaled a page small enough for us to 
 * trigger the zoom to list view
 */
-(void) isBeginningToScaleReallySmall:(MMPaperView *)page{
    [super isBeginningToScaleReallySmall:page];
    //
    // the user is also panning other pages, we need to
    // cancel them because only the top page's gesture
    // is allowed at this small scale
    if([[setOfPagesBeingPanned setByRemovingObject:page] count]){
        //
        // we're panning the top most page, and it's scale
        // is less than the minimum allowed.
        //
        // this means we need to cancel all other gestures
        // and start zooming views out
        NSSet* setOfAllPannedPagesExceptTopVisible = [setOfPagesBeingPanned setByRemovingObject:[visibleStackHolder peekSubview]];
        for(MMPaperView* page in setOfAllPannedPagesExceptTopVisible){
            [page cancelAllGestures];
        }
    }
    //
    // the bezelStackHolder may have subviews from a gesture
    // so empty that stack to the hidden stack before
    // we can continue scaling out
    if([bezelStackHolder.subviews count]){
        //
        // https://github.com/adamwulf/loose-leaf/issues/24
        // check to see if we have pages in the bezel or not.
        // if we do, then we need to move those pages to the appropriate
        // stack so that the animation into list view works correctly.
        //
        // we need to cancel any bezel gestures and consider this purely
        // a pinch gesture, not a pan->bezel gesture.
        //
        // we need to preserve the frame, so that if the bezel'd pages
        // are currently visible, when the animation to list view begins
        // they'll begin from their current location intsead of the hidden
        // stack
        [self emptyBezelStackToHiddenStackAnimated:NO andPreserveFrame:YES onComplete:nil];
    }
    [self beginUITransitionFromPageView];
}


/**
 * the user has scaled small enough with the top page
 * that we can take over and just animate the rest.
 *
 * so we need to cancel it's gestures, then calculate
 * the final resting place for every page in the visible
 * stack, then animate them.
 *
 * we're going to scale pages in the first two rows, and
 * we'll just slide any pages below that above the screen.
 *
 * when the animation completes, we'll adjust all the frames
 * and content offsets to that the user can scroll them
 */
-(void) finishedScalingReallySmall:(MMPaperView *)page{
    [super finishedScalingReallySmall:page];
    //
    // clean up gesture state
    [setOfPagesBeingPanned removeObject:page];

    CGFloat duration = 0.3;
    __block MMPaperView* lastPage = nil;
    __block NSMutableSet* pagesThatNeedAnimating = [NSMutableSet set];

    //
    // first, find all pages behind the first full scale
    // page, and just move them immediately
    //
    // this helps pretty dramatically with the animation
    // performance.
    //
    // also, turn off gestures
    void (^step1)(void) = ^{
        //
        // find visible stack pages that we can
        // move immediately
        for(MMPaperView* aPage in [visibleStackHolder.subviews reverseObjectEnumerator]){
            if([pagesThatWillBeVisibleAfterTransitionToListView containsObject:aPage]){
                // we'll animate these in step 2
                [pagesThatNeedAnimating addObject:aPage];
            }else{
                // ok, check if it's full screen
                if(lastPage){
                    // we already have the last visible page, we're going to
                    // hide all other pages during the animation, then re-show
                    // them in their correct positions afterwards
                    aPage.hidden = YES;
                }else{
                    CGRect rect = aPage.frame;
                    if(rect.origin.x <= 0 && rect.origin.y <= 0 && rect.origin.x + rect.size.width >= screenWidth && rect.origin.y + rect.size.height >= screenHeight){
                        // we just found the page that covers the whole screen,
                        // so remember it
                        lastPage = aPage;
                        [pagesThatNeedAnimating addObject:lastPage];
                    }
                }
            }
        }
        //
        // find hidden stack pages that we can
        // move immediately
        for(MMPaperView* aPage in [hiddenStackHolder.subviews reverseObjectEnumerator]){
            if([pagesThatWillBeVisibleAfterTransitionToListView containsObject:aPage]){
                // we'll animate these in step 2
                [pagesThatNeedAnimating addObject:aPage];
            }else{
                // this page won't be visible during the animation anyways,
                // so just hide it altogether, then re-show
                // it in their correct positions afterwards
                aPage.hidden = YES;
            }
            // gestures aren't allowed in list view
            [aPage disableAllGestures];
        }
        //
        // animate shadows
        for(MMPaperView* aPage in pagesThatNeedAnimating){
            if(aPage != lastPage){
                CGRect newFrame = [self framePositionDuringTransitionForPage:aPage originalFrame:aPage.frame withTrust:0.0];
                CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
                theAnimation.duration = duration;
                theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                theAnimation.fromValue = (id) aPage.contentView.layer.shadowPath;
                theAnimation.toValue = (id) [[MMShadowManager sharedInstace] getShadowForSize:newFrame.size];
                [aPage.contentView.layer addAnimation:theAnimation forKey:@"animateShadowPath"];
            }
        }
        CGRect fr = [self frameForAddPageButton];
        fr.origin.y -= initialScrollOffsetFromTransitionToListView.y;
        addPageButtonInListView.frame = fr;
        addPageButtonInListView.alpha = 0;
    };
    
    //
    // make sure all the pages go to the correct place
    // so that it looks like where they'll be in the list view
    void (^step2)(void) = ^{
        //
        // animate all visible stack pages that will be in the
        // visible frame to the correct place
        for(MMPaperView* aPage in pagesThatNeedAnimating){
            if(aPage == lastPage){
                // animate the last page to cover the screen
                // up above the visible page. we have to move it by the expanded frame
                // because shadows count here too
                CGRect newFrame = aPage.frame;
                newFrame.origin.y = -[MMShadowedView expandFrame:newFrame].size.height;
                aPage.frame = newFrame;
            }else{
                // these views we're animating into place
                aPage.frame = [self framePositionDuringTransitionForPage:aPage originalFrame:aPage.frame withTrust:0.0];
            }
        }
        hiddenStackHolder.frame = visibleStackHolder.frame;
        addPageButtonInListView.alpha = 1;
    };

    //
    // all of the pages "look" like they're in the right place,
    // but we need to turn on the scroll view.
    void (^step3)(BOOL finished) = ^(BOOL finished){
        //
        // this means we need to keep the pages visually in the same place,
        // but adjust their frames and the content size/offset so
        // that the scrollview works.
        for(MMPaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]){
            CGRect newFrame = [self frameForListViewForPage:aPage];
            if(!CGRectEqualToRect(newFrame, aPage.frame)){
                aPage.frame = newFrame;
            };
            aPage.hidden = NO;
            // gestures aren't allowed in list view
            [aPage disableAllGestures];
        }
        // set our content height/offset for the pages
        [self setContentOffset:initialScrollOffsetFromTransitionToListView animated:NO];
        [self setContentSize:CGSizeMake(screenWidth, [self contentHeightForAllPages])];
        [self finishUITransitionToListView];
        [setOfFinalFramesForPagesBeingZoomed removeAllObjects];
        [setOfInitialFramesForPagesBeingZoomed removeAllObjects];
        addPageButtonInListView.frame = [self frameForAddPageButton];
        [self moveAddButtonToTop];
    };
    
    step1();
    // ok, animate all the views in the visible stack!
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:step2
                     completion:step3];
    //
    // now that the user has finished the gesture,
    // we can forget about the original frame locations
}

/**
 * the user has cancelled the zoom-to-list gesture
 */
-(void) cancelledScalingReallySmall:(MMPaperView *)page{
    [super cancelledScalingReallySmall:page];
    [self finishUITransitionToPageView];
    if(![page isBeingPannedAndZoomed]){
        [self animatePageToFullScreen:[visibleStackHolder peekSubview] withDelay:0 withBounce:YES onComplete:^(BOOL finished){
            [self realignPagesInVisibleStackExcept:[visibleStackHolder peekSubview] animated:NO];
        }];
        [UIView animateWithDuration:0.1 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveLinear) animations:^{
            CGRect fr = visibleStackHolder.frame;
            fr.origin.x = fr.size.width;
            hiddenStackHolder.frame = fr;
            //
            // reset hidden stack pages
            for(MMPaperView* aPage in [hiddenStackHolder.subviews reverseObjectEnumerator]){
                if(CGRectEqualToRect(aPage.frame, hiddenStackHolder.bounds)){
                    break;
                }else{
                    aPage.frame = hiddenStackHolder.bounds;
                }
            }
        } completion:nil];
    }else{
        for(MMPaperView* aPage in [hiddenStackHolder.subviews reverseObjectEnumerator]){
            if(CGRectEqualToRect(aPage.frame, hiddenStackHolder.bounds)){
                break;
            }else{
                aPage.frame = hiddenStackHolder.bounds;
            }
        }
    }
    [setOfFinalFramesForPagesBeingZoomed removeAllObjects];
}

/**
 * this is called after we've transitioned to page view
 *
 * a bit awkward, but we actually call this on ourselves so
 * that the editablePaperStack can set buttons visibility
 */
-(void) finishedScalingBackToPageView:(MMPaperView*)page{
    [super finishedScalingBackToPageView:page];
    // noop
}

/**
 * this delegate method tells the MMPageView where
 * it sits in the combined visible/hidden stack
 */
-(NSInteger) indexOfPageInCompleteStack:(MMPaperView*)page{
    NSUInteger indexOfPageInVisible = [visibleStackHolder.subviews indexOfObject:page];
    if(indexOfPageInVisible != NSNotFound){
        return indexOfPageInVisible;
    }else{
        return [visibleStackHolder.subviews count] + [hiddenStackHolder.subviews count] - [hiddenStackHolder.subviews indexOfObject:page] - 1;
    }
}

/**
 * return true if the input page is in the visible stack
 */
-(BOOL) isInVisibleStack:(MMPaperView*)page{
    return [visibleStackHolder.subviews indexOfObject:page] != NSNotFound;
}


#pragma mark - MMPanAndPinchFromListViewGestureRecognizerDelegate - Tap Gesture

/**
 * called when a page is pinched in list view
 *
 * this manages the reordering and the zoom in/out from
 * list view to page view
 *
 * TODO
 * when dragging a page around, i can calculate it's center, and compare that
 * to locations in the scrollview. this'll tell me which index it's hovering over
 * based on its offset w/in the scrollview.
 *
 * that index can be used to:
 * a) insert that view into the stack at the specified index, and
 * b) animate all views between the old/new index to their new home
 */
-(void) didPinchAPageInListView:(MMPanAndPinchFromListViewGestureRecognizer*)gesture{
    
    void(^updatePageFrame)() = ^{
        //
        // ok, the top page is the only page that's being panned.
        // and it's zoom is below the min page zoom, so we should
        // start to move it's frame toward its resting place, and also
        // move all the top two rows of pages to their resting place as well
        //
        // how close are we to list view? 1 is not close at all, 0 is list view
        CGFloat percentageToTrustToFrame = gesture.scale / kMinPageZoom;
        
        CGFloat scale = gesture.scale;
        
        if(percentageToTrustToFrame > 1.0){
            //
            // the user has scaled the page above the kMinPageZoom threshhold,
            // so auto-pull that page to full screen
            //
            // also, cancel the gesture so that it doesn't continue to fire
            // after we've committed our animations
            [gesture cancel];
            [self immediatelyAnimateFromListViewToFullScreenView];
            return;
            
        }else if(scale < gesture.initialPageScale + .03){
            scale = gesture.initialPageScale + .03;
        }
        
        //
        // update the location of the dragged page
        pageBeingDragged = gesture.pinchedPage;
        CGPoint locatinInScrollView = [gesture locationInView:self];
        NSInteger indexOfGesture = [self indexForPointInList:locatinInScrollView];
        [self ensurePage:pageBeingDragged isAtIndex:indexOfGesture];
        //
        // scroll update for drag
        lastDragPoint = CGPointMake(locatinInScrollView.x, locatinInScrollView.y - self.contentOffset.y);
        if(displayLink.paused) displayLink.paused = NO;
        
        
        //
        // now, with our pan offset and new scale, we need to calculate the new frame location.
        //
        // first, find the location of the gesture at the size of the page before the gesture began.
        // then, find the location of the gesture at the new scale of the page.
        // since we're using the normalized location of the gesture, this will make sure the before/after
        // location of the gesture is in the same place of the view after scaling the width/height.
        // the difference in these locations is how muh we need to move the origin of the page to
        // accomodate the new scale while maintaining the location of the gesture uner the user's fingers
        //
        // the, add the diff of the pan gesture to get the full displacement of the origin. also set the
        // width and height to the new scale.
        CGPoint lastLocationInSuper = [gesture locationInView:gesture.pinchedPage.superview];
        CGSize superviewSize = self.superview.bounds.size;
        CGPoint locationOfPinchAfterScale = CGPointMake(scale * gesture.normalizedLocationOfScale.x * superviewSize.width,
                                                        scale * gesture.normalizedLocationOfScale.y * superviewSize.height);
        CGSize newSizeOfView = CGSizeMake(superviewSize.width * scale, superviewSize.height * scale);
        
        
        //
        // now calculate our final frame given our pan and zoom
        CGRect fr = self.frame;
        fr.origin = CGPointMake(lastLocationInSuper.x - locationOfPinchAfterScale.x,
                                lastLocationInSuper.y - locationOfPinchAfterScale.y);
        fr.size = newSizeOfView;
        gesture.pinchedPage.frame = fr;
    };
    
    
    
    if(gesture.state == UIGestureRecognizerStateBegan){
        [self setScrollEnabled:NO];
        [self ensurePageIsAtTopOfVisibleStack:gesture.pinchedPage];
        [self beginUITransitionFromListView];
        [UIView animateWithDuration:.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:updatePageFrame completion:nil];
    }else if(gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateFailed){
        // properties for drag behavior
        realizedThatPageIsBeingDragged = NO;
        pageBeingDragged = nil;
        
        // go to page/list view
        // based on how the gesture ended
        [self setScrollEnabled:YES];
        if(gesture.scaleDirection == MMScaleDirectionLarger && gesture.scale > kZoomToListPageZoom){
            // the user has released their pinch, and the page is still really small,
            // but they were *increasing* the size of the page when they let go,
            // so we're going to use that "momentum" and scale the page into view
            [self immediatelyAnimateFromListViewToFullScreenView];
            return;
        }else{
            // the user has released their pinch, and the page is still really small,
            // but they were *decreasing* the size of the page when they let go,
            // so we'll decrease it back into list view
            CGRect frameOfPage = [self frameForListViewForPage:gesture.pinchedPage];
            [UIView animateWithDuration:.15
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 gesture.pinchedPage.frame = frameOfPage;
                             }
                             completion:nil];
            [self finishUITransitionToListView];
        }
    }else if(gesture.state == UIGestureRecognizerStateChanged){
        updatePageFrame();
    }
}

/**
 * maps a point in this view to a page in either
 * the visible or hidden stacks
 */
-(MMPaperView*) pageForPointInList:(CGPoint) point{
    for(MMPaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]){
        CGRect frameOfPage = [self convertRect:aPage.frame fromView:aPage.superview];
        // we have to expand the frame, because we want to count pages even if
        // just their shadow is visible
        frameOfPage = [MMShadowedView expandFrame:frameOfPage];
        if(CGRectContainsPoint(frameOfPage, point)){
            return aPage;
        }
    }
    return nil;
}

-(NSInteger) indexForPointInList:(CGPoint)point{
    NSInteger row = point.y / (rowHeight + bufferWidth);
    NSInteger col = point.x / (columnWidth + bufferWidth);
    return row * kNumberOfColumnsInListView + col;
}


-(CGSize) sizeOfFullscreenPage{
    return CGSizeMake(screenWidth, screenHeight);
}


/**
 * will move the input page to the specified index within the
 * visible/hidden stacks.
 *
 * this will also trigger animations for all the pages that will
 * be affected by this change
 */
-(void) ensurePage:(MMPaperView*)thePage isAtIndex:(NSInteger)newIndex{
    // find out where it currently is
    NSInteger currentIndex = [self indexOfPageInCompleteStack:thePage];
    [self ensurePageIsAtTopOfVisibleStack:thePage];
    // that index is now the top of the visible stack

    if(newIndex > [visibleStackHolder.subviews count] + [hiddenStackHolder.subviews count] - 1){
        // if the page is dragged beyond the bounds
        // of the stacks, then put it at the very end
        newIndex = [visibleStackHolder.subviews count] + [hiddenStackHolder.subviews count] - 1;
    }
    //
    // here, we know that the aPage is at the top of the visible stack,
    // but it's index isn't where it needs to be.
    //
    // so we're either going to add/remove pages below it
    // until the index is in the right place.
    //
    // then we'll animate all the pages we just moved
    NSMutableSet* pagesToAnimate = [NSMutableSet set];
    while([visibleStackHolder.subviews count] - 1 != newIndex){
        if(currentIndex > newIndex){
            // i'm moving lower into the visible stack
            // so i need to pop views off the visible stack
            // and onto the hidden stack
            [hiddenStackHolder pushSubview:[visibleStackHolder getPageBelow:thePage]];
            [pagesToAnimate addObject:[hiddenStackHolder peekSubview]];
            [self clearFrameCacheForPage:[hiddenStackHolder peekSubview]];
        }else if(currentIndex < newIndex){
            // iterate through the hidden stack
            [pagesToAnimate addObject:[hiddenStackHolder peekSubview]];
            [self clearFrameCacheForPage:[hiddenStackHolder peekSubview]];
            [visibleStackHolder insertPage:[hiddenStackHolder peekSubview] belowPage:thePage];
        }
    }
    
    //
    // ok, pages are in the right order, so animate them
    // to their new home
    if([pagesToAnimate count]){
        [UIView animateWithDuration:.15
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             for(MMPaperView* aPage in pagesToAnimate){
                                 CGRect frameOfPage = [self frameForListViewForPage:aPage];
                                 aPage.frame = frameOfPage;
                             }
                         }
                         completion:nil];
        
        [self saveStacksToDisk];
    }
}



-(void) updateScrollOffsetDuringDrag{
    if(!pageBeingDragged){
        //
        // if we're not dragging the page, then don't update the display link
        displayLink.paused = YES;
        return;
    }
    if(!realizedThatPageIsBeingDragged){
        // skip the first call, so that the
        // duration property of the display link
        // will be defined
        realizedThatPageIsBeingDragged = YES;
    }
    
    //
    // we're going to normalize the drag based on the
    // midpoint of the screen.
    CGFloat directionAndAmplitude = lastDragPoint.y - screenHeight / 2;
    // make the max speed faster
    directionAndAmplitude *= 1.5;
    
    // save the middle half of the screen so that
    // we never scroll
    //
    // anything above/below the middle half will begin
    // to scroll
    if(directionAndAmplitude > screenHeight / 4){
        directionAndAmplitude -= screenHeight / 4;
    }else if (directionAndAmplitude < -screenHeight / 4){
        directionAndAmplitude += screenHeight / 4;
    }else{
        directionAndAmplitude = 0;
    }
    
    if(directionAndAmplitude){
        
        //
        // the directionAndAmplitude is the number of points
        // above/below the midpoint. so scale it down so that
        // the user drags roughly 256 / 20 = 12 pts per
        // display update
        CGFloat offsetDelta = directionAndAmplitude * displayLink.duration * 3;
        CGPoint newOffset = self.contentOffset;
        newOffset.y += offsetDelta;
        CGFloat delta = [self validateOffset:newOffset];
        newOffset.y -= delta;
        self.contentOffset = newOffset;
        CGRect fr = pageBeingDragged.frame;
        fr.origin.y += offsetDelta - delta;
        pageBeingDragged.frame = fr;
        
        
        //
        // update the location of the dragged page
        CGPoint locatinInScrollView = CGPointMake(lastDragPoint.x, lastDragPoint.y + self.contentOffset.y);
        NSInteger indexOfGesture = [self indexForPointInList:locatinInScrollView];
        [self ensurePage:pageBeingDragged isAtIndex:indexOfGesture];
    }
}

/**
 * this method accepts an offset that may or may not
 * be within the size bounds of the scroll view.
 * the offset may be negative, or may be far below
 * the end of the list of pages.
 *
 * the returned value is guarenteed to be the correct
 * offset that will keep the pages visible on screen
 * (including the add page button)
 */
-(CGFloat) validateOffset:(CGPoint)possibleOffset{
    CGPoint actualOffset = possibleOffset;
    CGFloat fullHeight = [self contentHeightForAllPages];
    if(actualOffset.y > fullHeight - screenHeight){
        actualOffset.y = fullHeight - screenHeight;
    }
    if(actualOffset.y < 0){
        actualOffset.y = 0;
    }
    return possibleOffset.y - actualOffset.y;
}


#pragma mark - Private Helper Methods

/**
 * this will return the scrollview's ideal contentOffset
 * position that will show the page
 * in the 2nd row of the view if possible.
 *
 * it will properly account for if the page is at the beginning
 * or end of the list
 */
-(CGPoint) offsetNeededToShowPage:(MMPaperView*)page{
    //
    // calculate the number of rows that will be hidden from offset
    NSInteger numberOfHiddenRows = MAX(0, page.rowInListView - 1);
    CGFloat contentHeight = [self contentHeightForAllPages];
    CGPoint possiblePoint = CGPointMake(0, numberOfHiddenRows * (bufferWidth + rowHeight));
    if(possiblePoint.y + self.frame.size.height > contentHeight){
        possiblePoint.y = contentHeight - self.frame.size.height;
    }
    if(possiblePoint.y < 0) possiblePoint.y = 0;
    return possiblePoint;
}

/**
 * calculate the height of the entire list view
 * from the number of both visible and hidden pages
 */
-(CGFloat) contentHeightForAllPages{
    NSInteger numberOfPages = [hiddenStackHolder.subviews count] + [visibleStackHolder.subviews count];
    CGFloat numberOfRows = ceilf(numberOfPages / (CGFloat) kNumberOfColumnsInListView);
    if(numberOfPages % kNumberOfColumnsInListView == 0){
        // need to add a row for the add button
        numberOfRows += 1;
    }
    return numberOfRows * (bufferWidth + rowHeight) + bufferWidth;
}

/**
 * this will help decide which pages will
 * be animated out into list view from page
 * view.
 *
 * the goal is to return as few pages as possible
 * so that we're not animating very many views
 */
-(NSArray*) findPagesInVisibleRowsOfListViewGivenOffset:(CGPoint)eventualOffsetOfListView{
    if(!self.scrollEnabled){
        //
        // ok, scroling is not enabled, which means we're
        // essentially in page view, and need to calculate
        // which pages would be visible if the user
        // switched into list view
        //
        // the top visible page will be at most w/in the top
        // two rows
        
        MMPaperView* aPage = [visibleStackHolder peekSubview];
        NSMutableArray* pagesThatWouldBeVisible = [NSMutableArray arrayWithObject:aPage];
        CGRect rectOfVisibleScroll = CGRectMake(eventualOffsetOfListView.x, eventualOffsetOfListView.y, screenWidth, screenHeight);
        while((aPage = [visibleStackHolder getPageBelow:aPage])){
            CGRect frameOfPage = [self frameForListViewForPage:aPage];
            // we have to expand the frame, because we want to count pages even if
            // just their shadow is visible
            frameOfPage = [MMShadowedView expandFrame:frameOfPage];
            if(frameOfPage.origin.y + frameOfPage.size.height > rectOfVisibleScroll.origin.y &&
               frameOfPage.origin.y < rectOfVisibleScroll.origin.y + rectOfVisibleScroll.size.height){
                [pagesThatWouldBeVisible insertObject:aPage atIndex:0];
            }else{
                break;
            }
        }
        
        aPage = [hiddenStackHolder peekSubview];
        if(aPage){
            //
            // only care about the hidden stack if there's anything
            // actually in the stack
            [pagesThatWouldBeVisible addObject:aPage];
            while((aPage = [hiddenStackHolder getPageBelow:aPage])){
                CGRect frameOfPage = [self frameForListViewForPage:aPage];
                // we have to expand the frame, because we want to count pages even if
                // just their shadow is visible
                frameOfPage = [MMShadowedView expandFrame:frameOfPage];
                if(frameOfPage.origin.y + frameOfPage.size.height > rectOfVisibleScroll.origin.y &&
                   frameOfPage.origin.y < rectOfVisibleScroll.origin.y + rectOfVisibleScroll.size.height){
                    [pagesThatWouldBeVisible insertObject:aPage atIndex:0];
                }else{
                    break;
                }
            }
        }
        
        return pagesThatWouldBeVisible;
    }else{
        //
        // scrolling is enabled, so we need to return
        // the list of pages that are currently visible
        NSMutableArray* pagesThatWouldBeVisible = [NSMutableArray array];
        for(MMPaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]){
            CGRect frameOfPage = [self frameForListViewForPage:aPage];
            // we have to expand the frame, because we want to count pages even if
            // just their shadow is visible
            frameOfPage = [MMShadowedView expandFrame:frameOfPage];
            if(frameOfPage.origin.y < self.contentOffset.y + self.frame.size.height &&
               frameOfPage.origin.y + frameOfPage.size.height > self.contentOffset.y){
                [pagesThatWouldBeVisible addObject:aPage];
            }
        }
        return pagesThatWouldBeVisible;
    }
}


/**
 * makes sure that the input page is at the top of the visible
 * stack. this will move pages on/off the visible stack to/from
 * the hidden stack to preserve stack order.
 */
-(void) ensurePageIsAtTopOfVisibleStack:(MMPaperView*)aPage{
    //
    // ok, we know what page was tapped.
    //
    // now we need to make sure that page is on the top
    // of the visible stack
    [self willChangeTopPageTo:aPage];
    if([self isInVisibleStack:aPage]){
        // the page is in teh visible stack, so pop pages
        // onto the hidden stack so that this page is the
        // top visible page
        while([visibleStackHolder peekSubview] != aPage){
            [hiddenStackHolder pushSubview:[visibleStackHolder peekSubview]];
        }
    }else{
        // the page is in the hidden stack, so pop pages
        // onto the visible stack so that this page is the
        // top visible page
        while([visibleStackHolder peekSubview] != aPage){
            [visibleStackHolder pushSubview:[hiddenStackHolder peekSubview]];
        }
    }
}

/**
 * this method helps transition from a page's current frame
 * to that page's new frame in the list view.
 *
 * the percentageToTrustToFrame ranges from 0 to 1.
 * if the value is 1, then the frame that's returned is
 * exactly the same as the input oldFrame.
 *
 * if the value is 0, then the frame that's returned is it's
 * position in the list view (during the transition).
 *
 * since the transition to list view has to adjust for the
 * contentOffset, then the list frame will be adjusted
 * up screen by numberOfHiddenRows
 */
-(CGRect) framePositionDuringTransitionForPage:(MMPaperView*)page originalFrame:(CGRect)oldFrame withTrust:(CGFloat)percentageToTrustToFrame{
    if(percentageToTrustToFrame < 0) percentageToTrustToFrame = 0;
    if(percentageToTrustToFrame > 1) percentageToTrustToFrame = 1;
    // final frame when the page is in the list view
    CGRect finalFrame = [self frameForListViewForPage:page];
    finalFrame.origin.x -= initialScrollOffsetFromTransitionToListView.x;
    finalFrame.origin.y -= initialScrollOffsetFromTransitionToListView.y;
    
    //
    // ok, set the new frame that we'll return
    CGRect newFrame = CGRectZero;
    newFrame.origin.x = finalFrame.origin.x - (finalFrame.origin.x - oldFrame.origin.x) * percentageToTrustToFrame;
    newFrame.origin.y = finalFrame.origin.y - (finalFrame.origin.y - oldFrame.origin.y) * percentageToTrustToFrame;
    newFrame.size.width = finalFrame.size.width - (finalFrame.size.width - oldFrame.size.width) * percentageToTrustToFrame;
    newFrame.size.height = finalFrame.size.height - (finalFrame.size.height - oldFrame.size.height) * percentageToTrustToFrame;
    
    return newFrame;
}


/**
 * the user has scaled small enough with the top page
 * that we can take over and just animate the rest.
 *
 * so we need to cancel it's gestures, then calculate
 * the final resting place for every page in the visible
 * stack, then animate them.
 *
 * we're going to scale pages in the first two rows, and
 * we'll just slide any pages below that above the screen.
 *
 * when the animation completes, we'll adjust all the frames
 * and content offsets to that the user can scroll them
 */
-(void) immediatelyAnimateFromListViewToFullScreenView{
    
    __block NSMutableSet* pagesThatNeedAnimating = [NSMutableSet set];
    
    CGFloat duration = 0.2;
    
    //
    // all of the pages "look" like they're in the right place,
    // but we need to turn on the scroll view.
    void (^step1)(void) = ^{
        //
        // this means we need to keep the pages visually in the same place,
        // but adjust their frames and the content size/offset so
        // that we can set the scrollview offset to zero and turn off scrolling
        if(self.contentOffset.y > 0){
            for(MMPaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]){
                CGRect newFrame = aPage.frame;
                newFrame.origin.y -= self.contentOffset.y;
                if(!CGRectEqualToRect(newFrame, aPage.frame)){
                    aPage.frame = newFrame;
                };
            }
        }
        // set our content height/offset for the pages
        [self beginUITransitionFromListView];
        [self setContentOffset:CGPointZero animated:NO];
        [self setContentSize:CGSizeMake(screenWidth, screenHeight)];
        [self setScrollEnabled:NO];
        [setOfFinalFramesForPagesBeingZoomed removeAllObjects];
        [setOfInitialFramesForPagesBeingZoomed removeAllObjects];
        
        [pagesThatNeedAnimating addObjectsFromArray:pagesThatWillBeVisibleAfterTransitionToListView];
        for(MMPaperView* aPage in pagesThatNeedAnimating){
            //
            // animate shadows
            CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
            theAnimation.duration = duration;
            theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            theAnimation.fromValue = (id) aPage.contentView.layer.shadowPath;
            CGSize toSize = visibleStackHolder.bounds.size;
            if(aPage == [visibleStackHolder peekSubview]){
                toSize = [MMShadowedView expandBounds:visibleStackHolder.bounds].size;
            }
            theAnimation.toValue = (id) [[MMShadowManager sharedInstace] getShadowForSize:toSize];
            [aPage.contentView.layer addAnimation:theAnimation forKey:@"animateShadowPath"];
        }
        [visibleStackHolder.superview insertSubview:hiddenStackHolder belowSubview:visibleStackHolder];
        addPageButtonInListView.frame = [self frameForAddPageButton];
        [self moveAddButtonToBottom];
    };
    
    //
    // make sure all the pages go to the correct place
    // so that it looks like where they'll be in the list view
    void (^step2)(void) = ^{
        //
        // animate all visible stack pages that will be in the
        // visible frame to the correct place
        for(MMPaperView* aPage in pagesThatNeedAnimating){
            if(aPage == [visibleStackHolder peekSubview]){
                aPage.frame = [MMPaperView expandFrame:visibleStackHolder.bounds];
            }else if([self isInVisibleStack:aPage]){
                aPage.frame = visibleStackHolder.bounds;
            }else{
                aPage.frame = hiddenStackHolder.bounds;
            }
        }
        CGRect newHiddenFrame = visibleStackHolder.frame;
        newHiddenFrame.origin.x += screenWidth;
        hiddenStackHolder.frame = newHiddenFrame;
        addPageButtonInListView.alpha = 0;
        [self finishedScalingBackToPageView:[visibleStackHolder peekSubview]];
    };
    
    
    
    
    //
    // first, find all pages behind the first full scale
    // page, and just move them immediately
    //
    // this helps pretty dramatically with the animation
    // performance.
    //
    // also, turn off gestures
    void (^step3)(BOOL finished) = ^(BOOL finished){
        //
        // now complete the bounce for the top page
        CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        theAnimation.duration = 0.15;
        theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        theAnimation.fromValue = (id) [visibleStackHolder peekSubview].contentView.layer.shadowPath;
        theAnimation.toValue = (id) [[MMShadowManager sharedInstace] getShadowForSize:self.bounds.size];
        [[visibleStackHolder peekSubview].contentView.layer addAnimation:theAnimation forKey:@"animateShadowPath"];
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^(void){
                             [visibleStackHolder peekSubview].frame = self.bounds;
                         } completion:^(BOOL finished){
                             //
                             // find visible stack pages that we can
                             // move immediately
                             for(MMPaperView* aPage in [visibleStackHolder.subviews reverseObjectEnumerator]){
                                 aPage.frame = visibleStackHolder.bounds;
                                 [aPage enableAllGestures];
                                 aPage.scale = 1;
                             }
                             for(MMPaperView* aPage in [hiddenStackHolder.subviews reverseObjectEnumerator]){
                                 aPage.frame = hiddenStackHolder.bounds;
                                 aPage.scale = 1;
                             }
                             [self finishUITransitionToPageView];
                         }];
    };
    
    
    step1();
    
    
    // ok, animate all the views in the visible stack!
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:step2
                     completion:step3];
    //
    // now that the user has finished the gesture,
    // we can forget about the original frame locations
}


#pragma mark Private Tap Gesture

/**
 * we are in list view, and the user tapped onto the
 * scrollview (probably tapped a page).
 *
 * let's check if the user tapped a page, and zoom
 * to that page as the top of the visible stack
 */
-(void) didTapScrollView:(UITapGestureRecognizer*)_tapGesture{
    //
    // first, we should find which page the user tapped
    CGPoint locationOfTap = [_tapGesture locationInView:self];
    
    MMPaperView* thePageThatWasTapped = nil;
    for(MMPaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]){
        CGRect frameOfPage = [self frameForListViewForPage:aPage];
        if(CGRectContainsPoint(frameOfPage, locationOfTap)){
            thePageThatWasTapped = aPage;
        }
    }
    if(!thePageThatWasTapped) return;
    
    
    [self ensurePageIsAtTopOfVisibleStack:thePageThatWasTapped];
    
    [self immediatelyAnimateFromListViewToFullScreenView];
    
}


-(BOOL) shouldPopPageFromVisibleStack:(MMPaperView*)page withFrame:(CGRect)frame{
    if([visibleStackHolder peekSubview].scale < kMinPageZoom){
        return NO;
    }
    return [super shouldPopPageFromVisibleStack:page withFrame:frame];
}

@end
