//
//  SLPanAndPinchFromListViewGestureRecognizerDelegate.h
//  Loose Leaf
//
//  Created by Adam Wulf on 8/31/12.
//
//

#import <Foundation/Foundation.h>
#import "SLPaperView.h"


@protocol SLPanAndPinchFromListViewGestureRecognizerDelegate <NSObject>

-(SLPaperView*) pageForPointInList:(CGPoint) point;

-(CGSize) sizeOfFullscreenPage;


@end
