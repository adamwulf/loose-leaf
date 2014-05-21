//
//  MMImageImporter.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/21/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMImageImporter.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation MMImageImporter

static MMImageImporter* _instance = nil;

+(MMImageImporter*) sharedInstace{
    if(!_instance){
        _instance = [[MMImageImporter alloc]init];
    }
    return _instance;
}


+(NSString*) UTIForExtension:(NSString*)fileExtension{
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
    if(!UTI){
        UTI = @"unknown";
    }
    return [UTI lowercaseString];
}

-(UIImage*) imageForURL:(NSURL*)url maxDim:(int)maxDim{
    
    NSLog(@"url of image: %@", url);
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, nil);
    
    CGSize fullScale;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:NO], (NSString *)kCGImageSourceShouldCache, nil];
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
    if (imageProperties) {
        NSNumber *width = (NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
        NSNumber *height = (NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
        fullScale.width = [width floatValue];
        fullScale.height = [height floatValue];
        NSLog(@"Image dimensions: %@ x %@ px", width, height);
        CFRelease(imageProperties);
        maxDim = MIN(MAX(fullScale.width, fullScale.height), maxDim);
    }
    
    NSLog(@"found max dimension: %d", maxDim);
    
    CGFloat scale = [UIScreen mainScreen].scale;
    NSDictionary* d = @{(id)kCGImageSourceShouldAllowFloat: (id)kCFBooleanTrue,
                        (id)kCGImageSourceCreateThumbnailWithTransform: (id)kCFBooleanTrue,
                        (id)kCGImageSourceCreateThumbnailFromImageAlways: (id)kCFBooleanTrue,
                        (id)kCGImageSourceThumbnailMaxPixelSize: @(maxDim)};
    CGImageRef imref = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)d);
    UIImage* scrapBacking = nil;
    
    if(imref){
        scrapBacking = [UIImage imageWithCGImage:imref scale:scale orientation:UIImageOrientationUp];
        CFRelease(imref);
    }
    CFRelease(imageSource);
    
    return scrapBacking;
}

@end
