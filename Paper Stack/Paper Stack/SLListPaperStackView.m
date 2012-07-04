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

#pragma mark - Future Model Methods

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
        SLPaperView* topVisiblePage = aPage;
        NSMutableArray* pagesThatWouldBeVisible = [NSMutableArray arrayWithObject:aPage];
        while((aPage = [visibleStackHolder getPageBelow:aPage]) && (topVisiblePage.rowInListView - 2 < aPage.rowInListView)){
            [pagesThatWouldBeVisible insertObject:aPage atIndex:0];
        }
        
        aPage = [hiddenStackHolder.subviews objectAtIndex:0];
        [pagesThatWouldBeVisible addObject:aPage];
        while((aPage = [hiddenStackHolder getPageAbove:aPage]) && (topVisiblePage.rowInListView + 3 > aPage.rowInListView)){
            [pagesThatWouldBeVisible insertObject:aPage atIndex:0];
        }

        return pagesThatWouldBeVisible;
    }
    
    //
    // TODO: handle case where scrolling is enabled
    return nil;
}





#pragma mark - SLPaperViewDelegate - Tap Gesture

-(void) didTapScrollView:(UITapGestureRecognizer*)_tapGesture{
    debug_NSLog(@"tapped at %f %f", [tapGesture locationInView:self].x, [tapGesture locationInView:self].y);
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
    
    //
    // calculate the number of rows that will be hidden due to content offset
    SLPaperView* topPage = [visibleStackHolder peekSubview];
    NSInteger numberOfHiddenRows = MAX(0, topPage.rowInListView - 1);

    // final frame when the page is in the list view
    CGRect finalFrame = [page frameForListViewGivenRowHeight:rowHeight andColumnWidth:columnWidth];
    CGPoint offset = CGPointMake(0, numberOfHiddenRows * (rowHeight + bufferWidth));
    finalFrame.origin.x -= offset.x;
    finalFrame.origin.y -= offset.y;
    
    //
    // ok, set the new frame that we'll return
    CGRect newFrame = CGRectZero;
    newFrame.origin.x = finalFrame.origin.x - (finalFrame.origin.x - oldFrame.origin.x) * percentageToTrustToFrame;
    newFrame.origin.y = finalFrame.origin.y - (finalFrame.origin.y - oldFrame.origin.y) * percentageToTrustToFrame;
    newFrame.size.width = finalFrame.size.width - (finalFrame.size.width - oldFrame.size.width) * percentageToTrustToFrame;
    newFrame.size.height = finalFrame.size.height - (finalFrame.size.height - oldFrame.size.height) * percentageToTrustToFrame;
    
    debug_NSLog(@"row:%d column: %d    x:%f y: %f", page.rowInListView, page.columnInListView, newFrame.origin.x, newFrame.origin.y);
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
        [self ensureAtLeast:1 pagesInStack:hiddenStackHolder];
        pagesThatWillBeVisibleAfterTransitionToListView = [[self pagesInVisibleRowsOfListView] retain];
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
    // turn off the pan/scale gesture,
    // we'll animate from here on out
    [page disableAllGestures];

    //
    // first, find all pages behind the first full scale
    // page, and just move them immediately
    //
    // this helps pretty dramatically with the animation
    // performance.
    //
    // also, turn off gestures
    SLPaperView* lastPage = nil;
    for(SLPaperView* aPage in [visibleStackHolder.subviews reverseObjectEnumerator]){
        if([pagesThatWillBeVisibleAfterTransitionToListView containsObject:aPage]){
            // noop for now, we'll animate these
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
            }
        }
        // gestures aren't allowed in list view
        [aPage disableAllGestures];
    }
    for(SLPaperView* aPage in [hiddenStackHolder.subviews reverseObjectEnumerator]){
        if([pagesThatWillBeVisibleAfterTransitionToListView containsObject:aPage]){
            // noop for now, we'll animate these
        }else{
            CGRect rect = aPage.frame;
            rect.origin.y = -rect.size.height;
            aPage.frame = rect;
        }
    }
    
    // ok, animate all the views in the visible stack!
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
        //
        // make sure all the pages go to the correct place
        // so that it looks like where they'll be in the list view
        for(SLPaperView* aPage in [visibleStackHolder.subviews reverseObjectEnumerator]){
            if([pagesThatWillBeVisibleAfterTransitionToListView containsObject:aPage]){
                // these views we're animating into place
                aPage.frame = [self zoomToListFrameForPage:aPage oldToFrame:aPage.frame withTrust:0.0];
            }else{
                if(aPage == lastPage){
                    // animate the last page to cover the screen
                    // up above the visible page
                    CGRect newFrame = aPage.frame;
                    newFrame.origin.y = -newFrame.size.height;
                    aPage.frame = newFrame;
                }else{
                    // the rest of these pages have alrady been moved
                    // and shouldn't be animated
                    break;
                }
            }
        }
        for(SLPaperView* aPage in [hiddenStackHolder.subviews reverseObjectEnumerator]){
            if([pagesThatWillBeVisibleAfterTransitionToListView containsObject:aPage]){
                aPage.frame = [self zoomToListFrameForPage:aPage oldToFrame:aPage.frame withTrust:0.0];
            }else{
                // already moved manually above
                break;
            }
        }
        hiddenStackHolder.frame = visibleStackHolder.frame;
    } completion:^(BOOL finished){
        //
        // all of the pages "look" like they're in the right place,
        // but we need to turn on the scroll view.
        //
        // this means we need to keep the pages visually in the same place,
        // but adjust their frames and the content size/offset so
        // that the scrollview works.
        [self setScrollEnabled:YES];
        for(SLPaperView* aPage in visibleStackHolder.subviews){
            aPage.frame = [aPage frameForListViewGivenRowHeight:rowHeight andColumnWidth:columnWidth];
        }
        for(SLPaperView* aPage in hiddenStackHolder.subviews){
            aPage.frame = [aPage frameForListViewGivenRowHeight:rowHeight andColumnWidth:columnWidth];
        }
        
        //
        // calculate the number of rows that will be hidden from offset
        SLPaperView* topPage = [visibleStackHolder peekSubview];
        SLPaperView* topHiddenPage = [hiddenStackHolder peekSubview];
        NSInteger numberOfHiddenRows = MAX(0, topPage.rowInListView - 1);
        NSInteger totalRows = topHiddenPage.rowInListView;
        CGFloat contentHeight = (totalRows + 3) * (bufferWidth + rowHeight) + bufferWidth;
        
        [self setContentOffset:CGPointMake(0, numberOfHiddenRows * (bufferWidth + rowHeight)) animated:NO];
        [self setContentSize:CGSizeMake(screenWidth, contentHeight)];
        [visibleStackHolder setClipsToBounds:NO];
        [hiddenStackHolder setClipsToBounds:NO];
        [tapGesture setEnabled:YES];
        
        [pagesThatWillBeVisibleAfterTransitionToListView release];
        pagesThatWillBeVisibleAfterTransitionToListView = nil;
    }];
    //
    // now that the user has finished the gesture,
    // we can forget about the original frame locations
    [setOfInitialFramesForPagesBeingZoomed removeAllObjects];
}

-(void) cancelledScalingReallySmall:(SLPaperView *)page{
    debug_NSLog(@"cancelled small scale");
    [setOfInitialFramesForPagesBeingZoomed removeAllObjects];
    [tapGesture setEnabled:NO];
    [pagesThatWillBeVisibleAfterTransitionToListView release];
    pagesThatWillBeVisibleAfterTransitionToListView = nil;
}

-(NSInteger) indexOfPageInCompleteStack:(SLPaperView*)page{
    if([visibleStackHolder containsSubview:page]){
        return [visibleStackHolder.subviews indexOfObject:page];
    }else{
        return [visibleStackHolder.subviews count] + [hiddenStackHolder.subviews indexOfObject:page];
    }
}



@end
