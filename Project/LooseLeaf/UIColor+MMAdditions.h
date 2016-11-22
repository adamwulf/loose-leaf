//
//  UIColor+MMAdditions.h
//  LooseLeaf
//
//  Created by Adam Wulf on 11/11/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIColor (MMAdditions)

- (UIColor*)blendWithColor:(UIColor*)otherColor withPercent:(CGFloat)percent;

- (UIColor*)brighten:(CGFloat)percent;

- (UIColor*)darken:(CGFloat)percent;

- (BOOL)isBright;

@end
