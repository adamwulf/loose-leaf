//
//  MMBackgroundedPaperView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 2/25/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMBackgroundedPaperView.h"
#import "MMEditablePaperViewSubclass.h"
#import "NSThread+BlockAdditions.h"
#import "MMLoadImageCache.h"
#import "MMScrapBackgroundView.h"
#import "NSFileManager+DirectoryOptimizations.h"
#import "Constants.h"

@interface MMBackgroundedPaperView ()<MMGenericBackgroundViewDelegate>

@end

@implementation MMBackgroundedPaperView{
    UIImageView* paperBackgroundView;
    NSString* backgroundTexturePath;
    BOOL isLoadingBackgroundTexture;
    BOOL wantsBackgroundTextureLoaded;
}

-(BOOL) isVert:(UIImage*)img{
    return img.imageOrientation == UIImageOrientationDown ||
    img.imageOrientation == UIImageOrientationDownMirrored ||
    img.imageOrientation == UIImageOrientationUp ||
    img.imageOrientation == UIImageOrientationUpMirrored;
    
}

-(UIImage*) pageBackgroundTexture{
    return paperBackgroundView.image;
}

-(void) saveOriginalBackgroundTextureFromURL:(NSURL*)originalAssetURL{
    NSError* error;
    NSString* backgroundAssetPath = [[[self pagesPath] stringByAppendingPathComponent:@"backgroundTexture.asset"] stringByAppendingPathExtension:[originalAssetURL pathExtension]];
    NSURL* toURL = [NSURL fileURLWithPath:backgroundAssetPath];
    [[NSFileManager defaultManager] copyItemAtURL:originalAssetURL toURL:toURL error:&error];
}

-(void) setPageBackgroundTexture:(UIImage*)img{
    [self setPageBackgroundTexture:img andSaveToDisk:YES];
}

-(void) setPageBackgroundTexture:(UIImage*)img andSaveToDisk:(BOOL)saveToDisk{
    CheckMainThread;
    if(img.size.width > img.size.height){
        // rotate
        img = [[UIImage alloc] initWithCGImage:img.CGImage scale:img.scale orientation:([self isVert:img] ? UIImageOrientationLeft : UIImageOrientationUp)];
    }

    if(!paperBackgroundView){
        paperBackgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        paperBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        paperBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView insertSubview:paperBackgroundView atIndex:0];
        paperBackgroundView.hidden = self.drawableView.hidden;
    }
    paperBackgroundView.image = img;

    BOOL wasBrandNewPage = self.isBrandNewPage;
    if(self.isBrandNewPage){
        CGSize thumbSize = self.bounds.size;
        thumbSize.width = floorf(thumbSize.width / 2);
        thumbSize.height = floorf(thumbSize.height / 2);
        UIImage* thumbImage = [img resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:thumbSize interpolationQuality:kCGInterpolationMedium];

        [UIImagePNGRepresentation(thumbImage) writeToFile:[self thumbnailPath] atomically:YES];
        [UIImagePNGRepresentation(thumbImage) writeToFile:[self scrappedThumbnailPath] atomically:YES];
        [[MMLoadImageCache sharedInstance] clearCacheForPath:[self thumbnailPath]];
        [[MMLoadImageCache sharedInstance] clearCacheForPath:[self scrappedThumbnailPath]];
        
    }
    if(saveToDisk){
        dispatch_async([MMEditablePaperView importThumbnailQueue], ^{
            [UIImagePNGRepresentation(img) writeToFile:[self backgroundTexturePath] atomically:YES];
            if(wasBrandNewPage){
                dispatch_async(dispatch_get_main_queue(), ^{
                    definitelyDoesNotHaveAnInkThumbnail = NO;
                    definitelyDoesNotHaveAScrappedThumbnail = NO;
                    fileExistsAtInkPath = NO;
                    cachedImgViewImage = nil;
                    [self loadCachedPreviewAndDecompressImmediately:YES];
                });
            }
        });
    }
}

-(void) updateThumbnailVisibility:(BOOL)forceUpdateIconImage{
    [super updateThumbnailVisibility:forceUpdateIconImage];
    paperBackgroundView.hidden = self.drawableView.hidden;
}

#pragma mark - Loading and Unloading State

-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize)pagePtSize andScale:(CGFloat)scale andContext:(JotGLContext *)context{
    [super loadStateAsynchronously:async withSize:pagePtSize andScale:scale andContext:context];
    
    if(isLoadingBackgroundTexture){
        return;
    }
    isLoadingBackgroundTexture = YES;
    wantsBackgroundTextureLoaded = YES;

    void (^loadPageBackgroundFromDisk)() = ^{
        if(![self pageBackgroundTexture]){
            UIImage* img = [UIImage imageWithContentsOfFile:[self backgroundTexturePath]];
            if(img){
                [[NSThread mainThread] performBlock:^{
                    if(wantsBackgroundTextureLoaded){
                        NSLog(@"image loaded");
                        [self setPageBackgroundTexture:img andSaveToDisk:NO];
                        isLoadingBackgroundTexture = NO;
                    };
                }];
            }else{
                isLoadingBackgroundTexture = NO;
            }
        }else{
            isLoadingBackgroundTexture = NO;
        }
    };
    
    if(async){
        dispatch_async([MMEditablePaperView importThumbnailQueue], loadPageBackgroundFromDisk);
    }else{
        // we're already on the correct thread, so just run it now
        loadPageBackgroundFromDisk();
    }

}

-(void) unloadState{
    [super unloadState];
    paperBackgroundView.image = nil;
    [paperBackgroundView removeFromSuperview];
    paperBackgroundView = nil;
    wantsBackgroundTextureLoaded = NO;
}

#pragma mark - Thumbnail Generation

-(void) drawPageBackgroundInContext:(CGContextRef)context forThumbnailSize:(CGSize)thumbSize{
    [super drawPageBackgroundInContext:context forThumbnailSize:thumbSize];
    if(paperBackgroundView){
        UIGraphicsPushContext(context);
        [paperBackgroundView.image drawInRect:CGRectMake(0, 0, thumbSize.width, thumbSize.height)];
//        CGContextDrawImage(context, CGRectMake(0, 0, thumbSize.width, thumbSize.height), paperBackgroundView.image.CGImage);
        UIGraphicsPopContext();
    }
}

#pragma mark - Paths

-(NSString*) backgroundTexturePath{
    if(!backgroundTexturePath){
        backgroundTexturePath = [[[self pagesPath] stringByAppendingPathComponent:@"backgroundTexture"] stringByAppendingPathExtension:@"png"];
    }
    return backgroundTexturePath;
}


#pragma mark - Protected Methods

-(void) newlyCutScrapFromPaperView:(MMScrapView*)addedScrap{
    if(self.pageBackgroundTexture){
        MMGenericBackgroundView* pageBackground = [[MMGenericBackgroundView alloc] initWithImage:self.pageBackgroundTexture andDelegate:self];
        pageBackground.bounds = self.bounds;
        [pageBackground aspectFillBackgroundImageIntoView];
        
        [addedScrap setBackgroundView:[pageBackground stampBackgroundFor:[addedScrap state]]];
    }
}

#pragma mark - MMGenericBackgroundViewDelegate

-(UIView*) contextViewForGenericBackground:(MMGenericBackgroundView*)backgroundView{
    return self.superview;
}

-(CGFloat) contextRotationForGenericBackground:(MMGenericBackgroundView*)backgroundView{
    return 0;
}

-(CGPoint) currentCenterOfBackgroundForGenericBackground:(MMGenericBackgroundView*)backgroundView{
    return CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}


#pragma mark - Export to PDF

-(void) exportToPDF:(void(^)(NSURL* urlToPDF))completionBlock{

    CGRect pageBounds = CGRectFromSize([[self drawableView] pagePtSize]);
    __block NSURL* backgroundAsset;
    
    [[NSFileManager defaultManager] enumerateDirectory:[self pagesPath] withBlock:^(NSURL *item, NSUInteger totalItemCount) {
        if([[[item path] lastPathComponent] hasPrefix:@"backgroundTexture.asset"]){
            backgroundAsset = item;
        }
    } andErrorHandler:nil];

    NSLog(@"found background asset: %@", backgroundAsset);
    
    
    if(completionBlock) completionBlock(backgroundAsset);
    
    
//
//    NSString* backgroundAssetPath = [[[self pagesPath] stringByAppendingPathComponent:@"backgroundTexture.asset"] stringByAppendingPathExtension:@"pdf"];
//
//    
//    CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, (CFStringRef)textView.text, NULL);
//    if (currentText) {
//        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
//        if (framesetter) {
//            
//            NSString *pdfFileName = [self getPDFFileName];
//            // Create the PDF context using the default page size of 612 x 792.
//            UIGraphicsBeginPDFContextToFile(pdfFileName, CGRectZero, nil);
//            
//            CFRange currentRange = CFRangeMake(0, 0);
//            NSInteger currentPage = 0;
//            BOOL done = NO;
//            
//            do {
//                // Mark the beginning of a new page.
//                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
//                
//                // Draw a page number at the bottom of each page.
//                currentPage++;
//                [self drawPageNumber:currentPage];
//                
//                // Render the current page and update the current range to
//                // point to the beginning of the next page.
//                currentRange = [self renderPageWithTextRange:currentRange andFramesetter:framesetter];
//                
//                // If we're at the end of the text, exit the loop.
//                if (currentRange.location == CFAttributedStringGetLength((CFAttributedStringRef)currentText))
//                    done = YES;
//            } while (!done);
//            
//            // Close the PDF context and write the contents out.
//            UIGraphicsEndPDFContext();
//            
//            // Release the framewetter.
//            CFRelease(framesetter);
//            
//        } else {
//            NSLog(@"Could not create the framesetter needed to lay out the atrributed string.");
//        }
//        // Release the attributed string.
//        CFRelease(currentText);
//    } else {
//        NSLog(@"Could not create the attributed string for the framesetter");
//    }
    
}

@end
