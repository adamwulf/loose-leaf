//
//  SLPaperView.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface SLPaperView : UIView{
    
    // properties for pinch gesture
    CGFloat preGestureScale;
    CGPoint normalizedLocationOfScale;
    
    // properties for pan gesture
    CGPoint firstLocationOfPanGesture;
    CGRect firstFrameOfViewForGesture;
    NSInteger lastNumberOfTouchesForPanGesture;
    CGPoint panDiffLocation;
}

@property (nonatomic, assign) CGFloat scale;



@end
