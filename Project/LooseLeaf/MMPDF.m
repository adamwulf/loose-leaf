//
//  MMPDF.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPDF.h"
#import "NSString+MD5.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "MMLoadImageCache.h"


@implementation MMPDF{
    NSURL* pdfResourceURL;
    NSUInteger pageCount;
    NSString* cachedAssetsPath;
    
    NSMutableArray* pageSizeCache;
}

#pragma mark - Queues

static dispatch_queue_t pdfAssetQueue;
static const void *const kPDFAssetQueueIdentifier = &kPDFAssetQueueIdentifier;

+(dispatch_queue_t) pdfAssetQueue{
    if(!pdfAssetQueue){
        pdfAssetQueue = dispatch_queue_create("com.milestonemade.looseleaf.pdfAssetQueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_queue_set_specific(pdfAssetQueue, kPDFAssetQueueIdentifier, (void *)kPDFAssetQueueIdentifier, NULL);
    }
    return pdfAssetQueue;
}

#pragma mark - Init

-(id) initWithURL:(NSURL*)pdfURL{
    if(self = [super init]){
        pdfResourceURL = pdfURL;

        // fetch page count
        CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL( (__bridge CFURLRef) pdfResourceURL );
		pageCount = CGPDFDocumentGetNumberOfPages( pdf );
		CGPDFDocumentRelease( pdf );
        pageSizeCache = [NSMutableArray array];
        
        [self generatePageThumbnailCache];
    }
    return self;
}

#pragma mark - Properties

-(NSString*) cachedAssetsPath{
    if(!cachedAssetsPath){
        NSString* relativeToDocuments = [pdfResourceURL path];
        relativeToDocuments = [relativeToDocuments stringByReplacingOccurrencesOfString:[NSFileManager documentsPath]
                                                                             withString:@""
                                                                                options:NSCaseInsensitiveSearch
                                                                                  range:NSMakeRange(0, [relativeToDocuments length])];
        NSString* pdfHash = [relativeToDocuments md5];
        NSLog(@"generating path: %@ to %@", relativeToDocuments, pdfHash);
        cachedAssetsPath = [[[NSFileManager documentsPath] stringByAppendingPathComponent:@"PDFCache"] stringByAppendingPathComponent:pdfHash];
        [NSFileManager ensureDirectoryExistsAtPath:cachedAssetsPath];
    }
    return cachedAssetsPath;
}

-(NSURL*) urlOnDisk{
    return pdfResourceURL;
}

-(NSUInteger) pageCount{
    return pageCount;
}

-(UIImage*) thumbnailForPage:(NSUInteger)page{
    return [self generateThumbnailForPage:page];
}

-(UIImage*) imageForPage:(NSUInteger)page withMaxDim:(CGFloat)maxDim{
    return [self generateImageForPage:page withMaxDim:maxDim];
}

-(CGSize) sizeForPage:(NSUInteger)page{
    @synchronized(self){
        // first check the cache and see if we have it
        // calculated already
        if(page < [pageSizeCache count]){
            return [[pageSizeCache objectAtIndex:page] CGSizeValue];
        }
    }
    
    // size isn't in the cache, so find out and return it
    // we dont' update the cache ourselves though.
    
    if(page >= pageCount){
        page = pageCount - 1;
    }
    page+=1; // pdfs are index 1 at the start!
    /*
     * Reference: http://www.cocoanetics.com/2010/06/rendering-pdf-is-easier-than-you-thought/
     */
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL( (__bridge CFURLRef) pdfResourceURL );
    
    CGPDFPageRef page1 = CGPDFDocumentGetPage( pdf, page );
    
    CGRect mediaRect = CGPDFPageGetBoxRect( page1, kCGPDFCropBox );
    
    CGPDFDocumentRelease( pdf );
    return mediaRect.size;
}

#pragma mark - Private
#pragma mark Thumbnail Generation

-(void) generatePageThumbnailCache{
    dispatch_async([MMPDF pdfAssetQueue], ^{
        @synchronized(self){
            [pageSizeCache removeAllObjects];
        }
        for(int i=0;i<[self pageCount];i++){
            [self generateThumbnailForPage:i];
            @synchronized(self){
                [pageSizeCache addObject:[NSValue valueWithCGSize:[self sizeForPage:i]]];
            }
        }
    });
}

-(UIImage*) generateThumbnailForPage:(NSInteger)pageNumber{
    UIImage* pageThumb = nil;
    @autoreleasepool {
        NSString* thumbnailFilename = [NSString stringWithFormat:@"thumb%d.png",(int) pageNumber];
        NSString* thumbnailPath = [[self cachedAssetsPath] stringByAppendingPathComponent:thumbnailFilename];
        if([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath]){
            return [[MMLoadImageCache sharedInstance] imageAtPath:thumbnailPath];
        }
        pageThumb = [self generateImageForPage:pageNumber withMaxDim:100 * [[UIScreen mainScreen] scale]];
        BOOL success = [UIImagePNGRepresentation(pageThumb) writeToFile:thumbnailPath atomically:YES];
        if(!success){
            NSLog(@"failed");
        }
        [[MMLoadImageCache sharedInstance] updateCacheForPath:thumbnailPath toImage:pageThumb];
    }
    return pageThumb;
}

#pragma mark Scaled Image Generation

-(UIImage*) generateImageForPage:(NSUInteger)page withMaxDim:(CGFloat)maxDim{
    UIImage *image;
    @autoreleasepool {
        CGSize sizeOfPage = [self sizeForPage:page];
        page+=1; // pdfs are index 1 at the start!
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
        [self renderIntoContext:cgContext size:sizeOfPage page:page-1];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

-(void)renderIntoContext:(CGContextRef)ctx size:(CGSize)size page:(NSUInteger)page
{
    @autoreleasepool {
        page+=1; // pdfs are index 1 at the start!
        /*
         * Reference: http://www.cocoanetics.com/2010/06/rendering-pdf-is-easier-than-you-thought/
         */
        CGContextGetCTM( ctx );
        CGContextScaleCTM( ctx, 1, -1 );
        CGContextTranslateCTM( ctx, 0, -size.height );
        CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
        
        CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL( (__bridge CFURLRef) pdfResourceURL );
        
        CGPDFPageRef page1 = CGPDFDocumentGetPage( pdf, page );
        
        CGRect mediaRect = CGPDFPageGetBoxRect( page1, kCGPDFCropBox );
        CGContextScaleCTM( ctx, size.width / mediaRect.size.width, size.height / mediaRect.size.height );
        CGContextTranslateCTM( ctx, -mediaRect.origin.x, -mediaRect.origin.y );
        
        CGContextDrawPDFPage( ctx, page1 );
        CGPDFDocumentRelease( pdf );
    }
}

@end
