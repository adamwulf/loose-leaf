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

@end

NS_ASSUME_NONNULL_END
