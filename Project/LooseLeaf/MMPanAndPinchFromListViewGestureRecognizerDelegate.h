//
//  MMPanAndPinchFromListViewGestureRecognizerDelegate.h
//  Loose Leaf
//
//  Created by Adam Wulf on 8/31/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMPaperView.h"


@protocol MMPanAndPinchFromListViewGestureRecognizerDelegate <NSObject>

-(MMPaperView*) pageForPointInList:(CGPoint) point;

-(CGSize) sizeOfFullscreenPage;


@end
