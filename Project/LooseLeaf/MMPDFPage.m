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
#import "Constants.h"

@implementation MMPDFPage{
    MMPDF* pdf;
    NSInteger pageNumber;
    UIImage* thumb;
}

-(id) initWithPDF:(MMPDF*)_pdf andPage:(NSInteger)_pageNum{
    if(self = [super init]){
        pdf = _pdf;
        pageNumber = _pageNum;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pdfThumbnailGenerated:) name:kPDFThumbnailGenerated object:pdf];
        NSLog(@"pdf page %d %p is registered to listen for notifcations from %p", (int) pageNumber, self, pdf);
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

#pragma mark - Notification

-(void) pdfThumbnailGenerated:(NSNotification*)obj{
    NSInteger updatedPageNumber = [[[obj userInfo] objectForKey:@"pageNumber"] integerValue];
    if(updatedPageNumber == pageNumber){
        NSLog(@"pdf page %d %p heard thumbnail generation from %p", (int) pageNumber, self, obj.object);
        [[NSNotificationCenter defaultCenter] postNotificationName:kDisplayAssetThumbnailGenerated object:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - Dealloc

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
