//
//  UIColor+MMAdditions.m
//  LooseLeaf
//
//  Created by Adam Wulf on 11/11/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "UIColor+MMAdditions.h"


@implementation UIColor (MMAdditions)

- (UIColor*)blendWithColor:(UIColor*)otherColor withPercent:(CGFloat)percent {
    CGFloat red1, green1, blue1, alpha1;
    [self getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];

    CGFloat red2, green2, blue2, alpha2;
    [otherColor getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];


    CGFloat red = (1 - percent) * red1 + percent * red2;
    CGFloat green = (1 - percent) * green1 + percent * green2;
    CGFloat blue = (1 - percent) * blue1 + percent * blue2;
    CGFloat alpha = (1 - percent) * alpha1 + percent * alpha2;

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (UIColor*)brightOrDarken:(CGFloat)percent {
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];


    CGFloat t = percent < 0 ? 0 : 1.0;
    CGFloat p = ABS(percent);

    red = (t - red) * p + red;
    green = (t - green) * p + green;
    blue = (t - blue) * p + blue;

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (UIColor*)brighten:(CGFloat)percent {
    return [self brightOrDarken:MAX(0, MIN(percent, 1))];
}

- (UIColor*)darken:(CGFloat)percent {
    return [self brightOrDarken:-ABS(MAX(0, MIN(percent, 1)))];
}

- (BOOL)isBright {
    const CGFloat* componentColors = CGColorGetComponents(self.CGColor);

    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    if (colorBrightness < 0.5) {
        return NO;
    } else {
        return YES;
    }
}


@end
