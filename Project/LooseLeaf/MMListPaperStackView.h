//
//  MMListPaperStackView.h
//  Loose Leaf
//
//  Created by Adam Wulf on 7/3/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperStackView.h"
#import <QuartzCore/QuartzCore.h>
#import "MMStretchPageGestureRecognizer.h"
#import "MMLongPressFromListViewGestureRecognizer.h"
#import "MMListAddPageButton.h"
#import "MMListAddPageButtonDelegate.h"
#import "MMButtonAwareTapGestureRecognizer.h"
#import "MMPageCacheManagerDelegate.h"
#import "MMDeletePageSidebarController.h"
#import "MMInboxManagerDelegate.h"
#import "MMButtonToolbarView.h"

@interface MMListPaperStackView : MMPaperStackView<MMStretchPageGestureRecognizerDelegate,MMListAddPageButtonDelegate,MMPageCacheManagerDelegate,UIScrollViewDelegate>{
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
    
    MMStretchPageGestureRecognizer* pinchGesture;
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

@property (nonatomic, strong) MMDeletePageSidebarController* deleteSidebar;
@property (nonatomic, readonly) MMButtonToolbarView* toolbar;
@property (nonatomic, readonly) BOOL isAnimatingTowardPageView;

-(CGPoint) offsetNeededToShowPage:(MMPaperView*)page;
-(NSArray*) findPagesInVisibleRowsOfListViewGivenOffset:(CGPoint)eventualOffsetOfListView;

// returns yes if the imported page was handled
-(BOOL) importAndShowPage:(MMExportablePaperView*)page;


// protected

-(void) immediatelyTransitionToListView;

-(void) beginUITransitionFromPageView;

-(void) beginUITransitionFromListView;

-(void) finishUITransitionToListView;

-(void) finishUITransitionToPageView;

-(void) deletePage:(MMPaperView*)page;

-(void) transitionFromListToNewBlankPageIfInPageView;

-(CGFloat) contentHeightForAllPages;

-(void) moveAddButtonToBottom;

-(void) moveAddButtonToTop;

-(void) subclassBeforeTransitionToListView;

-(void) subclassDuringTransitionToListView;

-(void) tutorialShouldOpen:(NSNotification*)note;

-(void) tutorialShouldClose:(NSNotification*)note;

@end
