//
//  UIImage+MCDrawSubImage.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/20/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MCDrawSubImage)

- (void)drawInRect:(CGRect)drawRect fromRect:(CGRect)fromRect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

@end
