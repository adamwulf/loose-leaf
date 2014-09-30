//
//  MMDeletePageSidebar.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMDeletePageSidebarController.h"

@implementation MMDeletePageSidebarController{
    UIView* deleteSidebarBackground;
    UIView* deleteSidebarForeground;
}

@synthesize deleteSidebarBackground;
@synthesize deleteSidebarForeground;

-(id) initWithFrame:(CGRect)frame{
    if(self = [super init]){
        deleteSidebarBackground = [[UIView alloc] initWithFrame:frame];
        deleteSidebarBackground.backgroundColor = [UIColor whiteColor];
        deleteSidebarForeground = [[UIView alloc] initWithFrame:frame];
        deleteSidebarForeground.backgroundColor = [UIColor clearColor];
        [self showSidebarWithPercent:0];
    }
    return self;
}

-(void) showSidebarWithPercent:(CGFloat)percent{
    CGRect fr = CGRectMake(-deleteSidebarForeground.bounds.size.width + 200 * percent, 0, deleteSidebarForeground.bounds.size.width, deleteSidebarForeground.bounds.size.height);
    deleteSidebarBackground.frame = fr;
    deleteSidebarForeground.frame = fr;
}


@end
