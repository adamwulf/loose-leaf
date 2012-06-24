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
#import "SLPapersIcon.h"
#import "SLPlusIcon.h"
#import "SLLeftArrow.h"
#import "SLRightArrow.h"
#import "SLBezelInRightGestureRecognizer.h"

#import "SLPopoverView.h"

@interface SLPaperStackView : UIView<SLPaperViewDelegate>{
    UIView* visibleStackHolder;
    UIView* hiddenStackHolder;
    SLPapersIcon* papersIcon;
    SLPaperIcon* paperIcon;
    SLPlusIcon* plusIcon;
    SLLeftArrow* leftArrow;
    SLRightArrow* rightArrow;
    
    SLBezelInRightGestureRecognizer* fromRightBezelGesture;
    NSMutableSet* setOfPagesBeingPanned;
    
    SLPaperView* inProgressOfBezeling;
}

@property (nonatomic, readonly) UIView* stackHolder;


-(void) addPaperToBottomOfStack:(SLPaperView*)page;
-(void) popTopPageOfHiddenStack;

@end
