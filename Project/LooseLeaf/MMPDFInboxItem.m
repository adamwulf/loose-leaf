//
//  MMPDF.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPDFInboxItem.h"
#import "MMLoadImageCache.h"
#import "Constants.h"
#import "MMInboxItem+Protected.h"

@implementation MMPDFInboxItem{
    NSUInteger pageCount;
    
    BOOL isEncrypted;
    NSString* password;
}

#pragma mark - Init

-(id) initWithURL:(NSURL*)pdfURL{
    if(self = [super initWithURL:pdfURL andInitBlock:^{
        @try {
            // initialize anything that could be affected by
            // race condition generating thumbnails
            // fetch page count
            CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL( (__bridge CFURLRef) self.urlOnDisk );
            
            pageCount = CGPDFDocumentGetNumberOfPages( pdf );
            isEncrypted = CGPDFDocumentIsEncrypted(pdf);
            
            CGPDFDocumentRelease( pdf );
        }
        @catch (NSException *exception) {
            isEncrypted = YES;
        }
    }]){
        // noop
    }
    return self;
}

#pragma mark - Properties

-(BOOL) attemptToDecrypt:(NSString*)_password{
    BOOL success = password != nil;
    if(!password){
        CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL( (__bridge CFURLRef) self.urlOnDisk );
        
        const char *key = [_password UTF8String];
        success = CGPDFDocumentUnlockWithPassword(pdf, key);
        CGPDFDocumentRelease( pdf );
        
        if(success){
            password = _password;
            [self generatePageThumbnailCache];
        }
    }

    return success;
}

-(BOOL) isEncrypted{
    return isEncrypted && !password;
}

#pragma mark - Override

-(NSUInteger) pageCount{
    
    return pageCount;
}

-(CGSize) calculateSizeForPage:(NSUInteger)page{
    // size isn't in the cache, so find out and return it
    // we dont' update the cache ourselves though.
    
    if(page >= pageCount){
        page = pageCount - 1;
    }
    /*
     * Reference: http://www.cocoanetics.com/2010/06/rendering-pdf-is-easier-than-you-thought/
     */
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL( (__bridge CFURLRef) self.urlOnDisk );

    if(password){
        const char *key = [password UTF8String];
        CGPDFDocumentUnlockWithPassword(pdf, key);
    }

    CGPDFPageRef pageref = CGPDFDocumentGetPage( pdf, page + 1 ); // pdfs are index 1 at the start!
    
    CGRect mediaRect = CGPDFPageGetBoxRect( pageref, kCGPDFCropBox );
    
    CGPDFDocumentRelease( pdf );
    return mediaRect.size;
}

#pragma mark - Private

#pragma mark Scaled Image Generation

-(void) generatePageThumbnailCache{
    if(!self.isEncrypted){
        [super generatePageThumbnailCache];
    }
}

-(UIImage*) generateImageForPage:(NSUInteger)page withMaxDim:(CGFloat)maxDim{
    UIImage *image;
    NSLog(@"%@ generating image for page %d with size: %f", [self.urlOnDisk lastPathComponent], (int)page, maxDim);
    @autoreleasepool {
        CGSize sizeOfPage = [self sizeForPage:page];
        if(sizeOfPage.width > maxDim || sizeOfPage.height > maxDim){
            CGFloat maxCurrDim = MAX(sizeOfPage.width, sizeOfPage.height);
            CGFloat ratio = maxDim / maxCurrDim;
            sizeOfPage.width *= ratio;
            sizeOfPage.height *= ratio;
        }
        if(CGSizeEqualToSize(sizeOfPage, CGSizeZero)){
            sizeOfPage = [UIScreen mainScreen].bounds.size;
        }
        
        UIGraphicsBeginImageContextWithOptions(sizeOfPage, NO, 1);
        CGContextRef cgContext = UIGraphicsGetCurrentContext();
        if(!cgContext){
            NSLog(@"no context");
        }
        [[UIColor whiteColor] setFill];
        CGContextFillRect(cgContext, CGRectMake(0, 0, sizeOfPage.width, sizeOfPage.height));
        [self renderIntoContext:cgContext size:sizeOfPage page:page];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

-(void)renderIntoContext:(CGContextRef)ctx size:(CGSize)size page:(NSUInteger)page
{
    @autoreleasepool {
        @try {
            CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL( (__bridge CFURLRef) self.urlOnDisk );

            if(password){
                const char *key = [password UTF8String];
                CGPDFDocumentUnlockWithPassword(pdf, key);
            }
            
            /*
             * Reference: http://www.cocoanetics.com/2010/06/rendering-pdf-is-easier-than-you-thought/
             */
            CGContextGetCTM( ctx );
            CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
            
            CGContextScaleCTM( ctx, 1, -1 );
            CGContextTranslateCTM( ctx, 0, -size.height );
            CGPDFPageRef pageref = CGPDFDocumentGetPage( pdf, page + 1 ); // pdfs are index 1 at the start!
            
            CGRect mediaRect = CGPDFPageGetBoxRect( pageref, kCGPDFCropBox );
            CGContextScaleCTM( ctx, size.width / mediaRect.size.width, size.height / mediaRect.size.height );
            CGContextTranslateCTM( ctx, -mediaRect.origin.x, -mediaRect.origin.y );
            
            CGContextDrawPDFPage( ctx, pageref );
                        
            CGPDFDocumentRelease( pdf );
        }
        @catch (NSException *exception) {
            NSLog(@"error drawing PDF: %@", exception);
        }
    }
}

#pragma mark - Dealloc and Delete

-(BOOL) deleteAssets{
    BOOL ret = [super deleteAssets];

    dispatch_async([MMInboxItem assetQueue], ^{
        // delete cached assets on background queue
        // since there might be a lot of them
        NSError* errorCache = nil;
        [[NSFileManager defaultManager] removeItemAtPath:[self cachedAssetsPath] error:&errorCache];
        
        if(errorCache){
            if(errorCache){
                NSLog(@"delete PDF cache erorr: %@", errorCache);
            }
        }
    });
    
    return ret;
}





@end
