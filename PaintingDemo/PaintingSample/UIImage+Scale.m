//
//  UIImage+Scale.m
//  PaintingSample
//
//  Created by Adam Wulf on 10/4/12.
//
//

#import "UIImage+Scale.h"

@implementation UIImage (Scale)

+(UIImage*) maxResolutionImageNamed:(NSString*)name{
    UIImage* marsImg = [UIImage imageNamed:name];
    if([[UIScreen mainScreen] scale] != 1.0){
        // load images at high resolution
        return [UIImage imageWithCGImage:marsImg.CGImage scale:[[UIScreen mainScreen] scale] orientation:marsImg.imageOrientation];
    }
    return marsImg;
}

@end
