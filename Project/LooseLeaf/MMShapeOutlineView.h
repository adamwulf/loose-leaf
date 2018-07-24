//
//  MMShapeOutlineView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/23/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDisplayAsset.h"

NS_ASSUME_NONNULL_BEGIN


@interface MMShapeOutlineView : UIView <MMDisplayAssetCoordinator>

@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, copy) UIBezierPath* shape;

@end

NS_ASSUME_NONNULL_END
