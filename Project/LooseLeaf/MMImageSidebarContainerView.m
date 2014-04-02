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

@dynamic delegate;

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton *)_button animateFromLeft:(BOOL)fromLeft{
    self = [super initWithFrame:frame forButton:_button animateFromLeft:fromLeft];
    if (self) {
        // Initialization code
        contentView = [[MMImageSidebarContentView alloc] initWithFrame:[sidebarContentView contentBounds]];
        contentView.delegate = self;
        [sidebarContentView addSubview:contentView];
    }
    return self;
}

-(void) show:(BOOL)animated{
    [super show:animated];
    [contentView show:animated];
}

-(void) hide:(BOOL)animated{
    [super hide:animated];
    [contentView hide:animated];
}

-(void) photoWasTapped:(ALAsset *)asset fromView:(MMBufferedImageView *)bufferedImage{
    [self.delegate photoWasTapped:asset fromView:bufferedImage];
}


@end
