//
//  SLPaperStackView.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import <UIKit/UIKit.h>
#import "SLPaperView.h"
#import "NSMutableArray+StackAdditions.h"
#import "SLPaperIcon.h"
#import "SLPlusIcon.h"
#import "SLLeftArrow.h"
#import "SLRightArrow.h"
#import "SLBezelInGestureRecognizer.h"
#import "SLBezelOutGestureRecognizer.h"

@interface SLPaperStackView : UIView<SLPaperViewDelegate>{
    NSMutableArray* visibleStack;
    NSMutableArray* hiddenStack;
    CGRect frameOfHiddenStack;
    
    UIView* stackHolder;
    SLPaperIcon* paperIcon;
    SLPlusIcon* plusIcon;
    SLLeftArrow* leftArrow;
    SLRightArrow* rightArrow;
    
    SLBezelInGestureRecognizer* fromRightBezelGesture;
    SLBezelOutGestureRecognizer* toRightBezelGesture;
}

-(void) addPaperToBottomOfStack:(SLPaperView*)page;

@end
