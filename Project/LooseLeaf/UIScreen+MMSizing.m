//
//  UIScreen+MMSizing.m
//  LooseLeaf
//
//  Created by Adam Wulf on 11/11/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "UIScreen+MMSizing.h"


@implementation UIScreen (MMSizing)

+ (CGFloat)screenWidth {
    static CGFloat screenWidth = 0;
    if (!screenWidth) {
        screenWidth = CGRectGetWidth([[[UIScreen mainScreen] fixedCoordinateSpace] bounds]);
    }
    return screenWidth;
}

+ (CGFloat)screenHeight {
    static CGFloat screenHeight = 0;
    if (!screenHeight) {
        screenHeight = CGRectGetHeight([[[UIScreen mainScreen] fixedCoordinateSpace] bounds]);
    }

    return screenHeight;
}

+ (CGSize)screenSize {
    return CGSizeMake([UIScreen screenWidth], [UIScreen screenHeight]);
}

@end
