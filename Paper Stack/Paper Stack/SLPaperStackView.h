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
#import "UIView+SubviewStacks.h"
#import "UIView+Debug.h"
#import "UIView+Animations.h"
#import "NSMutableSet+Extras.h"
#import "Constants.h"
#import "SLPopoverView.h"

@interface SLPaperStackView : UIScrollView<SLPaperViewDelegate>{
    @private
    SLPapersIcon* papersIcon;
    SLPaperIcon* paperIcon;
    SLPlusIcon* plusIcon;
    SLLeftArrow* leftArrow;
    SLRightArrow* rightArrow;
    
    // track if we're currently pulling in a page
    // from the bezel
    SLPaperView* inProgressOfBezeling;
    
    @protected
    SLBezelInRightGestureRecognizer* fromRightBezelGesture;
    
    UIView* visibleStackHolder;
    UIView* hiddenStackHolder;
    UIView* bezelStackHolder;

    NSMutableSet* setOfPagesBeingPanned;
}

@property (nonatomic, readonly) UIView* stackHolder;

-(void) addPaperToBottomOfStack:(SLPaperView*)page;
-(void) emptyBezelStackToHiddenStackAnimated:(BOOL)animated onComplete:(void(^)(BOOL finished))completionBlock;
-(void) popTopPageOfHiddenStack;
-(void) ensureAtLeast:(NSInteger)numberOfPagesToEnsure pagesInStack:(UIView*)stackView;
-(void) realignPagesInVisibleStackExcept:(SLPaperView*)page animated:(BOOL)animated;
-(void) animatePageToFullScreen:(SLPaperView*)page withDelay:(CGFloat)delay withBounce:(BOOL)bounce onComplete:(void(^)(BOOL finished))completionBlock;

@end
