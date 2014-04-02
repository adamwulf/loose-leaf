//
//  MMPhotoRowViewDelegate.h
//  LooseLeaf
//
//  Created by Adam Wulf on 4/2/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class MMPhotoRowView;
@class MMBufferedImageView;

@protocol MMPhotoRowViewDelegate <NSObject>

-(void) photoRowWasTapped:(MMPhotoRowView*)row forAsset:(ALAsset*)index forImage:(MMBufferedImageView*)bufferedImage;

@end
