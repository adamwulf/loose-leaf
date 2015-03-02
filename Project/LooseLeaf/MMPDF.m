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

-(void)renderIntoContext:(CGContextRef)ctx size:(CGSize)size page:(NSUInteger)page
{
    if ( pdfResourceURL)
    {
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
}


-(NSUInteger) pageCount{
    return pageCount;
}

@end
