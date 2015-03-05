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
    UIImage* thumb;
}

-(id) initWithPDF:(MMPDF*)_pdf andPage:(NSInteger)_pageNum{
    if(self = [super init]){
        pdf = _pdf;
        pageNumber = _pageNum;
    }
    return self;
}

-(UIImage*) aspectRatioThumbnail{
    if(!thumb) {
        thumb = [pdf thumbnailForPage:pageNumber];
    }
    return thumb;
}

-(UIImage*) aspectThumbnailWithMaxPixelSize:(int)maxDim{
    return [pdf imageForPage:pageNumber withMaxDim:maxDim];
}

-(NSURL*) fullResolutionURL{
    return [[NSBundle mainBundle] URLForResource:@"livestream-header" withExtension:@"png"];
}

-(CGSize) fullResolutionSize{
    return [pdf sizeForPage:pageNumber];
}

@end
