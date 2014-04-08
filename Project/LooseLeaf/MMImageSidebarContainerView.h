//
//  MMImageSlidingSidebarView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMSlidingSidebarContainerView.h"
#import "MMImageSidebarContainerViewDelegate.h"
#import "ALAsset+Thumbnail.h"

@interface MMImageSidebarContainerView : MMSlidingSidebarContainerView

@property (nonatomic, weak) NSObject<MMImageSidebarContainerViewDelegate>* delegate;

-(void) photoWasTapped:(ALAsset *)asset fromView:(MMBufferedImageView *)bufferedImage;

@end
