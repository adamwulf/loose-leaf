//
//  MMPaperStackView.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "Constants.h"
#import <UIKit/UIKit.h>
#import "MMPaperView.h"
#import "NSMutableArray+StackAdditions.h"
#import "MMPaperIcon.h"
#import "MMPapersIcon.h"
#import "MMPlusIcon.h"
#import "MMLeftArrow.h"
#import "MMRightArrow.h"
#import "MMBezelInRightGestureRecognizer.h"
#import "UIView+SubviewStacks.h"
#import "UIView+Debug.h"
#import "UIView+Animations.h"
#import "NSMutableSet+Extras.h"
#import "Constants.h"
#import "MMPopoverView.h"

@interface MMPaperStackView : UIScrollView<MMPaperViewDelegate>{
    @private
    // this is the UUID of the page that has
    // most recently been suggested that it might
    // be the top page soon
    NSString* recentlySuggestedPageUUID;
    
    MMPapersIcon* papersIcon;
    MMPaperIcon* paperIcon;
    MMPlusIcon* plusIcon;
    MMLeftArrow* leftArrow;
    MMRightArrow* rightArrow;
    
    // track if we're currently pulling in a page
    // from the bezel
    MMPaperView* inProgressOfBezeling;
    
    @protected
    MMBezelInRightGestureRecognizer* fromRightBezelGesture;
    
    UIView* visibleStackHolder;
    UIView* hiddenStackHolder;
    UIView* bezelStackHolder;

    NSMutableSet* setOfPagesBeingPanned;
}

@property (nonatomic, readonly) UIView* stackHolder;

-(void) addPaperToBottomOfStack:(MMPaperView*)page;
-(void) addPaperToBottomOfHiddenStack:(MMPaperView*)page;

-(void) emptyBezelStackToHiddenStackAnimated:(BOOL)animated onComplete:(void(^)(BOOL finished))completionBlock;
-(void) emptyBezelStackToHiddenStackAnimated:(BOOL)animated andPreserveFrame:(BOOL)preserveFrame onComplete:(void(^)(BOOL finished))completionBlock;
-(void) popTopPageOfHiddenStack;
-(void) ensureAtLeast:(NSInteger)numberOfPagesToEnsure pagesInStack:(UIView*)stackView;
-(void) realignPagesInVisibleStackExcept:(MMPaperView*)page animated:(BOOL)animated;
-(void) animatePageToFullScreen:(MMPaperView*)page withDelay:(CGFloat)delay withBounce:(BOOL)bounce onComplete:(void(^)(BOOL finished))completionBlock;
-(BOOL) shouldPopPageFromVisibleStack:(MMPaperView*)page withFrame:(CGRect)frame;
@end
