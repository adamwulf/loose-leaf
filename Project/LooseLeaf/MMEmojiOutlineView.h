//
//  MMEmojiOutlineView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/7/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDisplayAsset.h"

NS_ASSUME_NONNULL_BEGIN


@interface MMEmojiOutlineView : UIView <MMDisplayAssetCoordinator>

@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, copy) UIBezierPath* shape;
@property (nonatomic, strong) UIImage* image;

@end

NS_ASSUME_NONNULL_END
