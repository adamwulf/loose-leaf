//
//  MMShapeAsset.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/21/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMShapeAsset.h"


@implementation MMShapeAsset {
    UIBezierPath* _path;
    NSString* _shapeName;
}

- (instancetype)initWithPath:(UIBezierPath*)path withName:(NSString*)shapeName {
    if (self = [super init]) {
        _path = path;
        _shapeName = shapeName;
    }

    return self;
}

- (UIImage*)aspectRatioThumbnail {
    return nil;
}

- (UIImage*)aspectThumbnailWithMaxPixelSize:(int)maxDim {
    return nil;
}

- (UIImage*)aspectThumbnailWithMaxPixelSize:(int)maxDim andRatio:(CGFloat)ratio {
    return nil;
}

- (NSURL*)fullResolutionURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"loose-leaf://shapes/%@.shape", _shapeName]];
}

- (CGSize)fullResolutionSize {
    return [_path bounds].size;
}

- (CGFloat)defaultRotation {
    return 0;
}

- (CGFloat)preferredImportMaxDim {
    return MAX([_path bounds].size.width, [_path bounds].size.height);
}

- (UIBezierPath*)fullResolutionPath {
    return [_path copy];
}

@end
