//
//  UIBezierPath+MMEmoji.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/8/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface UIBezierPath (MMEmoji)

+ (UIBezierPath*)emojiFacePathForSize:(CGSize)size;

+ (UIBezierPath*)emojiJoyPathForSize:(CGSize)size;

+ (UIBezierPath*)emojiPrayPathForSize:(CGSize)size;

+ (UIBezierPath*)emojiRoflPathForSize:(CGSize)size;

+ (UIBezierPath*)emojiBlowingKissPathForSize:(CGSize)size;

+ (UIBezierPath*)emojiStarStruckPathForSize:(CGSize)size;

+ (UIBezierPath*)emojiThinkingPathForSize:(CGSize)size;

+ (UIBezierPath*)emojiZipperPathForSize:(CGSize)size;

+ (UIBezierPath*)emojiSleepingPathForSize:(CGSize)size;

+ (UIBezierPath*)emojiGrinSweatPathForSize:(CGSize)size;

+ (UIBezierPath*)emojiSquintToungePathForSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
