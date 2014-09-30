//
//  MMListPaperStackView.h
//  Loose Leaf
//
//  Created by Adam Wulf on 7/3/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperStackView.h"
#import <QuartzCore/QuartzCore.h>
#import "MMPanAndPinchFromListViewGestureRecognizer.h"
#import "MMLongPressFromListViewGestureRecognizer.h"
#import "MMListAddPageButton.h"
#import "MMListAddPageButtonDelegate.h"
#import "MMButtonAwareTapGestureRecognizer.h"
#import "MMPageCacheManagerDelegate.h"

@interface MMListPaperStackView : MMPaperStackView<MMPanAndPinchFromListViewGestureRecognizerDelegate,MMListAddPageButtonDelegate,MMPageCacheManagerDelegate>{
    //
    // when beginning a zoom, we need to save the
    // frames of all the pages we'll be animating
    //
    // then we'll use that saved frame value to
    // animate between it's final state
    NSMutableDictionary* setOfInitialFramesForPagesBeingZoomed;

    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat columnWidth;
    CGFloat rowHeight;
    CGFloat bufferWidth;
    
    MMPanAndPinchFromListViewGestureRecognizer* pinchGesture;
    MMLongPressFromListViewGestureRecognizer* longPressGesture;
    
    CGPoint initialScrollOffsetFromTransitionToListView;
    NSArray* pagesThatWillBeVisibleAfterTransitionToListView;
    
    // the point in the view's coordinates (not scroll offset)
    // of the drag gesture in list view
    CGPoint lastDragPoint;
    MMPaperView* pageBeingDragged;
    CADisplayLink* displayLink;
    BOOL realizedThatPageIsBeingDragged;
    
    MMListAddPageButton* addPageButtonInListView;
}

-(void) ensurePage:(MMPaperView*)thePage isAtIndex:(NSInteger)newIndex;

-(CGPoint) offsetNeededToShowPage:(MMPaperView*)page;
-(NSArray*) findPagesInVisibleRowsOfListViewGivenOffset:(CGPoint)eventualOffsetOfListView;


// protected

-(void) beginUITransitionFromPageView;

-(void) beginUITransitionFromListView;

-(void) finishUITransitionToListView;

-(void) finishUITransitionToPageView;

@end
