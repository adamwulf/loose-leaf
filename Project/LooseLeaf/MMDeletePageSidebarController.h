//
//  MMDeletePageSidebar.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMExportablePaperView.h"


@interface MMDeletePageSidebarController : NSObject

@property (nonatomic, readonly) UIView* deleteSidebarBackground;
@property (nonatomic, readonly) UIView* deleteSidebarForeground;

@property (nonatomic, copy) void (^deleteCompleteBlock)(UIView* deletedView);

- (id)initWithFrame:(CGRect)frame andDarkBorder:(BOOL)dark;

- (void)showSidebarWithPercent:(CGFloat)percent withTargetView:(UIView*)targetView;

- (void)closeSidebarAnimated;

// returns YES if the page would be dropped in the
// sidebar at its current location
- (BOOL)shouldDelete:(UIView*)pageMightDelete;

- (void)deleteView:(UIView*)pageToDelete onComplete:(void (^)(BOOL didDelete))onComplete;

@end
