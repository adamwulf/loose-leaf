//
//  MMImageSlidingSidebarView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMFullScreenSidebarContainingView.h"
#import "MMImageSidebarContainerViewDelegate.h"
#import "MMPhotoManagerDelegate.h"
#import "MMAbstractSidebarContentView.h"
#import "MMPDF.h"

@interface MMImageSidebarContainerView : MMFullScreenSidebarContainingView<MMPhotoManagerDelegate>

@property (nonatomic, weak) NSObject<MMImageSidebarContainerViewDelegate>* delegate;

-(void) pictureTakeWithCamera:(UIImage*)img fromView:(MMBorderedCamView*)cameraView;

-(void) photoWasTapped:(MMDisplayAsset *)asset
              fromView:(MMBufferedImageView *)bufferedImage
          withRotation:(CGFloat)rotation
         fromContainer:(MMAbstractSidebarContentView*)container;

-(void) updateInterfaceTo:(UIInterfaceOrientation)orientation;

-(void) showPDF:(MMPDF*)pdf;

-(void) refreshPDF;

@end
