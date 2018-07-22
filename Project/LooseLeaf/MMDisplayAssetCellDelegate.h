//
//  MMDisplayAssetCellDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/18/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#include <UIKit/UIKit.h>
#import "MMDisplayAsset.h"

@class MMBufferedImageView;

@protocol MMDisplayAssetCellDelegate <NSObject>

- (void)pictureTakeWithCamera:(UIImage*)img fromView:(UIView*)cameraView;

- (void)assetWasTapped:(MMDisplayAsset*)asset fromView:(MMBufferedImageView*)tappedView withRotation:(CGFloat)rotation;

@end
