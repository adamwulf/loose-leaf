//
//  SLPaperView.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLPaperView : UIView{
    
    // properties for pinch gesture
    CGFloat preGestureScale;
    CGFloat scale;
    CGPoint normalizedLocationOfScale;
    NSInteger lastNumberOfTouchesForPinchGesture;
    
    // properties for pan gesture
    CGPoint firstLocationOfPanGesture;
    CGRect firstFrameOfViewForGesture;
    NSInteger lastNumberOfTouchesForPanGesture;
    CGPoint panDiffLocation;
}

@property (nonatomic, assign) CGFloat scale;



@end
