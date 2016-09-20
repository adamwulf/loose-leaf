//
//  MMPanFromListViewGestureRecognizer.h
//  Loose Leaf
//
//  Created by Adam Wulf on 8/31/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "Constants.h"
#import "MMPanAndPinchFromListViewGestureRecognizerDelegate.h"
#import "NSMutableSet+Extras.h"
#import "MMCancelableGestureRecognizer.h"


@interface MMPanAndPinchFromListViewGestureRecognizer : MMCancelableGestureRecognizer <UIGestureRecognizerDelegate> {
    //
    // the initial distance between
    // the touches. to be used to calculate
    // scale
    CGFloat initialDistance;
    CGFloat initialPageScale;
    CGPoint normalizedLocationOfScale;
    //
    // the current scale of the gesture
    CGFloat scale;
    //
    // the collection of valid touches for this gesture
    NSMutableOrderedSet* validTouches;
    //
    // delegate to help us track down which page is being touched
    NSObject<MMPanAndPinchFromListViewGestureRecognizerDelegate>* pinchDelegate;
    //
    // the current page that the user is pinching
    MMPaperView* pinchedPage;
    // track the direction of the scale
    MMBezelScaleDirection scaleDirection;
}

@property (nonatomic, readonly) NSArray* validTouches;
@property (nonatomic, readonly) MMPaperView* pinchedPage;
@property (nonatomic, readonly) CGPoint normalizedLocationOfScale;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGFloat initialPageScale;
@property (nonatomic, readonly) MMBezelScaleDirection scaleDirection;
@property (nonatomic, assign) NSObject<MMPanAndPinchFromListViewGestureRecognizerDelegate>* pinchDelegate;

- (void)killTheGestureCold;

@end
