//
//  MMPhotoOnDisk.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPhotoOnDisk.h"
#import "Mixpanel.h"
#import <JotUI/JotUI.h>


@implementation MMPhotoOnDisk {
    NSString* pathToPhoto;
    CGSize defaultSize;
    UIImage* thumb;
}

- (id)initWithPath:(NSString*)_pathToPhoto {
    if (self = [super init]) {
        pathToPhoto = _pathToPhoto;
        defaultSize = CGSizeZero;
    }
    return self;
}

- (UIImage*)aspectRatioThumbnail {
    if (!thumb) {
        thumb = [self aspectThumbnailWithMaxPixelSize:100];
    }
    return thumb;
}

- (UIImage*)aspectThumbnailWithMaxPixelSize:(int)maxDim {
    return [[JotDiskAssetManager imageWithContentsOfFile:pathToPhoto] resizedImage:[self resolutionSizeWithMaxDim:maxDim] interpolationQuality:kCGInterpolationMedium];
}

- (NSURL*)fullResolutionURL {
    return [[NSURL alloc] initFileURLWithPath:pathToPhoto];
}

- (CGSize)fullResolutionSize {
    if (CGSizeEqualToSize(defaultSize, CGSizeZero)) {
        defaultSize = [JotDiskAssetManager imageWithContentsOfFile:pathToPhoto].size;
    }
    return defaultSize;
}

@end
