//
//  MMPaperView.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "MMPaperViewDelegate.h"
#import "MMPanAndPinchGestureRecognizer.h"
#import "MMShadowedView.h"

@interface MMPaperView : MMShadowedView{
    
    NSString* uuid;
    
    NSObject<MMPaperViewDelegate>* __weak delegate;
    
    // properties for pinch gesture
    CGFloat preGestureScale;
    CGPoint normalizedLocationOfScale;
    
    // properties for pan gesture
    CGPoint firstLocationOfPanGestureInSuperView;
    CGRect frameOfPageAtBeginningOfGesture;
    NSInteger lastNumberOfTouchesForPanGesture;

    BOOL isBeingPannedAndZoomed;
    
    UILabel* textLabel;
    
    MMPanAndPinchGestureRecognizer* panGesture;
    
    BOOL isBrandNewPage;
    
    UIBezierPath* unitShadowPath;
}

@property (nonatomic, readonly) NSString* uuid;
@property (nonatomic, readonly) UIBezierPath* unitShadowPath;
@property (nonatomic, weak) NSObject<MMPaperViewDelegate>* delegate;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, readonly) BOOL isBeingPannedAndZoomed;
// this will only be true if the bezel gesture is triggered and the page is actively being panned
@property (nonatomic, readonly) NSInteger numberOfTimesExitedBezel;
@property (nonatomic, readonly) UILabel* textLabel;
@property (nonatomic, assign) BOOL isBrandNewPage;

// List View
@property (nonatomic, readonly) NSInteger rowInListView;
@property (nonatomic, readonly) NSInteger columnInListView;


-(BOOL) willExitToBezel:(MMBezelDirection)bezelDirection;
-(void) cancelAllGestures;
-(void) disableAllGestures;
-(void) enableAllGestures;

-(void) panAndScale:(MMPanAndPinchGestureRecognizer*)_panGesture;

@end
