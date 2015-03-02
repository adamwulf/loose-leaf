//
//  MMPDF.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPDF.h"

@implementation MMPDF{
    NSURL* pdfResourceURL;
    NSUInteger pageCount;
}

-(id) initWithURL:(NSURL*)pdfURL{
    if(self = [super init]){
        pdfResourceURL = pdfURL;

        // fetch page count
        CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL( (__bridge CFURLRef) pdfResourceURL );
		pageCount = CGPDFDocumentGetNumberOfPages( pdf );
		CGPDFDocumentRelease( pdf );
    }
    return self;
}

-(NSURL*) urlOnDisk{
    return pdfResourceURL;
}

-(NSUInteger) pageCount{
    return pageCount;
}

-(UIImage*) imageForPage:(NSUInteger)page withMaxDim:(CGFloat)maxDim{
    page+=1; // pdfs are index 1 at the start!
    CGSize sizeOfPage = [self sizeForPage:page-1];
    if(sizeOfPage.width > maxDim || sizeOfPage.height > maxDim){
        CGFloat maxCurrDim = MAX(sizeOfPage.width, sizeOfPage.height);
        CGFloat ratio = maxDim / maxCurrDim;
        sizeOfPage.width *= ratio;
        sizeOfPage.height *= ratio;
    }
    
    UIGraphicsBeginImageContextWithOptions(sizeOfPage, NO, 1);
    CGContextRef cgContext = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] setFill];
    CGContextFillRect(cgContext, CGRectMake(0, 0, sizeOfPage.width, sizeOfPage.height));
    [self renderIntoContext:cgContext size:sizeOfPage page:page];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(CGSize) sizeForPage:(NSUInteger)page{
    if(page >= pageCount){
        page = pageCount - 1;
    }
    page+=1; // pdfs are index 1 at the start!
    /*
     * Reference: http://www.cocoanetics.com/2010/06/rendering-pdf-is-easier-than-you-thought/
     */
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL( (__bridge CFURLRef) pdfResourceURL );
    
    size_t num = CGPDFDocumentGetNumberOfPages(pdf);
    CGPDFPageRef page1 = CGPDFDocumentGetPage( pdf, page );
    
    CGRect mediaRect = CGPDFPageGetBoxRect( page1, kCGPDFCropBox );
    
    CGPDFDocumentRelease( pdf );
    return mediaRect.size;
}

#pragma mark - Private

-(void)renderIntoContext:(CGContextRef)ctx size:(CGSize)size page:(NSUInteger)page
{
    page+=1; // pdfs are index 1 at the start!
    /*
     * Reference: http://www.cocoanetics.com/2010/06/rendering-pdf-is-easier-than-you-thought/
     */
    CGContextGetCTM( ctx );
    CGContextScaleCTM( ctx, 1, -1 );
    CGContextTranslateCTM( ctx, 0, -size.height );
    
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL( (__bridge CFURLRef) pdfResourceURL );
    
    CGPDFPageRef page1 = CGPDFDocumentGetPage( pdf, page );
    
    CGRect mediaRect = CGPDFPageGetBoxRect( page1, kCGPDFCropBox );
    CGContextScaleCTM( ctx, size.width / mediaRect.size.width, size.height / mediaRect.size.height );
    CGContextTranslateCTM( ctx, -mediaRect.origin.x, -mediaRect.origin.y );
    
    CGContextDrawPDFPage( ctx, page1 );
    CGPDFDocumentRelease( pdf );
}

@end
