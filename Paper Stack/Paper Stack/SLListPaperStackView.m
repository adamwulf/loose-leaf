//
//  SLListPaperStackView.m
//  scratchpaper
//
//  Created by Adam Wulf on 7/3/12.
//
//

#import "SLListPaperStackView.h"
#import "SLPaperView+ListView.h"
#import "UIView+Debug.h"
#import "NSThread+BlocksAdditions.h"

@implementation SLListPaperStackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib{
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
    
    
    [super awakeFromNib];
}

#pragma mark - Local Cache

//
// for any given gesture, the frameForListViewGivenRowHeight:andColumnWidth: for any page
// will be the same, so let's cache that for this gesture
-(CGRect) frameForListViewForPage:(SLPaperView*)page givenRowHeight:(CGFloat)_rowHeight andColumnWidth:(CGFloat)_columnWidth{
    NSValue* finalFrame = [setOfFinalFramesForPagesBeingZoomed objectForKey:page.uuid];
    if(finalFrame){
        return [finalFrame CGRectValue];
    }
    CGRect frameOfPage = [page frameForListViewGivenRowHeight:_rowHeight andColumnWidth:_columnWidth];
    [setOfFinalFramesForPagesBeingZoomed setObject:[NSValue valueWithCGRect:frameOfPage] forKey:page.uuid];
    return frameOfPage;
}


#pragma mark - Future Model Methods

/**
 * this will return the scrollview's ideal contentOffset
 * position that will show the page
 * in the 2nd row of the view if possible
 */
-(CGPoint) offsetNeededToShowPage:(SLPaperView*)page{
    //
    // calculate the number of rows that will be hidden from offset
    SLPaperView* topPage = [visibleStackHolder peekSubview];
    NSInteger numberOfHiddenRows = MAX(0, topPage.rowInListView - 1);
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
    SLPaperView* topHiddenPage = [hiddenStackHolder bottomSubview];
    NSInteger totalRows = topHiddenPage.rowInListView;
    // add 1 since rows start at 0
    CGFloat contentHeight = (totalRows + 1) * (bufferWidth + rowHeight) + bufferWidth;
    return contentHeight;
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
        
        SLPaperView* aPage = [visibleStackHolder peekSubview];
        NSMutableArray* pagesThatWouldBeVisible = [NSMutableArray arrayWithObject:aPage];
        CGRect rectOfVisibleScroll = CGRectMake(eventualOffsetOfListView.x, eventualOffsetOfListView.y, screenWidth, screenHeight);
        while((aPage = [visibleStackHolder getPageBelow:aPage])){
            CGRect frameOfPage = [self frameForListViewForPage:aPage givenRowHeight:rowHeight andColumnWidth:columnWidth];
            // we have to expand the frame, because we want to count pages even if
            // just their shadow is visible
            frameOfPage = [SLShadowedView expandFrame:frameOfPage];
            if(frameOfPage.origin.y + frameOfPage.size.height > rectOfVisibleScroll.origin.y &&
               frameOfPage.origin.y < rectOfVisibleScroll.origin.y + rectOfVisibleScroll.size.height){
                [pagesThatWouldBeVisible insertObject:aPage atIndex:0];
            }else{
                break;
            }
        }
        
        aPage = [hiddenStackHolder peekSubview];
        [pagesThatWouldBeVisible addObject:aPage];
        while((aPage = [hiddenStackHolder getPageBelow:aPage])){
            CGRect frameOfPage = [self frameForListViewForPage:aPage givenRowHeight:rowHeight andColumnWidth:columnWidth];
            // we have to expand the frame, because we want to count pages even if
            // just their shadow is visible
            frameOfPage = [SLShadowedView expandFrame:frameOfPage];
            if(frameOfPage.origin.y + frameOfPage.size.height > rectOfVisibleScroll.origin.y &&
               frameOfPage.origin.y < rectOfVisibleScroll.origin.y + rectOfVisibleScroll.size.height){
                [pagesThatWouldBeVisible insertObject:aPage atIndex:0];
            }else{
                break;
            }
        }
        
        return pagesThatWouldBeVisible;
    }else{
        //
        // scrolling is enabled, so we need to return
        // the list of pages that are currently visible
        NSMutableArray* pagesThatWouldBeVisible = [NSMutableArray array];
        for(SLPaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]){
            CGRect frameOfPage = [self frameForListViewForPage:aPage givenRowHeight:rowHeight andColumnWidth:columnWidth];
            // we have to expand the frame, because we want to count pages even if
            // just their shadow is visible
            frameOfPage = [SLShadowedView expandFrame:frameOfPage];
            if(frameOfPage.origin.y < self.contentOffset.y + self.frame.size.height &&
               frameOfPage.origin.y + frameOfPage.size.height > self.contentOffset.y){
                [pagesThatWouldBeVisible addObject:aPage];
            }
        }
        return pagesThatWouldBeVisible;
    }
}




#pragma mark - List View Enable / Disable Helper Methods

/**
 * the user is beginning to transition between list/page view
 * and is starting from the Page view
 */
-(void) beginUITransitionFromPageView{
    [self ensureAtLeast:1 pagesInStack:hiddenStackHolder];
    // clear our cache of frame locations
    [setOfFinalFramesForPagesBeingZoomed removeAllObjects];
    // ok, now we can get offset
    initialScrollOffsetFromTransitionToListView = [self offsetNeededToShowPage:[visibleStackHolder peekSubview]];
    // from offset/height, we know which views will be visible
    pagesThatWillBeVisibleAfterTransitionToListView = [[self findPagesInVisibleRowsOfListViewGivenOffset:initialScrollOffsetFromTransitionToListView] retain];
    // bezeling in from right is no longer allowed
    [fromRightBezelGesture setEnabled:NO];
    [hiddenStackHolder setClipsToBounds:NO];
    [visibleStackHolder setClipsToBounds:NO];
    [self setScrollEnabled:NO];
    [tapGesture setEnabled:NO];
}

/**
 * the user is beginning to transition between list/page view
 * and is starting from the List view
 */
-(void) beginUITransitionFromListView{
    [self ensureAtLeast:1 pagesInStack:hiddenStackHolder];
    // clear our cache of frame locations
    [setOfFinalFramesForPagesBeingZoomed removeAllObjects];
    // ok, now we can get offset
    initialScrollOffsetFromTransitionToListView = [self offsetNeededToShowPage:[visibleStackHolder peekSubview]];
    // from offset/height, we know which views will be visible
    pagesThatWillBeVisibleAfterTransitionToListView = [[self findPagesInVisibleRowsOfListViewGivenOffset:initialScrollOffsetFromTransitionToListView] retain];
    // bezeling in from right is no longer allowed
    [fromRightBezelGesture setEnabled:NO];
    [hiddenStackHolder setClipsToBounds:NO];
    [visibleStackHolder setClipsToBounds:NO];
    [self setScrollEnabled:NO];
    [tapGesture setEnabled:NO];
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
    [pagesThatWillBeVisibleAfterTransitionToListView release];
    pagesThatWillBeVisibleAfterTransitionToListView = nil;
}

/**
 * the user has confirmed that they want to complete the
 * transition into page view from the transition state
 */
-(void) finishUITransitionToPageView{
    [setOfInitialFramesForPagesBeingZoomed removeAllObjects];
    [fromRightBezelGesture setEnabled:YES];
    [visibleStackHolder setClipsToBounds:YES];
    [hiddenStackHolder setClipsToBounds:YES];
    [self setScrollEnabled:NO];
    [tapGesture setEnabled:NO];
    [pagesThatWillBeVisibleAfterTransitionToListView release];
    pagesThatWillBeVisibleAfterTransitionToListView = nil;
}





#pragma mark - SLPaperViewDelegate - Paper View

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
-(CGRect) zoomToListFrameForPage:(SLPaperView*)page oldToFrame:(CGRect)oldFrame withTrust:(CGFloat)percentageToTrustToFrame{
    if(percentageToTrustToFrame < 0) percentageToTrustToFrame = 0;
    if(percentageToTrustToFrame > 1) percentageToTrustToFrame = 1;
    // final frame when the page is in the list view
    CGRect finalFrame = [self frameForListViewForPage:page givenRowHeight:rowHeight andColumnWidth:columnWidth];
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


-(CGRect) isPanningAndScalingPage:(SLPaperView*)page fromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame{
    if([visibleStackHolder peekSubview] == page){
        
        //
        // defer to bezel gesture
        if([page willExitToBezel:SLBezelDirectionLeft | SLBezelDirectionRight]){
            return [super isPanningAndScalingPage:page fromFrame:fromFrame toFrame:toFrame];
        }
        
        // make sure we're the top page being panned
        if([visibleStackHolder peekSubview].scale < kMinPageZoom){
            //
            // once the zoom is below kMinPageZoom and still above kZoomToListPageZoom,
            // then we need to adjust the frames of all the pages so that they zoom
            // into their list view frames correctly
            
            if([[setOfPagesBeingPanned setByRemovingObject:[visibleStackHolder peekSubview]] count]){
                // still pages being panned, this'll be caught by the isBeginningToScaleReallySmall handler
                //
                // while we wait for those other pages to have their gesturs cancelled, we'll just
                // return the toFrame so the gesture can continue
                return toFrame;
            }
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

            //
            // ok, move all the soon to be visible pages into their
            // position
            CGFloat transitionDelay = 0;
            for(SLPaperView* aPage in pagesThatWillBeVisibleAfterTransitionToListView){
                if(aPage != page){
                    CGRect oldFrame = hiddenStackHolder.bounds;
                    BOOL pageIsInVisibleStack = [self isInVisibleStack:aPage];
                    if(pageIsInVisibleStack){
                        oldFrame = [[setOfInitialFramesForPagesBeingZoomed objectForKey:aPage.uuid] CGRectValue];
                    }
                    CGRect newFrame = [self zoomToListFrameForPage:aPage oldToFrame:oldFrame withTrust:percentageToTrustToFrame + transitionDelay];
                    if(!pageIsInVisibleStack){
                        //
                        // this helps the hidden pages to show coming in from
                        // the right
                        newFrame.origin.x -= amountToMoveHiddenFrame;
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
            // the cancelled state will be caught in SLPaperStackView, so
            // the frame is not adjusted after we animate the page to
            // it's resting place
            if([visibleStackHolder peekSubview].scale < kZoomToListPageZoom){
                [[visibleStackHolder peekSubview] cancelAllGestures];
                return fromFrame;
            }
            return [self zoomToListFrameForPage:page oldToFrame:toFrame withTrust:percentageToTrustToFrame];
        }
    }
    return [super isPanningAndScalingPage:page fromFrame:fromFrame toFrame:toFrame];
}

#pragma mark - SLPaperViewDelegate - List View

/**
 * the user has scaled a page small enough for us to 
 * trigger the zoom to list view
 */
-(void) isBeginningToScaleReallySmall:(SLPaperView *)page{

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
        for(SLPaperView* page in setOfAllPannedPagesExceptTopVisible){
            [page cancelAllGestures];
        }
    }
    //
    // the bezelStackHolder may have subviews from a gesture
    // so empty that stack to the hidden stack before
    // we can continue scaling out
    if([bezelStackHolder.subviews count]){
        [self emptyBezelStackToHiddenStackAnimated:YES onComplete:^(BOOL finished){
            if(finished){
                // ok, bezel should be empty, try again
                [self isBeginningToScaleReallySmall:page];
            }
        }];
    }else{
        [self beginUITransitionFromPageView];
        //
        // ok, we're allowed to zoom out to list view, so save the frames
        // of all the pages in the visible stack
        for(SLPaperView* aPage in visibleStackHolder.subviews){
            [setOfInitialFramesForPagesBeingZoomed setObject:[NSValue valueWithCGRect:aPage.frame] forKey:aPage.uuid];
        }
    }
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
-(void) finishedScalingReallySmall:(SLPaperView *)page{
    //
    // clean up gesture state
    [setOfPagesBeingPanned removeObject:page];

    __block SLPaperView* lastPage = nil;
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
        for(SLPaperView* aPage in [visibleStackHolder.subviews reverseObjectEnumerator]){
            if([pagesThatWillBeVisibleAfterTransitionToListView containsObject:aPage]){
                // we'll animate these in step 2
                [pagesThatNeedAnimating addObject:aPage];
            }else{
                // ok, check if it's full screen
                CGRect rect = aPage.frame;
                if(lastPage){
                    // we already have the last visible page, move this one
                    // immediately. we have to move it by the expanded frame
                    // because shadows count here too
                    rect.origin.y = -[SLShadowedView expandFrame:rect].size.height;
                    aPage.frame = rect;
                }else if(rect.origin.x <= 0 && rect.origin.y <= 0 && rect.origin.x + rect.size.width >= screenWidth && rect.origin.y + rect.size.height >= screenHeight){
                    // we just found the page that covers the whole screen,
                    // so remember it
                    lastPage = aPage;
                    [pagesThatNeedAnimating addObject:lastPage];
                }
            }
            // gestures aren't allowed in list view
            [aPage disableAllGestures];
        }
        //
        // find hidden stack pages that we can
        // move immediately
        for(SLPaperView* aPage in [hiddenStackHolder.subviews reverseObjectEnumerator]){
            if([pagesThatWillBeVisibleAfterTransitionToListView containsObject:aPage]){
                // we'll animate these in step 2
                [pagesThatNeedAnimating addObject:aPage];
            }else{
                CGRect rect = aPage.frame;
                // we have to move it by the expanded frame
                // because shadows count here too
                rect.origin.y = -[SLShadowedView expandFrame:rect].size.height;
                aPage.frame = rect;
            }
            // gestures aren't allowed in list view
            [aPage disableAllGestures];
        }
    };
    
    //
    // make sure all the pages go to the correct place
    // so that it looks like where they'll be in the list view
    void (^step2)(void) = ^{
        //
        // animate all visible stack pages that will be in the
        // visible frame to the correct place
        for(SLPaperView* aPage in pagesThatNeedAnimating){
            if(aPage == lastPage){
                // animate the last page to cover the screen
                // up above the visible page. we have to move it by the expanded frame
                // because shadows count here too
                CGRect newFrame = aPage.frame;
                newFrame.origin.y = -[SLShadowedView expandFrame:newFrame].size.height;
                aPage.frame = newFrame;
            }else{
                // these views we're animating into place
                aPage.frame = [self zoomToListFrameForPage:aPage oldToFrame:aPage.frame withTrust:0.0];
            }
        }
        hiddenStackHolder.frame = visibleStackHolder.frame;
    };

    //
    // all of the pages "look" like they're in the right place,
    // but we need to turn on the scroll view.
    void (^step3)(BOOL finished) = ^(BOOL finished){
        //
        // this means we need to keep the pages visually in the same place,
        // but adjust their frames and the content size/offset so
        // that the scrollview works.
        for(SLPaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]){
            CGRect newFrame = [self frameForListViewForPage:aPage givenRowHeight:rowHeight andColumnWidth:columnWidth];
            if(!CGRectEqualToRect(newFrame, aPage.frame)){
                aPage.frame = newFrame;
            };
        }
        // set our content height/offset for the pages
        [self setContentOffset:initialScrollOffsetFromTransitionToListView animated:NO];
        [self setContentSize:CGSizeMake(screenWidth, [self contentHeightForAllPages])];
        [self finishUITransitionToListView];
        [setOfFinalFramesForPagesBeingZoomed removeAllObjects];
        [setOfInitialFramesForPagesBeingZoomed removeAllObjects];
    };
    
    
    
    step1();
    // ok, animate all the views in the visible stack!
    [UIView animateWithDuration:.3
                          delay:0
                        options:UIViewAnimationCurveEaseOut
                     animations:step2
                     completion:step3];
    //
    // now that the user has finished the gesture,
    // we can forget about the original frame locations
}

/**
 * the user has cancelled the zoom-to-list gesture
 */
-(void) cancelledScalingReallySmall:(SLPaperView *)page{
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
            for(SLPaperView* aPage in [hiddenStackHolder.subviews reverseObjectEnumerator]){
                if(CGRectEqualToRect(aPage.frame, hiddenStackHolder.bounds)){
                    break;
                }else{
                    aPage.frame = hiddenStackHolder.bounds;
                }
            }
        } completion:nil];
    }
    [setOfFinalFramesForPagesBeingZoomed removeAllObjects];
}

/**
 * this is called after we've transitioned to page view
 *
 * a bit awkward, but we actually call this on ourselves so
 * that the editablePaperStack can set buttons visibility
 */
-(void) finishedScalingBackToPageView:(SLPaperView*)page{
    // noop
}


/**
 * this delegate method tells the SLPageView where
 * it sits in the combined visible/hidden stack
 */
-(NSInteger) indexOfPageInCompleteStack:(SLPaperView*)page{
    if([self isInVisibleStack:page]){
        return [visibleStackHolder.subviews indexOfObject:page];
    }else{
        return [visibleStackHolder.subviews count] + [hiddenStackHolder.subviews count] - [hiddenStackHolder.subviews indexOfObject:page] - 1;
    }
}



/**
 * return true if the input page is in the visible stack
 */
-(BOOL) isInVisibleStack:(SLPaperView*)page{
    return [visibleStackHolder containsSubview:page];
}



#pragma mark - SLPaperViewDelegate - Tap Gesture
 
 
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

    SLPaperView* thePageThatWasTapped = nil;
    for(SLPaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]){
        CGRect frameOfPage = [aPage frameForListViewGivenRowHeight:rowHeight andColumnWidth:columnWidth];
        if(CGRectContainsPoint(frameOfPage, locationOfTap)){
            thePageThatWasTapped = aPage;
        }
    }
    if(!thePageThatWasTapped) return;
    
    
    //
    // ok, we know what page was tapped.
    //
    // now we need to make sure that page is on the top
    // of the visible stack
    if([self isInVisibleStack:thePageThatWasTapped]){
        // the page is in teh visible stack, so pop pages
        // onto the hidden stack so that this page is the
        // top visible page
        while([visibleStackHolder peekSubview] != thePageThatWasTapped){
            [hiddenStackHolder pushSubview:[visibleStackHolder peekSubview]];
        }
    }else{
        // the page is in the hidden stack, so pop pages
        // onto the visible stack so that this page is the
        // top visible page
        while([visibleStackHolder peekSubview] != thePageThatWasTapped){
            [visibleStackHolder pushSubview:[hiddenStackHolder peekSubview]];
        }
    }
    
    [self animateFromListViewToFullScreenView:thePageThatWasTapped];
    
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
-(void) animateFromListViewToFullScreenView:(SLPaperView *)page{
    
    __block NSMutableSet* pagesThatNeedAnimating = [NSMutableSet set];
    
    
    
    //
    // all of the pages "look" like they're in the right place,
    // but we need to turn on the scroll view.
    void (^step1)(void) = ^{
        //
        // this means we need to keep the pages visually in the same place,
        // but adjust their frames and the content size/offset so
        // that we can set the scrollview offset to zero and turn off scrolling
        for(SLPaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]){
            CGRect newFrame = aPage.frame;
            newFrame.origin.y -= self.contentOffset.y;
            if(!CGRectEqualToRect(newFrame, aPage.frame)){
                aPage.frame = newFrame;
            };
        }
        // set our content height/offset for the pages
        [self beginUITransitionFromListView];
        [self setContentOffset:CGPointZero animated:NO];
        [self setContentSize:CGSizeMake(screenWidth, screenHeight)];
        [self setScrollEnabled:NO];
        [setOfFinalFramesForPagesBeingZoomed removeAllObjects];
        [setOfInitialFramesForPagesBeingZoomed removeAllObjects];
        
        [pagesThatNeedAnimating addObjectsFromArray:pagesThatWillBeVisibleAfterTransitionToListView];
        
        [visibleStackHolder.superview insertSubview:hiddenStackHolder belowSubview:visibleStackHolder];
    };
    
    //
    // make sure all the pages go to the correct place
    // so that it looks like where they'll be in the list view
    void (^step2)(void) = ^{
        //
        // animate all visible stack pages that will be in the
        // visible frame to the correct place
        for(SLPaperView* aPage in pagesThatNeedAnimating){
            if(aPage == [visibleStackHolder peekSubview]){
                aPage.frame = [SLPaperView expandFrame:visibleStackHolder.bounds];
            }else if([self isInVisibleStack:aPage]){
                aPage.frame = visibleStackHolder.bounds;
            }else{
                aPage.frame = hiddenStackHolder.bounds;
            }
        }
        CGRect newHiddenFrame = visibleStackHolder.frame;
        newHiddenFrame.origin.x += screenWidth;
        hiddenStackHolder.frame = newHiddenFrame;
        
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
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^(void){
                             [visibleStackHolder peekSubview].frame = self.bounds;
                         } completion:^(BOOL finished){
                             [self finishUITransitionToPageView];

                             //
                             // find visible stack pages that we can
                             // move immediately
                             for(SLPaperView* aPage in [visibleStackHolder.subviews reverseObjectEnumerator]){
                                 aPage.frame = visibleStackHolder.bounds;
                                 [aPage enableAllGestures];
                                 page.scale = 1;
                             }
                             for(SLPaperView* aPage in [hiddenStackHolder.subviews reverseObjectEnumerator]){
                                 aPage.frame = hiddenStackHolder.bounds;
                                 page.scale = 1;
                             }
                             [visibleStackHolder.superview insertSubview:visibleStackHolder belowSubview:hiddenStackHolder];
                         }];
    };
    
    
    step1();
    

    // ok, animate all the views in the visible stack!
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationCurveEaseOut
                     animations:step2
                     completion:step3];
    //
    // now that the user has finished the gesture,
    // we can forget about the original frame locations
}






@end
