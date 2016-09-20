//
//  MMStretchPageGestureRecognizer.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/16/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMPanAndPinchFromListViewGestureRecognizer.h"
#import "MMStretchPageGestureRecognizerDelegate.h"


@interface MMStretchPageGestureRecognizer : MMPanAndPinchFromListViewGestureRecognizer

@property (nonatomic, assign) NSObject<MMStretchPageGestureRecognizerDelegate>* pinchDelegate;
@property (nonatomic, readonly) NSArray* additionalTouches;


@end
