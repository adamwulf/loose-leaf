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
#import "MMPopoverView.h"
#import "MMPageCacheManager.h"

@interface MMPaperStackView : UIScrollView<MMPaperViewDelegate>{

@protected
    MMBezelInGestureRecognizer* fromRightBezelGesture;
    MMBezelInGestureRecognizer* fromLeftBezelGesture;
    
    UIView* visibleStackHolder;
    UIView* hiddenStackHolder;
    UIView* bezelStackHolder;
    
    NSMutableSet* setOfPagesBeingPanned;
}

@property (nonatomic, readonly) UIView* visibleStackHolder;
@property (nonatomic, readonly) UIView* hiddenStackHolder;
@property (nonatomic, readonly) UIView* bezelStackHolder;

-(void) addPaperToBottomOfStack:(MMPaperView*)page;
-(void) addPaperToBottomOfHiddenStack:(MMPaperView*)page;

-(void) emptyBezelStackToHiddenStackAnimated:(BOOL)animated onComplete:(void(^)(BOOL finished))completionBlock;
-(void) emptyBezelStackToHiddenStackAnimated:(BOOL)animated andPreservePageFrame:(BOOL)preserveFrame onComplete:(void(^)(BOOL finished))completionBlock;
-(void) popTopPageOfHiddenStack;
-(void) ensureAtLeast:(NSInteger)numberOfPagesToEnsure pagesInStack:(UIView*)stackView;
-(void) realignPagesInVisibleStackExcept:(MMPaperView*)page animated:(BOOL)animated;
-(void) animatePageToFullScreen:(MMPaperView*)page withDelay:(CGFloat)delay withBounce:(BOOL)bounce onComplete:(void(^)(BOOL finished))completionBlock;
-(BOOL) shouldPopPageFromVisibleStack:(MMPaperView*)page withFrame:(CGRect)frame;

-(void) cancelAllGestures;

// private

-(void) mayChangeTopPageTo:(MMPaperView*)page;
-(void) willChangeTopPageTo:(MMPaperView*)page;
-(void) didChangeTopPage;
-(void) willNotChangeTopPageTo:(MMPaperView*)page;
-(void) isBezelingInRightWithGesture:(MMBezelInGestureRecognizer*)bezelGesture;
-(void) isBezelingInLeftWithGesture:(MMBezelInGestureRecognizer*)bezelGesture;
-(void) saveStacksToDisk;

-(NSString*) activeGestureSummary;

@end
