//
//  SLListPaperStackView.h
//  Loose Leaf
//
//  Created by Adam Wulf on 7/3/12.
//
//

#import "SLPaperStackView.h"
#import "SLPanAndPinchFromListViewGestureRecognizer.h"
#import <QuartzCore/QuartzCore.h>
#import "MSListAddPageButton.h"
#import "MSListAddPageButtonDelegate.h"

@interface SLListPaperStackView : SLPaperStackView<SLPanAndPinchFromListViewGestureRecognizerDelegate,MSListAddPageButtonDelegate>{
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
    SLPanAndPinchFromListViewGestureRecognizer* pinchGesture;
    
    CGPoint initialScrollOffsetFromTransitionToListView;
    NSArray* pagesThatWillBeVisibleAfterTransitionToListView;
    
    // the point in the view's coordinates (not scroll offset)
    // of the drag gesture in list view
    CGPoint lastDragPoint;
    SLPaperView* pageBeingDragged;
    CADisplayLink* displayLink;
    BOOL realizedThatPageIsBeingDragged;
    
    MSListAddPageButton* addPageButtonInListView;
}

@end
