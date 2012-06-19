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
#import "SLBezelGestureRecognizer.h"

@interface SLPaperStackView : UIView<SLPaperViewDelegate>{
    NSMutableArray* visibleStack;
    NSMutableArray* hiddenStack;
    CGRect boundsOfHiddenStack;
    
    UIView* stackHolder;
    SLPaperIcon* paperIcon;
    SLPlusIcon* plusIcon;
    SLLeftArrow* leftArrow;
    SLRightArrow* rightArrow;
    
}

-(void) addPaperToBottomOfStack:(SLPaperView*)page;

@end
