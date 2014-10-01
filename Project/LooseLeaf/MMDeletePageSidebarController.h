//
//  MMDeletePageSidebar.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMDeletePageSidebarController : NSObject

@property (nonatomic, readonly) UIView* deleteSidebarBackground;
@property (nonatomic, readonly) UIView* deleteSidebarForeground;

-(id) initWithFrame:(CGRect)frame;

-(void) showSidebarWithPercent:(CGFloat)percent withTargetView:(UIView*)targetView;

-(void) closeSidebarAnimated;

@end
