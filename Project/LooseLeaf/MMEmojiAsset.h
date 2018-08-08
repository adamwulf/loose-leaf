//
//  MMEmojiAsset.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/7/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMDisplayAsset.h"

NS_ASSUME_NONNULL_BEGIN


@interface MMEmojiAsset : MMDisplayAsset

- (instancetype)initWithEmoji:(NSString*)emoji withName:(NSString*)emojiName;

@end

NS_ASSUME_NONNULL_END
