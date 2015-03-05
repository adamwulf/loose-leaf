//
//  MMDisplayAsset.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/5/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMDisplayAsset.h"
#import "Constants.h"

@implementation MMDisplayAsset

-(UIImage*) aspectRatioThumbnail{
    @throw kAbstractMethodException;
}

-(UIImage*) aspectThumbnailWithMaxPixelSize:(int)maxDim{
    @throw kAbstractMethodException;
}

-(NSURL*) fullResolutionURL{
    @throw kAbstractMethodException;
}

-(CGSize) fullResolutionSize{
    @throw kAbstractMethodException;
}

@end
