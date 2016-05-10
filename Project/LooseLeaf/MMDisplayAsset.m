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

-(UIImage*) aspectRatioThumbnail{
    @throw kAbstractMethodException;
}

-(UIImage*) aspectThumbnailWithMaxPixelSize:(int)maxDim{
    @throw kAbstractMethodException;
}

-(UIImage*) aspectThumbnailWithMaxPixelSize:(int)maxDim andRatio:(CGFloat)ratio{
    
    UIImage* ret = [self aspectThumbnailWithMaxPixelSize:maxDim];
    
    CGSize size = [self fullResolutionSize];
    CGFloat pdfRatio = ret.size.width / ret.size.height;
    
    if((pdfRatio > 1 && ratio < 1) || (pdfRatio < 1 && ratio > 1)){
        ratio = 1 / ratio;
    }
    
    if(pdfRatio != ratio){
        if(pdfRatio > 1){
            size.width = maxDim;
            size.height = maxDim * ratio;
        }else{
            size.height = maxDim;
            size.width = maxDim * ratio;
        }
        
        ret = [ret resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:size interpolationQuality:kCGInterpolationHigh];
    }
    
    return ret;
}

-(NSURL*) fullResolutionURL{
    @throw kAbstractMethodException;
}

-(CGSize) fullResolutionSize{
    @throw kAbstractMethodException;
}

-(CGFloat) preferredImportMaxDim{
    return kPhotoImportMaxDim;
}

@end
