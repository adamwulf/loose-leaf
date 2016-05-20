//
//  UIImage+FXBlur.m
//  Remotely
//
//  Created by Adam Wulf on 6/30/15.
//  Copyright © 2015 Graceful Made. All rights reserved.
//

#import "UIImage+FXBlur.h"
#import "FXBlurView.h"

@implementation UIImage (FXBlur)

-(UIImage*) imageWithBackgroundBlur{
    return [self blurredImageWithRadius:60 iterations:3 tintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.25]];
}

@end
