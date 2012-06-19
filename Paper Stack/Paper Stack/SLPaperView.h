//
//  SLPaperView.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "SLPaperViewDelegate.h"

@interface SLPaperView : UIView{
    
    NSObject<SLPaperViewDelegate>* delegate;
    
    // properties for pinch gesture
    CGFloat preGestureScale;
    CGPoint normalizedLocationOfScale;
    
    // properties for pan gesture
    CGPoint firstLocationOfPanGestureInSuperView;
    CGRect frameOfPageAtBeginningOfGesture;
    NSInteger lastNumberOfTouchesForPanGesture;

    BOOL isBeingPannedAndZoomed;
}

@property (nonatomic, assign) NSObject<SLPaperViewDelegate>* delegate;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, readonly) BOOL isBeingPannedAndZoomed;

-(void) setShadowIsVisible:(BOOL)visible;

@end
