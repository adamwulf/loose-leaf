//
//  UIColor+Shadow.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/9/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "UIColor+Shadow.h"


@implementation UIColor (Shadow)

static UIColor* shadowColor;
static UIColor* blueShadowColor;
+ (UIColor*)shadowColor {
    if (shadowColor) {
        return shadowColor;
    }
    shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.35];
    return shadowColor;
}

+ (UIColor*)blueShadowColor {
    if (blueShadowColor) {
        return blueShadowColor;
    }
    blueShadowColor = [UIColor colorWithRed:77.0 / 255.0 green:187.0 / 255.0 blue:1.0 alpha:0.5];
    return blueShadowColor;
}


+ (UIColor*)lightBlueShadowColor {
    if (blueShadowColor) {
        return blueShadowColor;
    }
    blueShadowColor = [UIColor colorWithRed:127.0 / 255.0 green:237.0 / 255.0 blue:1.0 alpha:0.7];
    return blueShadowColor;
}
@end
