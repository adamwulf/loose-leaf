//
//  MMShapeAsset.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/21/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMDisplayAsset.h"

NS_ASSUME_NONNULL_BEGIN


@interface MMShapeAsset : MMDisplayAsset

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPath:(UIBezierPath*)path withName:(NSString*)shapeName;

@end

NS_ASSUME_NONNULL_END
