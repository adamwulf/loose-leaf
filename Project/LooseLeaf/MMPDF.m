//
//  MMPDF.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/9/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMPDF.h"

@implementation MMPDF{
    NSUInteger pageCount;
    
    BOOL isEncrypted;
    NSString* password;
}

@synthesize urlOnDisk;

-(instancetype) initWithURL:(NSURL*)url{
    if(self = [super init]){
        urlOnDisk = url;
        
        CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL( (__bridge CFURLRef) self.urlOnDisk );
        
        pageCount = CGPDFDocumentGetNumberOfPages( pdf );
        isEncrypted = CGPDFDocumentIsEncrypted(pdf);
        
        CGPDFDocumentRelease( pdf );
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
        }
    }
    
    return success;
}

-(BOOL) isEncrypted{
    return isEncrypted && !password;
}

-(NSUInteger) pageCount{
    
    return pageCount;
}

-(CGSize) sizeForPage:(NSUInteger)page{
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

#pragma mark - Rendering

-(UIImage*) imageForPage:(NSUInteger)page withMaxDim:(CGFloat)maxDim{
    UIImage *image;
    @autoreleasepool {
        CGSize sizeOfPage = [self sizeForPage:page];

        CGFloat maxCurrDim = MAX(sizeOfPage.width, sizeOfPage.height);
        CGFloat ratio = maxDim / maxCurrDim;
        sizeOfPage.width *= ratio;
        sizeOfPage.height *= ratio;

        if(CGSizeEqualToSize(sizeOfPage, CGSizeZero)){
            sizeOfPage = [UIScreen mainScreen].bounds.size;
        }
        
        UIGraphicsBeginImageContextWithOptions(sizeOfPage, NO, 0);
        CGContextRef cgContext = UIGraphicsGetCurrentContext();
        if(!cgContext){
            NSLog(@"no context");
        }
        [[UIColor whiteColor] setFill];
        CGContextFillRect(cgContext, CGRectMake(0, 0, sizeOfPage.width, sizeOfPage.height));
        [self renderPage:page intoContext:cgContext withSize:sizeOfPage];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return image;
}

-(void)renderPage:(NSUInteger)page intoContext:(CGContextRef)ctx withSize:(CGSize)size
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


@end
