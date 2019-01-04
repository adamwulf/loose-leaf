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
#import "MMPDFInboxItem.h"


@interface MMImageSidebarContainerView : MMFullScreenSidebarContainingView <MMPhotoManagerDelegate>

@property (nonatomic, weak) NSObject<MMImageSidebarContainerViewDelegate>* delegate;

- (void)pictureTakeWithCamera:(UIImage*)img fromView:(MMBorderedCamView*)cameraView;

- (void)assetWasTapped:(MMDisplayAsset*)asset fromView:(UIView<MMDisplayAssetCoordinator>*)bufferedImage withBackgroundColor:(UIColor*)color withRotation:(CGFloat)rotation fromContainer:(MMAbstractSidebarContentView*)container;

- (void)updateInterfaceTo:(UIInterfaceOrientation)orientation;

- (void)showPDF:(MMInboxItem*)pdf;

- (void)refreshPDF;

@end
