//
//  UIImage+MMColor.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/11/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "UIImage+MMColor.h"

@implementation UIImage (MMColor)

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
