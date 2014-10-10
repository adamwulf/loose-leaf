//
//  MMPhoto.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/25/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPhoto.h"
#import "ALAsset+Thumbnail.h"

@implementation MMPhoto{
    ALAsset* asset;
}

-(id) initWithALAsset:(ALAsset*)_asset{
    if(self = [super init]){
        asset = _asset;
    }
    return self;
}

-(UIImage*) aspectRatioThumbnail{
    return [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
}

-(UIImage*) aspectThumbnailWithMaxPixelSize:(int)maxDim{
    return [asset aspectThumbnailWithMaxPixelSize:maxDim];
}

-(NSURL*) fullResolutionURL{
    return asset.defaultRepresentation.url;
}

-(CGSize) fullResolutionSize{
    return asset.defaultRepresentation.dimensions;
}

@end
