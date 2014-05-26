//
//  MMImageSidebarContainerViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/2/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MMSlidingSidebarContainerViewDelegate.h"

@class MMBufferedImageView;
@class MMBorderedCamView;

@protocol MMImageSidebarContainerViewDelegate <MMSlidingSidebarContainerViewDelegate>

-(void) pictureTakeWithCamera:(UIImage*)img fromView:(MMBorderedCamView*)cameraView;

-(void) photoWasTapped:(ALAsset *)asset fromView:(MMBufferedImageView *)bufferedImage withRotation:(CGFloat)rotation fromContainer:(NSString*)containerDescription;

@end
