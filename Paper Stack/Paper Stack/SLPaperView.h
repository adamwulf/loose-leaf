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
#import "SLBezelOutPanPinchGestureRecognizer.h"

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
    
    UILabel* textLabel;
    
    SLBezelOutPanPinchGestureRecognizer* panGesture;
    
    BOOL isBrandNewPage;
    
    UITextField* textField;
}

@property (nonatomic, assign) NSObject<SLPaperViewDelegate>* delegate;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, readonly) BOOL isBeingPannedAndZoomed;
// this will only be true if the bezel gesture is triggered and the page is actively being panned
@property (nonatomic, readonly) BOOL willExitBezel;
@property (nonatomic, readonly) UILabel* textLabel;
@property (nonatomic, assign) BOOL isBrandNewPage;

-(void) cancelAllGestures;
-(void) disableAllGestures;
-(void) enableAllGestures;

@end
