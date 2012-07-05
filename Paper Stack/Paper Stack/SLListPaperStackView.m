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
    SLPaperView* topHiddenPage = [hiddenStackHolder peekSubview];
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
-(NSArray*) pagesInVisibleRowsOfListView{
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
        CGRect rectOfVisibleScroll = CGRectMake(initialScrollOffsetFromTransitionToListView.x, initialScrollOffsetFromTransitionToListView.y, screenWidth, screenHeight);
        while((aPage = [visibleStackHolder getPageBelow:aPage])){
            CGRect frameOfPage = [self frameForListViewForPage:aPage givenRowHeight:rowHeight andColumnWidth:columnWidth];
            if(frameOfPage.origin.y + frameOfPage.size.height > rectOfVisibleScroll.origin.y &&
               frameOfPage.origin.y < rectOfVisibleScroll.origin.y + rectOfVisibleScroll.size.height){
                [pagesThatWouldBeVisible insertObject:aPage atIndex:0];
            }else{
                break;
            }
        }
        
        aPage = [hiddenStackHolder.subviews objectAtIndex:0];
        [pagesThatWouldBeVisible addObject:aPage];
        while((aPage = [hiddenStackHolder getPageAbove:aPage])){
            CGRect frameOfPage = [self frameForListViewForPage:aPage givenRowHeight:rowHeight andColumnWidth:columnWidth];
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
 * list view is half enabled as the user
 * gestures into the list view
 *
 * it is disabled when the user cancels the 
 * gesture
 */
-(void) setListViewHalfEnabled:(BOOL)halfEnabled{
    if(halfEnabled){
        [self ensureAtLeast:1 pagesInStack:hiddenStackHolder];
        // clear our cache of frame locations
        [setOfFinalFramesForPagesBeingZoomed removeAllObjects];
        // calculate height first, that'll help determine offset
        contentHeightFromTransitionToListView = [self contentHeightForAllPages];
        // ok, now we can get offset
        initialScrollOffsetFromTransitionToListView = [self offsetNeededToShowPage:[visibleStackHolder peekSubview]];
        // from offset/height, we know which views will be visible
        pagesThatWillBeVisibleAfterTransitionToListView = [[self pagesInVisibleRowsOfListView] retain];
        // bezeling in from right is no longer allowed
        [fromRightBezelGesture setEnabled:NO];
    }else{
        [setOfInitialFramesForPagesBeingZoomed removeAllObjects];
        [tapGesture setEnabled:NO];
        [pagesThatWillBeVisibleAfterTransitionToListView release];
        pagesThatWillBeVisibleAfterTransitionToListView = nil;
        [fromRightBezelGesture setEnabled:YES];
    }
}

/**
 * a list view is entirely enabled when the user
 * confirms the list view gesture.
 *
 * when the user taps to return to paper view,
 * the list view is set to entirely disabled
 */
-(void) setListViewEntirelyEnabled:(BOOL)entirelyEnabled{
    if(entirelyEnabled){
        [visibleStackHolder setClipsToBounds:NO];
        [hiddenStackHolder setClipsToBounds:NO];
        [self setScrollEnabled:YES];
        [tapGesture setEnabled:YES];
        [pagesThatWillBeVisibleAfterTransitionToListView release];
        pagesThatWillBeVisibleAfterTransitionToListView = nil;
    }else{
        // TODO allow user to disable list view
    }
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
            // ok, move all the soon to be visible pages into their
            // position
            for(SLPaperView* aPage in pagesThatWillBeVisibleAfterTransitionToListView){
                CGRect oldFrame = hiddenStackHolder.bounds;
                if([visibleStackHolder containsSubview:aPage]){
                    oldFrame = [[setOfInitialFramesForPagesBeingZoomed objectForKey:aPage.uuid] CGRectValue];
                }
                CGRect rect = [self zoomToListFrameForPage:aPage oldToFrame:oldFrame withTrust:percentageToTrustToFrame];
                aPage.frame = rect;
            }
            
            //
            // start to move the hidden frame to overlap the visible frame
            CGFloat percentageToMoveHiddenFrame = percentageToTrustToFrame;
            percentageToMoveHiddenFrame += .1;
            if(percentageToMoveHiddenFrame > 1) percentageToMoveHiddenFrame = 1;
            CGRect hiddenFrame = hiddenStackHolder.frame;
            hiddenFrame.origin.x = visibleStackHolder.frame.origin.x + percentageToMoveHiddenFrame * visibleStackHolder.frame.size.width;
            hiddenStackHolder.frame = hiddenFrame;
            
            //
            // the user has zoomed out far enough for us to take over
            // with animations. cancel the gesture.
            //
            // the cancelled state will be caught in SLPaperStackView, so
            // the frame is not adjusted after we animate the page to
            // it's resting place
            if([visibleStackHolder peekSubview].scale < kZoomToListPageZoom){
                [[visibleStackHolder peekSubview] cancelAllGestures];
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
        [self setListViewHalfEnabled:YES];
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
                    // immediately
                    rect.origin.y = -rect.size.height;
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
                rect.origin.y = -rect.size.height;
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
                // up above the visible page
                CGRect newFrame = aPage.frame;
                newFrame.origin.y = -newFrame.size.height;
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
        [self setContentSize:CGSizeMake(screenWidth, contentHeightFromTransitionToListView)];
        [self setListViewEntirelyEnabled:YES];
        [setOfFinalFramesForPagesBeingZoomed removeAllObjects];
    };
    
    
    
    step1();
    // ok, animate all the views in the visible stack!
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:step2
                     completion:step3];
    //
    // now that the user has finished the gesture,
    // we can forget about the original frame locations
    [setOfInitialFramesForPagesBeingZoomed removeAllObjects];
}

/**
 * the user has cancelled the zoom-to-list gesture
 */
-(void) cancelledScalingReallySmall:(SLPaperView *)page{
    [self setListViewHalfEnabled:NO];
    if(![page isBeingPannedAndZoomed]){
        [self animatePageToFullScreen:[visibleStackHolder peekSubview] withDelay:0 withBounce:YES onComplete:^(BOOL finished){
            [self realignPagesInVisibleStackExcept:[visibleStackHolder peekSubview] animated:NO];
        }];
        [UIView animateWithDuration:0.1 delay:0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveLinear) animations:^{
            CGRect fr = visibleStackHolder.frame;
            fr.origin.x = fr.size.width;
            hiddenStackHolder.frame = fr;
        } completion:nil];
    }
    [setOfFinalFramesForPagesBeingZoomed removeAllObjects];
}

/**
 * this delegate method tells the SLPageView where
 * it sits in the combined visible/hidden stack
 */
-(NSInteger) indexOfPageInCompleteStack:(SLPaperView*)page{
    if([visibleStackHolder containsSubview:page]){
        return [visibleStackHolder.subviews indexOfObject:page];
    }else{
        return [visibleStackHolder.subviews count] + [hiddenStackHolder.subviews indexOfObject:page];
    }
}




#pragma mark - SLPaperViewDelegate - Tap Gesture

-(void) didTapScrollView:(UITapGestureRecognizer*)_tapGesture{
    CGPoint locationOfTap = [_tapGesture locationInView:self];
    CGPoint offset = self.contentOffset;
    SLPaperView* thePageThatWasTapped = nil;
    for(SLPaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]){
        CGRect frameOfPage = [aPage frameForListViewGivenRowHeight:rowHeight andColumnWidth:columnWidth];
        if(CGRectContainsPoint(frameOfPage, locationOfTap)){
            thePageThatWasTapped = aPage;
        }
    }
    if(!thePageThatWasTapped) return;
    
    // they tapped a page, and we know which one
    for(SLPaperView* aPage in [visibleStackHolder.subviews arrayByAddingObjectsFromArray:hiddenStackHolder.subviews]){
        CGRect frameOfPage = [aPage frameForListViewGivenRowHeight:rowHeight andColumnWidth:columnWidth];
        frameOfPage.origin.y -= offset.y;
        aPage.frame = frameOfPage;
    }
    self.contentOffset = CGPointZero;
    //
    // TODO
    //
    // before we animate, we need to move pages to/from
    // the hidden stack
    //
    // also, the hidden pages need to be "under" the visible
    // page that's about to get animated
    [self animatePageToFullScreen:thePageThatWasTapped withDelay:0 withBounce:YES onComplete:^(BOOL finished){
        // TODO
        // turn back on gestures etc
        // and formally go back to page view
        //
        // also, make sure the hiddenStackHolder's frame is where it should be
        // and that all the frames of all the pages are correct
        debug_NSLog(@"clean up");
    }];
}

@end
