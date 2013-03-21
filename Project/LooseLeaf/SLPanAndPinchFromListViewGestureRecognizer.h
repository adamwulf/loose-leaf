//
//  SLPanFromListViewGestureRecognizer.h
//  Loose Leaf
//
//  Created by Adam Wulf on 8/31/12.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "Constants.h"
#import "SLPanAndPinchFromListViewGestureRecognizerDelegate.h"
#import "NSMutableSet+Extras.h"

@interface SLPanAndPinchFromListViewGestureRecognizer : UIGestureRecognizer{
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
    NSObject<SLPanAndPinchFromListViewGestureRecognizerDelegate>* pinchDelegate;
    //
    // the current page that the user is pinching
    SLPaperView* pinchedPage;
    // track the direction of the scale
    SLBezelScaleDirection scaleDirection;
}

@property (nonatomic, readonly) SLPaperView* pinchedPage;
@property (nonatomic, readonly) CGPoint normalizedLocationOfScale;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGFloat initialPageScale;
@property (nonatomic, readonly) SLBezelScaleDirection scaleDirection;
@property (nonatomic, assign) NSObject<SLPanAndPinchFromListViewGestureRecognizerDelegate>* pinchDelegate;

-(void) cancel;

@end
