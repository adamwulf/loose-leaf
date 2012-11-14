//
//  SLPaperStackView.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Skylight, LLC. All rights reserved.
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
#import "UIView+Debug.h"
#import "UIView+Animations.h"
#import "NSMutableSet+Extras.h"
#import "SLPopoverView.h"
#import "SLModeledStackView.h"
#import "Constants.h"

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
    
    SLModeledStackView* visibleStackHolder;
    SLModeledStackView* hiddenStackHolder;
    SLModeledStackView* bezelStackHolder;

    NSMutableSet* setOfPagesBeingPanned;
    
    SLPaperView* previouslyVisiblePage;
}

@property (nonatomic, readonly) UIView* stackHolder;

@property (nonatomic, readonly) NSArray* visibleViews;
@property (nonatomic, readonly) NSArray* inflightViews;
@property (nonatomic, readonly) NSArray* hiddenViews;


-(void) addPaperToBottomOfStack:(SLPaperView*)page;
-(void) addPaperToBottomOfHiddenStack:(SLPaperView*)page;
-(void) pushPaperToTopOfHiddenStack:(SLPaperView*)page;

-(void) emptyBezelStackToHiddenStackAnimated:(BOOL)animated onComplete:(void(^)(BOOL finished))completionBlock;
-(void) popTopPageOfHiddenStack;
-(void) ensureAtLeast:(NSInteger)numberOfPagesToEnsure pagesInStack:(UIView*)stackView;
-(void) realignPagesInVisibleStackExcept:(SLPaperView*)page animated:(BOOL)animated;
-(void) animatePageToFullScreen:(SLPaperView*)page withDelay:(CGFloat)delay withBounce:(BOOL)bounce onComplete:(void(^)(BOOL finished))completionBlock;


-(void) loadVisiblePageIfNeeded;

@end
