//
//  MMImageSlidingSidebarView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMSlidingSidebarContainerView.h"
#import "MMImageSidebarContainerViewDelegate.h"
#import "MMPhotoManagerDelegate.h"
#import "MMAbstractSidebarContentView.h"

@interface MMImageSidebarContainerView : MMSlidingSidebarContainerView<MMPhotoManagerDelegate>

@property (nonatomic, weak) NSObject<MMImageSidebarContainerViewDelegate>* delegate;

-(void) pictureTakeWithCamera:(UIImage*)img fromView:(MMBorderedCamView*)cameraView;

-(void) photoWasTapped:(MMPhoto *)asset
              fromView:(MMBufferedImageView *)bufferedImage
          withRotation:(CGFloat)rotation
         fromContainer:(MMAbstractSidebarContentView*)container;

-(void) updateInterfaceTo:(UIInterfaceOrientation)orientation;

@end
