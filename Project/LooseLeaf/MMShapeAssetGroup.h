//
//  MMShapeAssetGroup.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/21/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMDisplayAssetGroup.h"

NS_ASSUME_NONNULL_BEGIN


@interface MMShapeAssetGroup : MMDisplayAssetGroup

+ (MMShapeAssetGroup*)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
