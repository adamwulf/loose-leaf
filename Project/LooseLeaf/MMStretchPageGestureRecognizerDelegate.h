//
//  MMStretchPageGestureRecognizerDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/16/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMPanAndPinchFromListViewGestureRecognizerDelegate.h"

@class MMStretchPageGestureRecognizer;

@protocol MMStretchPageGestureRecognizerDelegate <MMPanAndPinchFromListViewGestureRecognizerDelegate>

-(void) didStretchToDuplicatePageWithGesture:(MMStretchPageGestureRecognizer*)gesture;

@end
