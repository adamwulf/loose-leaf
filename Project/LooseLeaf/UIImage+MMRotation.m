//
//  UIImage+MMRotation.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/11/17.
//  Copyright © 2017 Milestone Made, LLC. All rights reserved.
//

#import "UIImage+MMRotation.h"

@implementation UIImage (MMRotation)

- (UIImage*)rotateClockwise:(BOOL)clockwise
{
    @autoreleasepool {
        CGSize size = self.size;
        UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
        [[UIImage imageWithCGImage:[self CGImage]
                             scale:1.0
                       orientation:clockwise ? UIImageOrientationRight : UIImageOrientationLeft]
         drawInRect:CGRectMake(0,0,size.height ,size.width)];
        
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}
@end
