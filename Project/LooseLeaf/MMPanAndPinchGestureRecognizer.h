//
//  MMPanAndPinchGestureRecognizer.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "MMCancelableGestureRecognizer.h"
#import "Constants.h"
#import "MMScrapView.h"
#import "MMPanAndPinchScrapGestureRecognizerDelegate.h"
#import "MMTouchLifeCycleDelegate.h"


@interface MMPanAndPinchGestureRecognizer : MMCancelableGestureRecognizer <MMTouchLifeCycleDelegate> {
    //
    // the initial distance between
    // the touches. to be used to calculate
    // scale
    CGFloat initialDistance;
    //
    // the current scale of the gesture
    CGFloat scale;
    //
    // the collection of valid touches for this gesture
    NSMutableSet* ignoredTouches;
    NSMutableOrderedSet* possibleTouches;
    NSMutableOrderedSet* validTouches;

    // track which bezels our delegate cares about
    MMBezelDirection bezelDirectionMask;
    // the direction that the user actually did exit, if any
    MMBezelDirection didExitToBezel;
    // track the direction of the scale
    MMBezelScaleDirection scaleDirection;

    __weak NSObject<MMPanAndPinchScrapGestureRecognizerDelegate>* scrapDelegate;
}

@property (nonatomic, weak) NSObject<MMPanAndPinchScrapGestureRecognizerDelegate>* scrapDelegate;
@property (readonly) NSArray* validTouches;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, assign) MMBezelDirection bezelDirectionMask;
@property (nonatomic, readonly) MMBezelDirection didExitToBezel;
@property (nonatomic, readonly) MMBezelScaleDirection scaleDirection;
@property (nonatomic, readonly) UIGestureRecognizerState subState;

@property (nonatomic, readonly) CGFloat preGestureScale;
@property (nonatomic, readonly) CGPoint normalizedLocationOfScale;
@property (nonatomic, readonly) CGPoint firstLocationOfPanGestureInSuperView;
@property (nonatomic, readonly) CGRect frameOfPageAtBeginningOfGesture;
@property (nonatomic, readonly) BOOL hasPannedOrScaled;

- (BOOL)containsTouch:(UITouch*)touch;
- (void)ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture;

@end
