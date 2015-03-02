//
//  MMPDFPage.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMPDFPage.h"
#import "MMPDF.h"
#import <JotUI/UIImage+Resize.h>

@implementation MMPDFPage{
    MMPDF* pdf;
    NSInteger pageNumber;
}

-(id) initWithPDF:(MMPDF*)_pdf andPage:(NSInteger)_pageNum{
    if(self = [super init]){
        pdf = _pdf;
        pageNumber = _pageNum;
    }
    return self;
}

-(UIImage*) aspectRatioThumbnail{
    return [[UIImage imageNamed:@"livestream-header.png"] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(100, 100) interpolationQuality:kCGInterpolationMedium];
}

-(UIImage*) aspectThumbnailWithMaxPixelSize:(int)maxDim{
    return [[UIImage imageNamed:@"livestream-header.png"] resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(maxDim, maxDim) interpolationQuality:kCGInterpolationMedium];
}

-(NSURL*) fullResolutionURL{
    return [[NSBundle mainBundle] URLForResource:@"livestream-header" withExtension:@"png"];
}

-(CGSize) fullResolutionSize{
    return CGSizeMake(1280, 720);
}

@end
