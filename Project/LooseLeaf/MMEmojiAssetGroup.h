//
//  MMEmojiAssetGroup.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/7/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMDisplayAssetGroup.h"

NS_ASSUME_NONNULL_BEGIN


@interface MMEmojiAssetGroup : MMDisplayAssetGroup

+ (MMEmojiAssetGroup*)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
