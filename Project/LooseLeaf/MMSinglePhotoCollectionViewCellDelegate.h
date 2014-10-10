//
//  MMSinglePhotoCollectionViewCellDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/18/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#include <UIKit/UIKit.h>
#import "MMPhoto.h"
#include "MMBufferedImageView.h"

@protocol MMSinglePhotoCollectionViewCellDelegate <NSObject>

-(void) pictureTakeWithCamera:(UIImage*)img fromView:(UIView*)cameraView;

-(void) photoWasTapped:(MMPhoto *)photo
              fromView:(MMBufferedImageView *)bufferedImage
          withRotation:(CGFloat)rotation;

@end
