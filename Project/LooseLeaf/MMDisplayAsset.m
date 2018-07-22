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
