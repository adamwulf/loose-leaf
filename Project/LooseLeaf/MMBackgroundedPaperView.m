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
#import <CoreGraphics/CoreGraphics.h>


@interface MMBackgroundedPaperView () <MMGenericBackgroundViewDelegate>

@property (nonatomic, assign, readonly) BOOL usesCorrectBackgroundRotation;

@end


@implementation MMBackgroundedPaperView {
    UIImageView* paperBackgroundView;
    NSString* backgroundTexturePath;
    BOOL isLoadingBackgroundTexture;
    BOOL wantsBackgroundTextureLoaded;
    
    UILabel* debuglbl;
}

-(instancetype) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        _usesCorrectBackgroundRotation = YES;
    }
    
    return self;
}

-(instancetype) initWithFrame:(CGRect)frame andUUID:(NSString *)_uuid{
    if(self = [super initWithFrame:frame andUUID:_uuid]){
        debuglbl = [[UILabel alloc] initWithFrame:CGRectMake(60, 60, 100, 100)];
        debuglbl.backgroundColor = [UIColor whiteColor];
        debuglbl.textAlignment = NSTextAlignmentCenter;
        [self addSubview:debuglbl];
    }
    return self;
}

- (void)moveAssetsFrom:(id<MMPaperViewDelegate>)previousDelegate {
    [super moveAssetsFrom:previousDelegate];
    backgroundTexturePath = nil;
}

- (BOOL)isVert:(UIImage*)img {
    return img.imageOrientation == UIImageOrientationDown ||
        img.imageOrientation == UIImageOrientationDownMirrored ||
        img.imageOrientation == UIImageOrientationUp ||
        img.imageOrientation == UIImageOrientationUpMirrored;
}

- (UIImage*)pageBackgroundTexture {
    return paperBackgroundView.image;
}

- (void)saveOriginalBackgroundTextureFromURL:(NSURL*)originalAssetURL {
    NSError* error;
    NSString* backgroundAssetPath = [[[self pagesPath] stringByAppendingPathComponent:@"backgroundTexture.asset"] stringByAppendingPathExtension:[originalAssetURL pathExtension]];
    NSURL* toURL = [NSURL fileURLWithPath:backgroundAssetPath];
    [[NSFileManager defaultManager] copyItemAtURL:originalAssetURL toURL:toURL error:&error];

    NSDictionary* bgProps = @{ @"usesCorrectBackgroundRotation" : @([self usesCorrectBackgroundRotation]) };
    [bgProps writeToFile:[self backgroundInfoPlist] atomically:YES];
}

- (void)setPageBackgroundTexture:(UIImage*)img {
    CheckMainThread;
    if (img.size.width > img.size.height) {
        // rotate
        UIImageOrientation rotationForLandscape = UIImageOrientationLeft;
        if([self usesCorrectBackgroundRotation]){
            rotationForLandscape = UIImageOrientationRight;
        }
        img = [[UIImage alloc] initWithCGImage:img.CGImage scale:img.scale orientation:([self isVert:img] ? rotationForLandscape : UIImageOrientationUp)];
    }

    if (!paperBackgroundView) {
        paperBackgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        paperBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        paperBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView insertSubview:paperBackgroundView atIndex:0];
        paperBackgroundView.hidden = self.drawableView.hidden;
    }
    paperBackgroundView.image = img;
}

+ (void)writeBackgroundImageToDisk:(UIImage*)img backgroundTexturePath:(NSString*)backgroundTexturePath {
    @autoreleasepool {
        [UIImagePNGRepresentation(img) writeToFile:backgroundTexturePath atomically:YES];

        [[MMLoadImageCache sharedInstance] clearCacheForPath:backgroundTexturePath];
    }
}

+ (void)writeThumbnailImagesToDisk:(UIImage*)img thumbnailPath:(NSString*)thumbnailPath scrappedThumbnailPath:(NSString*)scrappedThumbnailPath {
    @autoreleasepool {
        NSData* imgData = UIImagePNGRepresentation(img);
        [imgData writeToFile:thumbnailPath atomically:YES];
        [imgData writeToFile:scrappedThumbnailPath atomically:YES];
        [[MMLoadImageCache sharedInstance] clearCacheForPath:thumbnailPath];
        [[MMLoadImageCache sharedInstance] clearCacheForPath:scrappedThumbnailPath];
    }
}

- (void)updateThumbnailVisibility:(BOOL)forceUpdateIconImage {
    [super updateThumbnailVisibility:forceUpdateIconImage];
    paperBackgroundView.hidden = self.drawableView.hidden;
}

#pragma mark - Loading and Unloading State

-(NSString*)backgroundInfoPlist{
    return [[self pagesPath] stringByAppendingPathComponent:@"bg.plist"];
}

- (void)loadStateAsynchronously:(BOOL)async withSize:(CGSize)pagePtSize andScale:(CGFloat)scale andContext:(JotGLContext*)context {
    [super loadStateAsynchronously:async withSize:pagePtSize andScale:scale andContext:context];
    
    wantsBackgroundTextureLoaded = YES;

    if (isLoadingBackgroundTexture) {
        return;
    }
    isLoadingBackgroundTexture = YES;

    void (^loadPageBackgroundFromDisk)() = ^{
        NSDictionary* bgInfo = [NSDictionary dictionaryWithContentsOfFile:[self backgroundInfoPlist]];
        
        _usesCorrectBackgroundRotation = [bgInfo[@"usesCorrectBackgroundRotation"] boolValue];
        
        if (![self pageBackgroundTexture]) {
            UIImage* img = [UIImage imageWithContentsOfFile:[self backgroundTexturePath]];
            if (img) {
                [[NSThread mainThread] performBlock:^{
                    if (wantsBackgroundTextureLoaded) {
                        [self setPageBackgroundTexture:img];
                    };
                    isLoadingBackgroundTexture = NO;
                }];
            } else {
                __block NSURL* backgroundAssetURL;

                [[NSFileManager defaultManager] enumerateDirectory:[self pagesPath] withBlock:^(NSURL* item, NSUInteger totalItemCount) {
                    if ([[[item path] lastPathComponent] hasPrefix:@"backgroundTexture.asset"]) {
                        backgroundAssetURL = item;
                    }
                } andErrorHandler:nil];

                if (backgroundAssetURL && [[backgroundAssetURL path] hasSuffix:@"pdf"]) {
                    CGFloat maxDim = kPDFImportMaxDim * [[UIScreen mainScreen] scale];
                    MMPDF* pdf = [[MMPDF alloc] initWithURL:backgroundAssetURL];
                    UIImage* img = [pdf imageForPage:0 withMaxDim:maxDim];
                    [[NSThread mainThread] performBlock:^{
                        if (wantsBackgroundTextureLoaded) {
                            [self setPageBackgroundTexture:img];
                        };
                        isLoadingBackgroundTexture = NO;
                    }];
                    [MMBackgroundedPaperView writeBackgroundImageToDisk:img backgroundTexturePath:[self backgroundTexturePath]];
                } else {
                    isLoadingBackgroundTexture = NO;
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                debuglbl.text = [self usesCorrectBackgroundRotation] ? @"YES" : @"NO";
            });
        } else {
            isLoadingBackgroundTexture = NO;
        }
    };

    if (async) {
        dispatch_async([MMEditablePaperView importThumbnailQueue], loadPageBackgroundFromDisk);
    } else {
        // we're already on the correct thread, so just run it now
        loadPageBackgroundFromDisk();
    }
}

- (void)unloadState {
    [super unloadState];
    paperBackgroundView.image = nil;
    [paperBackgroundView removeFromSuperview];
    paperBackgroundView = nil;
    wantsBackgroundTextureLoaded = NO;
}

- (void)unloadCachedPreview {
    [super unloadCachedPreview];
    paperBackgroundView.image = nil;
    [paperBackgroundView removeFromSuperview];
    paperBackgroundView = nil;
}

#pragma mark - Thumbnail Generation

- (void)drawPageBackgroundInContext:(CGContextRef)context forThumbnailSize:(CGSize)thumbSize {
    [super drawPageBackgroundInContext:context forThumbnailSize:thumbSize];
    if (paperBackgroundView) {
        UIGraphicsPushContext(context);

        CGSize backgroundImageSize = paperBackgroundView.image.size;
        CGRect scaledScreen = CGSizeFill(backgroundImageSize, thumbSize);

        [paperBackgroundView.image drawInRect:scaledScreen];

        UIGraphicsPopContext();
    }
}

#pragma mark - Paths

- (NSString*)backgroundTexturePath {
    if (!backgroundTexturePath) {
        backgroundTexturePath = [[[self pagesPath] stringByAppendingPathComponent:@"backgroundTexture"] stringByAppendingPathExtension:@"png"];
    }
    return backgroundTexturePath;
}


#pragma mark - Protected Methods

- (void)newlyCutScrapFromPaperView:(MMScrapView*)addedScrap {
    if (self.pageBackgroundTexture) {
        MMGenericBackgroundView* pageBackground = [[MMGenericBackgroundView alloc] initWithImage:self.pageBackgroundTexture andDelegate:self];
        pageBackground.bounds = self.bounds;
        [pageBackground aspectFillBackgroundImageIntoView];

        [addedScrap setBackgroundView:[pageBackground stampBackgroundFor:[addedScrap state]]];
    }
}

#pragma mark - MMGenericBackgroundViewDelegate

- (UIView*)contextViewForGenericBackground:(MMGenericBackgroundView*)backgroundView {
    return self.superview;
}

- (CGFloat)contextRotationForGenericBackground:(MMGenericBackgroundView*)backgroundView {
    return 0;
}

- (CGPoint)currentCenterOfBackgroundForGenericBackground:(MMGenericBackgroundView*)backgroundView {
    return CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

#pragma mark - Export to PDF

- (void)exportVisiblePageToPDF:(void (^)(NSURL* urlToPDF))completionBlock {
    __block NSURL* backgroundAssetURL;
    
    [[NSFileManager defaultManager] enumerateDirectory:[self pagesPath] withBlock:^(NSURL* item, NSUInteger totalItemCount) {
        if ([[[item path] lastPathComponent] hasPrefix:@"backgroundTexture.asset"]) {
            backgroundAssetURL = item;
        }
    } andErrorHandler:nil];
    
    MMPDF* pdf = nil;
    UIImage* backgroundImage = nil;
    
    // default the page size to the screen dimensions in PDF ppi.
    CGSize screenSize = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds].size;
    CGSize pagePtSize = screenSize;
    __block CGRect finalExportBounds = CGRectFromSize(pagePtSize);
    CGSize backgroundSize = CGSizeZero;
    CGFloat defaultRotation = 0;
    
    if ([[[[backgroundAssetURL path] pathExtension] lowercaseString] isEqualToString:@"pdf"]) {
        pdf = [[MMPDF alloc] initWithURL:backgroundAssetURL];
        if ([pdf pageCount]) {
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
            
            backgroundSize = pagePtSize;
            
            if(backgroundSize.height > backgroundSize.width){
                finalExportBounds = CGSizeFill(pagePtSize, screenSize);
            }else{
                finalExportBounds = CGSizeFill(pagePtSize, CGSizeSwap(screenSize));
            }
            //
            //            NSLog(@"Fit screen to PDF (pts): %.2f %.2f %.2f %.2f", scaledScreen.origin.x, scaledScreen.origin.y, scaledScreen.size.width, scaledScreen.size.height);
        }
    } else if ([self backgroundTexturePath]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self backgroundTexturePath]]) {
            backgroundAssetURL = [NSURL fileURLWithPath:[self backgroundTexturePath]];
            backgroundImage = [UIImage imageWithContentsOfFile:[backgroundAssetURL path]];
            if (backgroundImage) {
                if (backgroundImage.size.width > backgroundImage.size.height) {
                    // rotate
                    UIImageOrientation rotationForLandscape = UIImageOrientationLeft;
                    if([self usesCorrectBackgroundRotation]){
                        rotationForLandscape = UIImageOrientationRight;
                    }
                    
                    backgroundImage = [[UIImage alloc] initWithCGImage:backgroundImage.CGImage scale:backgroundImage.scale orientation:([self isVert:backgroundImage] ? rotationForLandscape : UIImageOrientationUp)];
                }
                
                backgroundSize = [backgroundImage size];
                
                finalExportBounds = CGSizeFill([backgroundImage size], finalExportBounds.size);
            }
        }
    }
    
    if ([[self.drawableView state] isStateLoaded]) {
        MMImmutableScrapsOnPaperState* immutableScrapState = [scrapsOnPaperState immutableStateForPath:nil];
        [self.drawableView exportToImageOnComplete:^(UIImage* image) {
            NSString* tmpPagePath = [[NSTemporaryDirectory() stringByAppendingString:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"pdf"];
            __block CGPDFDocumentRef pdfDocRef = NULL;

            CGRect exportedPageSize = CGRectFromSize(finalExportBounds.size);
            CGContextRef context = CGPDFContextCreateWithURL((__bridge CFURLRef)([NSURL fileURLWithPath:tmpPagePath]), &exportedPageSize, NULL);
            UIGraphicsPushContext(context);
            
            CFDataRef boxData = CFDataCreate(NULL, (const UInt8*)&exportedPageSize, sizeof(CGRect));
            
            CGPDFContextBeginPage(context, (CFDictionaryRef) @{ @"Rotate": @(defaultRotation),
                                                                   (NSString*)kCGPDFContextMediaBox: (__bridge NSData*)boxData });
            
            CGContextSaveThenRestoreForBlock(context, ^{
                // flip
                CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
                
                [[UIColor whiteColor] setFill];
                [[UIBezierPath bezierPathWithRect:finalExportBounds] fill];
                
                CGContextSaveThenRestoreForBlock(context, ^{
                    CGContextScaleCTM(context, 1, -1);
                    CGContextTranslateCTM(context, 0, -finalExportBounds.size.height);
                    
                    if (pdf) {
                        CGContextSaveThenRestoreForBlock(context, ^{
                            // PDF background
                            pdfDocRef = [pdf openPDF];
                            [pdf renderPage:0 intoContext:context withSize:finalExportBounds.size withPDFRef:pdfDocRef];
                        });
                    } else if (backgroundImage) {
                        // image background
                        CGContextSaveThenRestoreForBlock(context, ^{
                            CGRect rectForImage = CGSizeFill(backgroundSize, finalExportBounds.size);
                            [backgroundImage drawInRect:rectForImage];
                        });
                    }
                    
                    if(pdf && backgroundSize.width > backgroundSize.height){
                        // if the PDF is landscape, then we need to rotate our
                        // canvas so that the landscape PDF is drawn on our
                        // vertical canvas properly.
                        CGFloat theta = 90.0 * M_PI / 180.0;
                        if([self usesCorrectBackgroundRotation]){
                            theta = -theta;
                        }
                        
                        CGContextTranslateCTM(context, finalExportBounds.size.width / 2, finalExportBounds.size.height / 2);
                        CGContextRotateCTM(context, theta);
                        CGContextTranslateCTM(context, -finalExportBounds.size.height / 2, -finalExportBounds.size.width / 2);
                        
                        finalExportBounds.size = CGSizeSwap(finalExportBounds.size);
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
                        
                        for (MMScrapView* scrap in immutableScrapState.scraps) {
                            [self drawScrap:scrap intoContext:context withSize:screenSize];
                        }
                        
                    });
                });
            });
            
            UIImage* outputImage = UIGraphicsGetImageFromCurrentImageContext();
            [UIImagePNGRepresentation(outputImage) writeToFile:tmpPagePath atomically:YES];
            
            CGPDFContextEndPage(context);
            CGPDFContextClose(context);
            UIGraphicsPopContext();
            CFRelease(context);
            CFRelease(boxData);
            
            CGPDFDocumentRelease(pdfDocRef);
            
            NSURL* fullyRenderedPDFURL = [NSURL fileURLWithPath:tmpPagePath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock)
                    completionBlock(fullyRenderedPDFURL);
            });
            
        } withScale:self.drawableView.scale];
        return;
    }
    
    if (completionBlock)
        completionBlock(nil);
}

// NOTE: this method will always export a portrait image
// of the canvas. Rotation to match the iPad's orientation
// is handled in the MMShareSidebarContainerView
- (void)exportVisiblePageToImage:(void (^)(NSURL* urlToImage))completionBlock {
    __block NSURL* backgroundAssetURL;

    [[NSFileManager defaultManager] enumerateDirectory:[self pagesPath] withBlock:^(NSURL* item, NSUInteger totalItemCount) {
        if ([[[item path] lastPathComponent] hasPrefix:@"backgroundTexture.asset"]) {
            backgroundAssetURL = item;
        }
    } andErrorHandler:nil];

    MMPDF* pdf = nil;
    UIImage* backgroundImage = nil;

    // default the page size to the screen dimensions in PDF ppi.
    CGSize screenSize = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds].size;
    CGSize pagePtSize = screenSize;
    __block CGRect finalExportBounds = CGRectFromSize(pagePtSize);
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize backgroundSize = CGSizeZero;


    if ([[[[backgroundAssetURL path] pathExtension] lowercaseString] isEqualToString:@"pdf"]) {
        pdf = [[MMPDF alloc] initWithURL:backgroundAssetURL];
        if ([pdf pageCount]) {
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
            
            backgroundSize = pagePtSize;
            
            if(backgroundSize.height > backgroundSize.width){
                finalExportBounds = CGSizeFill(pagePtSize, screenSize);
            }else{
                finalExportBounds = CGSizeFill(pagePtSize, CGSizeSwap(screenSize));
            }
            //
            //            NSLog(@"Fit screen to PDF (pts): %.2f %.2f %.2f %.2f", scaledScreen.origin.x, scaledScreen.origin.y, scaledScreen.size.width, scaledScreen.size.height);
        }
    } else if ([self backgroundTexturePath]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self backgroundTexturePath]]) {
            backgroundAssetURL = [NSURL fileURLWithPath:[self backgroundTexturePath]];
            backgroundImage = [UIImage imageWithContentsOfFile:[backgroundAssetURL path]];
            if (backgroundImage) {
                if (backgroundImage.size.width > backgroundImage.size.height) {
                    // rotate
                    UIImageOrientation rotationForLandscape = UIImageOrientationLeft;
                    if([self usesCorrectBackgroundRotation]){
                        rotationForLandscape = UIImageOrientationRight;
                    }
                    
                    backgroundImage = [[UIImage alloc] initWithCGImage:backgroundImage.CGImage scale:backgroundImage.scale orientation:([self isVert:backgroundImage] ? rotationForLandscape : UIImageOrientationUp)];
                }

                backgroundSize = [backgroundImage size];
                
                finalExportBounds = CGSizeFill([backgroundImage size], finalExportBounds.size);
            }
        }
    }


    if ([[self.drawableView state] isStateLoaded]) {
        MMImmutableScrapsOnPaperState* immutableScrapState = [scrapsOnPaperState immutableStateForPath:nil];
        [self.drawableView exportToImageOnComplete:^(UIImage* image) {
            NSString* tmpPagePath = [[NSTemporaryDirectory() stringByAppendingString:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"png"];

            __block CGPDFDocumentRef pdfDocRef = NULL;
            UIGraphicsBeginImageContextWithOptions(finalExportBounds.size, NO, scale);
            CGContextRef context = UIGraphicsGetCurrentContext();

            CGContextSaveThenRestoreForBlock(context, ^{
                // flip
                CGContextSetInterpolationQuality(context, kCGInterpolationHigh);

                [[UIColor whiteColor] setFill];
                [[UIBezierPath bezierPathWithRect:finalExportBounds] fill];
                
                if (pdf) {
                    CGContextSaveThenRestoreForBlock(context, ^{
                        // PDF background
                        pdfDocRef = [pdf openPDF];
                        [pdf renderPage:0 intoContext:context withSize:finalExportBounds.size withPDFRef:pdfDocRef];
                    });
                } else if (backgroundImage) {
                    // image background
                    CGContextSaveThenRestoreForBlock(context, ^{
                        CGRect rectForImage = CGSizeFill(backgroundSize, finalExportBounds.size);
                        [backgroundImage drawInRect:rectForImage];
                    });
                }
                
                if(pdf && backgroundSize.width > backgroundSize.height){
                    // if the PDF is landscape, then we need to rotate our
                    // canvas so that the landscape PDF is drawn on our
                    // vertical canvas properly.
                    CGFloat theta = 90.0 * M_PI / 180.0;
                    if([self usesCorrectBackgroundRotation]){
                        theta = -theta;
                    }
                    
                    CGContextTranslateCTM(context, finalExportBounds.size.width / 2, finalExportBounds.size.height / 2);
                    CGContextRotateCTM(context, theta);
                    CGContextTranslateCTM(context, -finalExportBounds.size.height / 2, -finalExportBounds.size.width / 2);
                    
                    finalExportBounds.size = CGSizeSwap(finalExportBounds.size);
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

                    for (MMScrapView* scrap in immutableScrapState.scraps) {
                        [self drawScrap:scrap intoContext:context withSize:screenSize];
                    }

                });
            });

            UIImage* outputImage = UIGraphicsGetImageFromCurrentImageContext();
            [UIImagePNGRepresentation(outputImage) writeToFile:tmpPagePath atomically:YES];

            UIGraphicsEndImageContext();

            CGPDFDocumentRelease(pdfDocRef);

            NSURL* fullyRenderedImageURL = [NSURL fileURLWithPath:tmpPagePath];

            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock)
                    completionBlock(fullyRenderedImageURL);
            });

        } withScale:self.drawableView.scale];
        return;
    }

    if (completionBlock)
        completionBlock(nil);
}

@end
