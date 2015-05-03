//
//  MMInboxImage.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/11/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMInboxImage.h"
#import "MMInboxItem.h"
#import "Constants.h"

@implementation MMInboxImage{
    MMInboxItem* asset;
}

-(id) initWithImageItem:(MMInboxItem*)imageItem{
    if(self = [super init]){
        asset = imageItem;
    }
    return self;
}

-(UIImage*) aspectRatioThumbnail{
    return [asset imageForPage:0 forMaxDim:kThumbnailMaxDim];
}

-(UIImage*) aspectThumbnailWithMaxPixelSize:(int)maxDim{
    return [asset imageForPage:0 forMaxDim:maxDim];
}

-(NSURL*) fullResolutionURL{
    return asset.urlOnDisk;
}

-(CGSize) fullResolutionSize{
    return [asset sizeForPage:0];
}

@end
