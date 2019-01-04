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
#import "MMBezelInGestureRecognizer.h"
#import "UIView+SubviewStacks.h"
#import "UIView+Debug.h"
#import "UIView+Animations.h"
#import "NSMutableSet+Extras.h"
#import "Constants.h"
#import "MMPageCacheManager.h"
#import "MMGestureTouchOwnershipDelegate.h"
#import "MMPaperStackViewDelegate.h"


@interface MMPaperStackView : UIScrollView <MMPaperViewDelegate, MMGestureTouchOwnershipDelegate> {
   @protected
    MMBezelInGestureRecognizer* _fromRightBezelGesture;
    MMBezelInGestureRecognizer* _fromLeftBezelGesture;

    NSMutableSet* _setOfPagesBeingPanned;
}

@property (nonatomic, readonly) NSString* uuid;
@property (nonatomic, readonly) MMSingleStackManager* stackManager;
@property (nonatomic, readonly) UIView* visibleStackHolder;
@property (nonatomic, readonly) UIView* hiddenStackHolder;
@property (nonatomic, readonly) UIView* bezelStackHolder;
@property (nonatomic, weak) NSObject<MMPaperStackViewDelegate>* stackDelegate;

- (id)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid;

- (void)addPaperToBottomOfStack:(MMPaperView*)page;
- (void)addPaperToBottomOfHiddenStack:(MMPaperView*)page;
- (void)addPage:(MMPaperView*)page belowPage:(MMPaperView*)otherPage;

- (void)emptyBezelStackToHiddenStackAnimated:(BOOL)animated onComplete:(void (^)(BOOL finished))completionBlock;
- (void)emptyBezelStackToHiddenStackAnimated:(BOOL)animated andPreservePageFrame:(BOOL)preserveFrame onComplete:(void (^)(BOOL finished))completionBlock;
- (void)popTopPageOfHiddenStack;
- (void)ensureAtLeast:(NSInteger)numberOfPagesToEnsure pagesInStack:(UIView*)stackView;
- (void)realignPagesInVisibleStackExcept:(MMPaperView*)page animated:(BOOL)animated;
- (void)animatePageToFullScreen:(MMPaperView*)page withDelay:(CGFloat)delay withBounce:(BOOL)bounce onComplete:(void (^)(BOOL finished))completionBlock;
- (BOOL)shouldPopPageFromVisibleStack:(MMPaperView*)page withFrame:(CGRect)frame;

- (void)cancelAllGestures;
- (void)disableAllGesturesForPageView;
- (void)enableAllGesturesForPageView;

- (void)addPageButtonTapped:(UIButton*)_button;

// private

- (void)mayChangeTopPageTo:(MMPaperView*)page;
- (void)willChangeTopPageTo:(MMPaperView*)page;
- (void)didChangeTopPage;
- (void)didChangeTopPageTo:(MMPaperView*)page;
- (void)willNotChangeTopPageTo:(MMPaperView*)page;
- (void)isBezelingInRightWithGesture:(MMBezelInGestureRecognizer*)bezelGesture;
- (void)isBezelingInLeftWithGesture:(MMBezelInGestureRecognizer*)bezelGesture;
- (void)saveStacksToDisk;

- (NSString*)activeGestureSummary;

- (BOOL)isActivelyGesturing;

@end
