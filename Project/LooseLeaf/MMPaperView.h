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
#import "MMImmovableTapGestureRecognizer.h"
#import "MMObjectSelectLongPressGestureRecognizer.h"
#import "MMShadowedView.h"
#import "MMUUIDView.h"


@interface MMPaperView : MMShadowedView <MMUUIDView> {
    NSObject<MMPaperViewDelegate>* __weak delegate;

    BOOL isBeingPannedAndZoomed;

    UILabel* textLabel;

    MMObjectSelectLongPressGestureRecognizer* longPress;
    //    MMImmovableTapGestureRecognizer* tap;
    MMPanAndPinchGestureRecognizer* panGesture;

    BOOL isBrandNewPage;

    UIBezierPath* unitShadowPath;
}

@property (nonatomic, readonly) UIBezierPath* unitShadowPath;
@property (nonatomic, weak) NSObject<MMPaperViewDelegate>* delegate;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, readonly) BOOL isBeingPannedAndZoomed;
// this will only be true if the bezel gesture is triggered and the page is actively being panned
@property (nonatomic, readonly) NSInteger numberOfTimesExitedBezel;
@property (nonatomic, readonly) UILabel* textLabel;
@property (nonatomic, assign) BOOL isBrandNewPage;
@property (nonatomic, readonly) MMPanAndPinchGestureRecognizer* panGesture;
@property (nonatomic, readonly) int fullByteSize;

// read only props
@property (nonatomic, readonly) CGRect originalUnscaledBounds;

// List View
@property (nonatomic, readonly) NSInteger rowInListView;
@property (nonatomic, readonly) NSInteger columnInListView;

- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid;

- (BOOL)willExitToBezel:(MMBezelDirection)bezelDirection;
- (void)cancelAllGestures;
- (void)disableAllGestures;
- (void)enableAllGestures;

- (void)panAndScale:(MMPanAndPinchGestureRecognizer*)_panGesture;

- (NSDictionary*)dictionaryDescription;

- (BOOL)areGesturesEnabled;

- (void)moveAssetsFrom:(id<MMPaperViewDelegate>)previousDelegate NS_REQUIRES_SUPER;

@end
