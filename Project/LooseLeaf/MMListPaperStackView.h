//
//  MMListPaperStackView.h
//  Loose Leaf
//
//  Created by Adam Wulf on 7/3/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperStackView.h"
#import "MMPanAndPinchFromListViewGestureRecognizer.h"
#import <QuartzCore/QuartzCore.h>
#import "MMListAddPageButton.h"
#import "MMListAddPageButtonDelegate.h"

@interface MMListPaperStackView : MMPaperStackView<MMPanAndPinchFromListViewGestureRecognizerDelegate,MMListAddPageButtonDelegate>{
    //
    // when beginning a zoom, we need to save the
    // frames of all the pages we'll be animating
    //
    // then we'll use that saved frame value to
    // animate between it's final state
    NSMutableDictionary* setOfInitialFramesForPagesBeingZoomed;
    NSMutableDictionary* setOfFinalFramesForPagesBeingZoomed;

    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat columnWidth;
    CGFloat rowHeight;
    CGFloat bufferWidth;
    
    UITapGestureRecognizer* tapGesture;
    MMPanAndPinchFromListViewGestureRecognizer* pinchGesture;
    
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

@end
