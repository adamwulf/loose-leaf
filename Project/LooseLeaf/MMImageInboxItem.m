//
//  MMImageInboxItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/11/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMImageInboxItem.h"
#import "MMInboxItem+Protected.h"
#import "Constants.h"
#import "NSURL+UTI.h"
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>


@implementation MMImageInboxItem {
    CGSize cachedSize;
}

- (id)initWithURL:(NSURL*)itemURL {
    if (self = [super initWithURL:itemURL andInitBlock:nil]) {
        cachedSize = CGSizeZero;
    }
    return self;
}

#pragma mark - Override

- (NSUInteger)pageCount {
    return 1;
}

- (CGSize)calculateSizeForPage:(NSUInteger)page {
    // size isn't in the cache, so find out and return it
    // we dont' update the cache ourselves though.
    if (CGSizeEqualToSize(cachedSize, CGSizeZero)) {
        @autoreleasepool {
            UIImage* img = [UIImage imageWithContentsOfFile:[self.urlOnDisk path]];
            cachedSize = img.size;
        }
    }
    return cachedSize;
}

- (UIImage*)generateImageForPage:(NSUInteger)page withMaxDim:(CGFloat)maxDim {
    return [self imageForURL:self.urlOnDisk maxDim:maxDim];
}


#pragma mark - Private Helpers

- (UIImage*)imageForURL:(NSURL*)url maxDim:(int)maxDim {
    if ([[url fileExtension] isEqualToString:@"icns"]) {
        CFBooleanRef b = (__bridge CFBooleanRef)([NSNumber numberWithBool:YES]);
        NSDictionary* sourceDict = [NSDictionary dictionaryWithObjectsAndKeys:(id)kUTTypeAppleICNS, kCGImageSourceTypeIdentifierHint,
                                                                              b, kCGImageSourceShouldAllowFloat, nil];
        //        DebugLog(@"url of image: %@", url);
        //        CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, (__bridge CFDictionaryRef)(sourceDict));

        //        NSString* type = (__bridge NSString *)(CGImageSourceGetType (imageSource));
        //        DebugLog(@"input type: %p %@", imageSource, type);

        //        CGImageSourceStatus status = CGImageSourceGetStatus (imageSource);
        //        DebugLog(@"status: %d", status);

        //        size_t foo = CGImageSourceGetCount (imageSource);
        //        DebugLog(@"size: %zu", foo);

        [NSDictionary dictionaryWithDictionary:sourceDict];
    }

    //    DebugLog(@"url of image: %@", url);
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, nil);

    CGSize fullScale;
    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], (NSString*)kCGImageSourceShouldCache, nil];
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
    if (imageProperties) {
        NSNumber* width = (NSNumber*)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
        NSNumber* height = (NSNumber*)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
        fullScale.width = [width floatValue];
        fullScale.height = [height floatValue];
        //        DebugLog(@"Image dimensions: %@ x %@ px", width, height);
        CFRelease(imageProperties);
        maxDim = MIN(MAX(fullScale.width, fullScale.height), maxDim);
    }

    //    DebugLog(@"found max dimension: %d", maxDim);

    NSDictionary* d = @{(id)kCGImageSourceShouldAllowFloat: (id)kCFBooleanTrue,
                        (id)kCGImageSourceCreateThumbnailWithTransform: (id)kCFBooleanTrue,
                        (id)kCGImageSourceCreateThumbnailFromImageAlways: (id)kCFBooleanTrue,
                        (id)kCGImageSourceThumbnailMaxPixelSize: @(maxDim) };
    CGImageRef imref = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)d);
    UIImage* scrapBacking = nil;

    if (imref) {
        // need to always import images at 1.0x scale
        scrapBacking = [UIImage imageWithCGImage:imref scale:1.0 orientation:UIImageOrientationUp];
        CFRelease(imref);
    }
    CFRelease(imageSource);

    return scrapBacking;
}

@end
