//
//  MMImageSlidingSidebarView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMImageSidebarContainerView.h"
#import "MMImageSidebarContentView.h"

@implementation MMImageSidebarContainerView{
    MMImageSidebarContentView* contentView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        contentView = [[MMImageSidebarContentView alloc] initWithFrame:[sidebarContentView contentBounds]];
        contentView.delegate = self;
        [sidebarContentView addSubview:contentView];
    }
    return self;
}



@end
