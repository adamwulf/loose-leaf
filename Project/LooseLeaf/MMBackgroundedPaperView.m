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
#import "UIDevice+PPI.h"
#import "MMPDF.h"
#import "MMImmutableScrapsOnPaperState.h"

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
        
        CGSize backgroundImageSize = paperBackgroundView.image.size;
        CGRect scaledScreen = CGSizeFill(backgroundImageSize, thumbSize);

        [paperBackgroundView.image drawInRect:scaledScreen];

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
    __block NSURL* backgroundAssetURL;
    
    [[NSFileManager defaultManager] enumerateDirectory:[self pagesPath] withBlock:^(NSURL *item, NSUInteger totalItemCount) {
        if([[[item path] lastPathComponent] hasPrefix:@"backgroundTexture.asset"]){
            backgroundAssetURL = item;
        }
    } andErrorHandler:nil];
    
    MMPDF* pdf = nil;
    UIImage* backgroundImage = nil;

    CGSize pxSize = CGSizeScale([[[UIScreen mainScreen] fixedCoordinateSpace] bounds].size, [[UIScreen mainScreen] scale]);
    CGSize inSize = CGSizeScale(pxSize, 1 / [UIDevice ppi]);
    CGSize finalSize = CGSizeScale(inSize, [MMPDF ppi]);
    
    // default the page size to the screen dimensions in PDF ppi.
    CGSize pagePtSize = finalSize;
    CGRect finalExportBounds = CGRectFromSize(pagePtSize);
    CGFloat defaultRotation = 0;
    
    if([[[[backgroundAssetURL path] pathExtension] lowercaseString] isEqualToString:@"pdf"]){
        pdf = [[MMPDF alloc] initWithURL:backgroundAssetURL];
        if([pdf pageCount]){
            pagePtSize = [pdf sizeForPage:0];
            defaultRotation = [pdf rotationForPage:0];
//            CGSize pageInSize = CGSizeScale([pdf sizeForPage:0], 1 / [MMPDF ppi]);
//            
//            NSLog(@"Screen size (pxs): %.2f %.2f", pxSize.width, pxSize.height);
//            NSLog(@"Screen size (in):  %.2f %.2f", inSize.width, inSize.height);
//            NSLog(@"Screen PDF size (pts):  %.2f %.2f", finalSize.width, finalSize.height);
//            NSLog(@"Screen PDF ratio:  %.2f", finalSize.width / finalSize.height);
//            
//            NSLog(@"Background PDF (in):  %.2f %.2f", pageInSize.width, pageInSize.height);
//            NSLog(@"Background PDF size (pts):  %.2f %.2f", pagePtSize.width, pagePtSize.height);
//            NSLog(@"Background PDF ratio:  %.2f", pagePtSize.width / pagePtSize.height);
//            
//            scaledScreen = CGSizeFill(finalSize, pagePtSize);
//            
//            NSLog(@"Fill screen to PDF (pts): %.2f %.2f %.2f %.2f", scaledScreen.origin.x, scaledScreen.origin.y, scaledScreen.size.width, scaledScreen.size.height);
//            
            finalExportBounds = CGSizeFit(finalSize, pagePtSize);
//            
//            NSLog(@"Fit screen to PDF (pts): %.2f %.2f %.2f %.2f", scaledScreen.origin.x, scaledScreen.origin.y, scaledScreen.size.width, scaledScreen.size.height);
        }
    }else if([self backgroundTexturePath]){
        if([[NSFileManager defaultManager] fileExistsAtPath:[self backgroundTexturePath]]){
            backgroundAssetURL = [NSURL fileURLWithPath:[self backgroundTexturePath]];
            backgroundImage = [UIImage imageWithContentsOfFile:[backgroundAssetURL path]];
            if(backgroundImage){
                if(backgroundImage.size.width > backgroundImage.size.height){
                    // rotate
                    backgroundImage = [[UIImage alloc] initWithCGImage:backgroundImage.CGImage scale:backgroundImage.scale orientation:([self isVert:backgroundImage] ? UIImageOrientationLeft : UIImageOrientationUp)];
                }
                CGSize pxSize = CGSizeScale([backgroundImage size], [backgroundImage scale]);
                CGSize inSize = CGSizeScale(pxSize, 1 / [UIDevice ppi]);
                pagePtSize = CGSizeScale(inSize, [MMPDF ppi]);
                finalExportBounds = CGSizeFit(finalSize, pagePtSize);
            }
        }
    }
    
    if([[self.drawableView state] isStateLoaded]){
        [self.drawableView exportToImageOnComplete:^(UIImage * image) {
            NSString* tmpPagePath = [[NSTemporaryDirectory() stringByAppendingString:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"pdf"];
            
            CGRect exportedPageSize = CGRectFromSize(pagePtSize);
            CGContextRef pdfContext = CGPDFContextCreateWithURL((__bridge CFURLRef)([NSURL fileURLWithPath:tmpPagePath]), &exportedPageSize, NULL);
            UIGraphicsPushContext(pdfContext);
            
            CGPDFContextBeginPage(pdfContext, (CFDictionaryRef)@{ @"Rotate" : @(defaultRotation) });
            
            CGContextSaveThenRestoreForBlock(pdfContext, ^{
                // flip
                CGContextSetInterpolationQuality(pdfContext, kCGInterpolationHigh);
                
                CGContextSaveThenRestoreForBlock(pdfContext, ^{
                    CGContextScaleCTM(pdfContext, 1, -1);
                    CGContextTranslateCTM(pdfContext, 0, -pagePtSize.height);
                    
                    if(pdf){
                        // PDF background
                        [pdf renderPage:0 intoContext:pdfContext withSize:pagePtSize];
                    }else if(backgroundImage){
                        // image background
                        CGContextSaveThenRestoreForBlock(pdfContext, ^{
                            [backgroundImage drawInRect:CGRectFromSize(pagePtSize)];
                        });
                    }else{
                        CGContextSetFillColorWithColor(pdfContext, [[UIColor whiteColor] CGColor]);
                        CGContextFillRect(pdfContext, finalExportBounds);
                    }
                });
                
                // Ink
                CGContextDrawImage(pdfContext, finalExportBounds, [image CGImage]);
                
                CGContextSaveThenRestoreForBlock(pdfContext, ^{
                    CGContextScaleCTM(pdfContext, 1, -1);
                    CGContextTranslateCTM(pdfContext, 0, -pagePtSize.height);
                    
                    // Scraps
                    // adjust so that (0,0) is the origin of the content rect in the PDF page,
                    // since the PDF may be much taller/wider than our screen
                    CGContextTranslateCTM(pdfContext, finalExportBounds.origin.x, finalExportBounds.origin.y);
                    MMImmutableScrapsOnPaperState* immutableScrapState = [scrapsOnPaperState immutableStateForPath:nil];
                    
                    for(MMScrapView* scrap in immutableScrapState.scraps){
                        [self drawScrap:scrap intoContext:pdfContext withSize:finalExportBounds.size];
                    }
                    CGContextTranslateCTM(pdfContext, -finalExportBounds.origin.x, -finalExportBounds.origin.y);
                });
            });
            
            CGPDFContextEndPage(pdfContext);
            UIGraphicsPopContext();
            CFRelease(pdfContext);
            
            NSURL* fullyRenderedPDFURL = [NSURL fileURLWithPath:tmpPagePath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completionBlock) completionBlock(fullyRenderedPDFURL);
            });
            
        } withScale:self.drawableView.scale];
        return;
    }
    
    if(completionBlock) completionBlock(nil);
}

// NOTE: this method will always export a portrait image
// of the canvas. Rotation to match the iPad's orientation
// is handled in the MMShareSidebarContainerView
-(void) exportToImage:(void(^)(NSURL* urlToImage))completionBlock{
    __block NSURL* backgroundAssetURL;
    
    [[NSFileManager defaultManager] enumerateDirectory:[self pagesPath] withBlock:^(NSURL *item, NSUInteger totalItemCount) {
        if([[[item path] lastPathComponent] hasPrefix:@"backgroundTexture.asset"]){
            backgroundAssetURL = item;
        }
    } andErrorHandler:nil];
    
    MMPDF* pdf = nil;
    UIImage* backgroundImage = nil;
    
    // default the page size to the screen dimensions in PDF ppi.
    CGSize screenSize = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds].size;
    CGSize pagePtSize = screenSize;
    CGRect finalExportBounds = CGRectFromSize(pagePtSize);
    CGFloat scale = [[UIScreen mainScreen] scale];
    

    if([[[[backgroundAssetURL path] pathExtension] lowercaseString] isEqualToString:@"pdf"]){
        pdf = [[MMPDF alloc] initWithURL:backgroundAssetURL];
        if([pdf pageCount]){
            pagePtSize = [pdf sizeForPage:0];
            //            CGSize pageInSize = CGSizeScale([pdf sizeForPage:0], 1 / [MMPDF ppi]);
            //
            //            NSLog(@"Screen size (pxs): %.2f %.2f", pxSize.width, pxSize.height);
            //            NSLog(@"Screen size (in):  %.2f %.2f", inSize.width, inSize.height);
            //            NSLog(@"Screen PDF size (pts):  %.2f %.2f", finalSize.width, finalSize.height);
            //            NSLog(@"Screen PDF ratio:  %.2f", finalSize.width / finalSize.height);
            //
            //            NSLog(@"Background PDF (in):  %.2f %.2f", pageInSize.width, pageInSize.height);
            //            NSLog(@"Background PDF size (pts):  %.2f %.2f", pagePtSize.width, pagePtSize.height);
            //            NSLog(@"Background PDF ratio:  %.2f", pagePtSize.width / pagePtSize.height);
            //
            //            scaledScreen = CGSizeFill(finalSize, pagePtSize);
            //
            //            NSLog(@"Fill screen to PDF (pts): %.2f %.2f %.2f %.2f", scaledScreen.origin.x, scaledScreen.origin.y, scaledScreen.size.width, scaledScreen.size.height);
            //
            finalExportBounds = CGSizeFill(pagePtSize, screenSize);
            //
            //            NSLog(@"Fit screen to PDF (pts): %.2f %.2f %.2f %.2f", scaledScreen.origin.x, scaledScreen.origin.y, scaledScreen.size.width, scaledScreen.size.height);
        }
    }else if([self backgroundTexturePath]){
        if([[NSFileManager defaultManager] fileExistsAtPath:[self backgroundTexturePath]]){
            backgroundAssetURL = [NSURL fileURLWithPath:[self backgroundTexturePath]];
            backgroundImage = [UIImage imageWithContentsOfFile:[backgroundAssetURL path]];
            if(backgroundImage){
                if(backgroundImage.size.width > backgroundImage.size.height){
                    // rotate
                    backgroundImage = [[UIImage alloc] initWithCGImage:backgroundImage.CGImage scale:backgroundImage.scale orientation:([self isVert:backgroundImage] ? UIImageOrientationLeft : UIImageOrientationUp)];
                }
                finalExportBounds = CGSizeFill([backgroundImage size], finalExportBounds.size);
            }
        }
    }
    
    
    if([[self.drawableView state] isStateLoaded]){
        [self.drawableView exportToImageOnComplete:^(UIImage * image) {
            NSString* tmpPagePath = [[NSTemporaryDirectory() stringByAppendingString:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"png"];
            
            UIGraphicsBeginImageContextWithOptions(finalExportBounds.size, NO, scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGContextSaveThenRestoreForBlock(context, ^{
                // flip
                CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
                
                [[UIColor whiteColor] setFill];
                [[UIBezierPath bezierPathWithRect:finalExportBounds] fill];

                if(pdf){
                    CGContextSaveThenRestoreForBlock(context, ^{
                        // PDF background
                        [pdf renderPage:0 intoContext:context withSize:finalExportBounds.size];
                    });
                }else if(backgroundImage){
                    // image background
                    CGContextSaveThenRestoreForBlock(context, ^{
                        CGRect rectForImage = CGSizeFill([backgroundImage size], finalExportBounds.size);
                        [backgroundImage drawInRect:rectForImage];
                    });
                }
                
                CGContextSaveThenRestoreForBlock(context, ^{
                    // flip context
                    CGContextTranslateCTM(context, 0, finalExportBounds.size.height);
                    CGContextScaleCTM(context, 1, -1);
                    
                    // adjust to origin
                    CGContextTranslateCTM(context, -finalExportBounds.origin.x, -finalExportBounds.origin.y);
                    
                    // Draw Ink
                    CGContextDrawImage(context, CGRectFromSize(screenSize), [image CGImage]);
                });
                
                CGContextSaveThenRestoreForBlock(context, ^{
                    // Scraps
                    // adjust so that (0,0) is the origin of the content rect in the PDF page,
                    // since the PDF may be much taller/wider than our screen
                    CGContextTranslateCTM(context, -finalExportBounds.origin.x, -finalExportBounds.origin.y);
                    MMImmutableScrapsOnPaperState* immutableScrapState = [scrapsOnPaperState immutableStateForPath:nil];
                    
                    for(MMScrapView* scrap in immutableScrapState.scraps){
                        [self drawScrap:scrap intoContext:context withSize:screenSize];
                    }

                });
            });
            
            
            UIImage* outputImage = UIGraphicsGetImageFromCurrentImageContext();
            [UIImagePNGRepresentation(outputImage) writeToFile:tmpPagePath atomically:YES];

            
            UIGraphicsEndImageContext();
            
            NSURL* fullyRenderedImageURL = [NSURL fileURLWithPath:tmpPagePath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completionBlock) completionBlock(fullyRenderedImageURL);
            });
            
        } withScale:self.drawableView.scale];
        return;
    }
    
    if(completionBlock) completionBlock(nil);
}

@end
