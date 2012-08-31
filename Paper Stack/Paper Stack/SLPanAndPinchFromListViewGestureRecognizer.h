//
//  SLPanFromListViewGestureRecognizer.h
//  scratchpaper
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
    //
    // the current scale of the gesture
    CGFloat scale;
    //
    // the collection of valid touches for this gesture
    NSMutableSet* validTouches;
    //
    // delegate to help us track down which page is being touched
    NSObject<SLPanAndPinchFromListViewGestureRecognizerDelegate>* pinchDelegate;
    //
    // the current page that the user is pinching
    SLPaperView* pinchedPage;
}

@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, assign) NSObject<SLPanAndPinchFromListViewGestureRecognizerDelegate>* pinchDelegate;

-(void) cancel;

@end
