//
//  MMLongPressGestureRecognizer.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/8/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "MMPanAndPinchFromListViewGestureRecognizerDelegate.h"

@interface MMLongPressFromListViewGestureRecognizer : UILongPressGestureRecognizer<UIGestureRecognizerDelegate>{
    CGPoint normalizedLocationOfScale;
    // delegate to help us track down which page is being touched
    NSObject<MMPanAndPinchFromListViewGestureRecognizerDelegate>* pinchDelegate;
    // the current page that the user is pinching
    MMPaperView* pinchedPage;
}

@property (nonatomic, readonly) CGPoint normalizedLocationOfScale;
@property (nonatomic, assign) NSObject<MMPanAndPinchFromListViewGestureRecognizerDelegate>* pinchDelegate;
@property (nonatomic, readonly) MMPaperView* pinchedPage;

-(void) cancel;

@end
