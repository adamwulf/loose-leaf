//
//  MMDisplayAsset.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/5/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMDisplayAsset.h"
#import "Constants.h"
#import <JotUI/UIImage+Resize.h>


@implementation MMDisplayAsset

- (UIImage*)aspectRatioThumbnail {
    @throw kAbstractMethodException;
}

- (UIImage*)aspectThumbnailWithMaxPixelSize:(int)maxDim {
    @throw kAbstractMethodException;
}

- (UIImage*)aspectThumbnailWithMaxPixelSize:(int)maxDim andRatio:(CGFloat)ratio {
    @autoreleasepool {
        return [self aspectThumbnailWithMaxPixelSize:maxDim];
    }
}

- (NSURL*)fullResolutionURL {
    @throw kAbstractMethodException;
}

- (CGSize)fullResolutionSize {
    @throw kAbstractMethodException;
}

- (CGSize)resolutionSizeWithMaxDim:(NSInteger)maxDim {
    CGSize currSize = self.fullResolutionSize;
    CGFloat ratio = currSize.width / currSize.height;
    if (ratio > 1) {
        return CGSizeMake(maxDim, floor(maxDim / ratio));
    } else {
        return CGSizeMake(floor(ratio * maxDim), maxDim);
    }
}

- (CGFloat)defaultRotation {
    return 0;
}

- (CGFloat)preferredImportMaxDim {
    return kPhotoImportMaxDim;
}

- (UIBezierPath*)fullResolutionPath {
    return nil;
}

@end
