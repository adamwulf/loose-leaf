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
#import "SLBezelInGestureRecognizer.h"

@interface SLPaperStackView : UIView<SLPaperViewDelegate>{
    UIView* visibleStackHolder;
    UIView* hiddenStackHolder;
    SLPapersIcon* papersIcon;
    SLPaperIcon* paperIcon;
    SLPlusIcon* plusIcon;
    SLLeftArrow* leftArrow;
    SLRightArrow* rightArrow;
    
    SLBezelInGestureRecognizer* fromRightBezelGesture;
    NSMutableSet* setOfPagesBeingPanned;
    
    SLPaperView* inProgressOfBezeling;
}

-(void) addPaperToBottomOfStack:(SLPaperView*)page;

@end
