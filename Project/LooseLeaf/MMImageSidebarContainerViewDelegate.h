//
//  MMImageSidebarContainerViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/2/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMSlidingSidebarContainerViewDelegate.h"
#import "MMDisplayAsset.h"

@class MMBufferedImageView;
@class MMBorderedCamView;

@protocol MMImageSidebarContainerViewDelegate <MMSlidingSidebarContainerViewDelegate>

-(void) pictureTakeWithCamera:(UIImage*)img fromView:(MMBorderedCamView*)cameraView andRequestsImportAsPage:(BOOL)asPage;

-(void) photoWasTapped:(MMDisplayAsset *)photo fromView:(MMBufferedImageView *)bufferedImage withRotation:(CGFloat)rotation fromContainer:(NSString*)containerDescription andRequestsImportAsPage:(BOOL)asPage;

@end
