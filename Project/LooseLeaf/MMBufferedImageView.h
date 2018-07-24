//
//  MMBufferedImageView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDisplayAsset.h"


@interface MMBufferedImageView : UIView <MMDisplayAssetCoordinator>

@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, strong) UIImage* image;

@end
