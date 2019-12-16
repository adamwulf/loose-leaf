//
//  ALAsset+Thumbnail.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/31/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "ALAsset+Thumbnail.h"
#import "Constants.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>


@implementation ALAsset (Thumbnail)


- (NSString*)type {
    return [self valueForProperty:ALAssetPropertyType];
}

- (NSURL*)url {
    return [self valueForProperty:ALAssetPropertyAssetURL];
}

- (NSDictionary*)urls {
    return [self valueForProperty:ALAssetPropertyURLs];
}

- (CLLocation*)location {
    return [self valueForProperty:ALAssetPropertyLocation];
}

- (NSNumber*)duration {
    NSNumber* ret = [self valueForProperty:ALAssetPropertyDuration];
    if ([ALErrorInvalidProperty isEqual:ret]) {
        return nil;
    }
    return ret;
}

- (NSNumber*)orientation {
    return [self valueForProperty:ALAssetPropertyOrientation];
}

- (NSDate*)date {
    return [self valueForProperty:ALAssetPropertyDate];
}

- (NSArray*)representations {
    return [self valueForProperty:ALAssetPropertyRepresentations];
}


// See http://mindsea.com/2012/12/18/downscaling-huge-alassets-without-fear-of-sigkill for details

// Helper methods for thumbnailForAsset:maxPixelSize:
static size_t getAssetBytesCallback(void* info, void* buffer, off_t position, size_t count) {
    ALAssetRepresentation* rep = (__bridge id)info;

    NSError* error = nil;
    size_t countRead = [rep getBytes:(uint8_t*)buffer fromOffset:position length:count error:&error];

    if (countRead == 0 && error) {
        // We have no way of passing this info back to the caller, so we log it, at least.
        DebugLog(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }

    return countRead;
}

static void releaseAssetCallback(void* info) {
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}

// Returns a UIImage for the given asset, with size length at most the passed size.
// The resulting UIImage will be already rotated to UIImageOrientationUp, so its CGImageRef
// can be used directly without additional rotation handling.
// This is done synchronously, so you should call this method on a background queue/thread.
- (UIImage*)aspectThumbnailWithMaxPixelSize:(int)size {
    NSParameterAssert(size > 0);

    ALAssetRepresentation* rep = [self defaultRepresentation];

    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };

    CGImageRef imageRef = NULL;
    CGDataProviderRef provider = CGDataProviderCreateDirect((void*)CFBridgingRetain(rep), [rep size], &callbacks);

    if (provider) {
        CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);

        if (source) {
            imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{
                (NSString*)kCGImageSourceCreateThumbnailFromImageAlways: @YES,
                (NSString*)kCGImageSourceThumbnailMaxPixelSize: [NSNumber numberWithInt:size],
                (NSString*)kCGImageSourceCreateThumbnailWithTransform: @YES,
            });
            CFRelease(source);
        }
        CGDataProviderRelease(provider);
    }

    if (!imageRef) {
        return nil;
    }

    UIImage* toReturn = [UIImage imageWithCGImage:imageRef];

    CGImageRelease(imageRef);

    return toReturn;
}

@end
