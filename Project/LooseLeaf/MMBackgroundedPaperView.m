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
#import "MMRuledBackgroundView.h"
#import <CoreGraphics/CoreGraphics.h>
#import "UIView+MPHelpers.h"


@interface MMBackgroundedPaperView () <MMGenericBackgroundViewDelegate>

@property (nonatomic, assign, readonly) BOOL usesCorrectBackgroundRotation;

@end


@implementation MMBackgroundedPaperView {
    UIImageView* paperBackgroundView;
    NSString* backgroundTexturePath;
    BOOL isLoadingBackgroundTexture;
    BOOL wantsBackgroundTextureLoaded;
    
    ExportRotation _defaultExportRotation;
    
    MMRuledBackgroundView* _ruledOrGridBackgroundView;
}

@synthesize idealExportRotation = _idealExportRotation;

-(instancetype) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        _usesCorrectBackgroundRotation = YES;
        _ruledOrGridBackgroundView = [[MMRuledBackgroundView alloc] initWithFrame:[self bounds] andProperties:@{}];
        [self.contentView insertSubview:_ruledOrGridBackgroundView atIndex:0];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _ruledOrGridBackgroundView.transform = CGAffineTransformMakeScale(self.scale, self.scale);
}

-(void) setDelegate:(NSObject<MMScrapViewOwnershipDelegate,MMPaperViewDelegate> *)_delegate{
    [super setDelegate:_delegate];
    
    if(_usesCorrectBackgroundRotation){
        // if we're here, then we're setting the delegate
        // immediately after initWithFrame above.
        // otherwise we initialized with a uuid etc,
        // and _usesCorrectBackgroundRotation would be NO.
        // we only want to save properties for new pages
        // that have _usesCorrectBackgroundRotation = YES
        [self saveAdditionalBackgroundProperties:YES];
    }
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

    [self saveAdditionalBackgroundProperties:NO];
}

-(void) saveAdditionalBackgroundProperties:(BOOL)forceSave{
    if(forceSave || ([self isStateLoaded] && !isLoadingBackgroundTexture)){
        NSDictionary* backgroundClassName = _ruledOrGridBackgroundView ? [_ruledOrGridBackgroundView properties] : @{};
        
        NSDictionary* bgProps = @{ @"usesCorrectBackgroundRotation" : @([self usesCorrectBackgroundRotation]),
                                   @"idealExportRotation" : @(_idealExportRotation),
                                   @"defaultExportRotation" : @(_defaultExportRotation),
                                   @"ruledOrGridBackgroundProps" : backgroundClassName};
        [bgProps writeToFile:[self backgroundInfoPlist] atomically:YES];
        
        if(_ruledOrGridBackgroundView){
            [_ruledOrGridBackgroundView saveDefaultThumbToPath:[self scrappedThumbnailPath] forSize:[self thumbnailSize]];
        }
    }
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
    if(isLoadingBackgroundTexture){
        // if we're still loading our background image, then
        // keep the thumbnail visible, otherwise defer to
        // our superclass.
        [self setThumbnailTo:[self scrappedImgViewImage]];
        scrapsOnPaperState.scrapContainerView.hidden = YES;
        drawableView.hidden = YES;
        shapeBuilderView.hidden = YES;
        cachedImgView.hidden = NO;
        [self isShowingDrawableView:NO andIsShowingThumbnail:YES];
    }else{
        [super updateThumbnailVisibility:forceUpdateIconImage];
        paperBackgroundView.hidden = self.drawableView.hidden;
    }
}

#pragma mark - Properties

-(NSURL*)backgroundAssetURL{
    __block NSURL* backgroundAssetURL;
    
    [[NSFileManager defaultManager] enumerateDirectory:[self pagesPath] withBlock:^(NSURL* item, NSUInteger totalItemCount) {
        if ([[[item path] lastPathComponent] hasPrefix:@"backgroundTexture.asset"]) {
            backgroundAssetURL = item;
        }
    } andErrorHandler:nil];
    
    return backgroundAssetURL;
}

-(void) setIdealExportRotation:(ExportRotation)idealExportRotation{
    if(_idealExportRotation != idealExportRotation){
        _idealExportRotation = idealExportRotation;
        
        [self saveAdditionalBackgroundProperties:NO];
    }
}

-(void) setDefaultRotationForBackgroundSize:(CGSize)backgroundSize{
    if(backgroundSize.width > backgroundSize.height){
        // if the background is landscape, then we need to rotate our
        // canvas so that the landscape PDF is drawn on our
        // vertical canvas properly.
        _defaultExportRotation = ExportRotationLandscapeRight;
        if([self usesCorrectBackgroundRotation]){
            _defaultExportRotation = ExportRotationLandscapeLeft;
        }
    }
}

-(ExportRotation) idealExportRotation{
    if(_defaultExportRotation == ExportRotationBackgroundDefault){
        // haven't calculated our default yet
        _defaultExportRotation = ExportRotationPortrait;
        
        NSURL* backgroundAssetURL = [self backgroundAssetURL];
        CGSize backgroundSize = CGSizeZero;
        
        @autoreleasepool {
            if ([[[[backgroundAssetURL path] pathExtension] lowercaseString] isEqualToString:@"pdf"]) {
                MMPDF* pdf = [[MMPDF alloc] initWithURL:backgroundAssetURL];
                if ([pdf pageCount]) {
                    backgroundSize = [pdf sizeForPage:0];
                }
            } else if ([self backgroundTexturePath]) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:[self backgroundTexturePath]]) {
                    backgroundAssetURL = [NSURL fileURLWithPath:[self backgroundTexturePath]];
                    UIImage* backgroundImage = [UIImage imageWithContentsOfFile:[backgroundAssetURL path]];
                    if (backgroundImage) {
                        backgroundSize = [backgroundImage size];
                    }
                }
            }
        }
        
        [self setDefaultRotationForBackgroundSize:backgroundSize];
    }
    
    if(_idealExportRotation == ExportRotationBackgroundDefault){
        _idealExportRotation = _defaultExportRotation;
    }
    
    return _idealExportRotation;
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
        _idealExportRotation = [bgInfo[@"idealExportRotation"] integerValue];
        _defaultExportRotation = [bgInfo[@"defaultExportRotation"] integerValue];
        _idealExportRotation = MIN(ExportRotationLandscapeRight, MAX(ExportRotationBackgroundDefault, _idealExportRotation));
        
        if(!_ruledOrGridBackgroundView){
            // if we've already loaded it, don't reload
            NSString* bgClassName = bgInfo[@"ruledOrGridBackgroundProps"][@"class"];
            if([bgClassName length]){
                Class bgClass = NSClassFromString(bgClassName);
                if(bgClass){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(!_ruledOrGridBackgroundView){
                            _ruledOrGridBackgroundView = [[bgClass alloc] initWithFrame:self.originalUnscaledBounds andProperties:bgInfo];
                            [self.contentView insertSubview:_ruledOrGridBackgroundView atIndex:0];
                        }
                    });
                }
            }
        }
        
        if (![self pageBackgroundTexture]) {
            CGSize backgroundSize = CGSizeZero;
            
            UIImage* img = [UIImage imageWithContentsOfFile:[self backgroundTexturePath]];
            if (img) {
                [[NSThread mainThread] performBlock:^{
                    if (wantsBackgroundTextureLoaded) {
                        [self setPageBackgroundTexture:img];
                    };
                    isLoadingBackgroundTexture = NO;
                    [self updateThumbnailVisibility];
                }];
                
                backgroundSize = img.size;
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
                    backgroundSize = [pdf sizeForPage:0];
                    [[NSThread mainThread] performBlock:^{
                        if (wantsBackgroundTextureLoaded) {
                            [self setPageBackgroundTexture:img];
                        };
                        isLoadingBackgroundTexture = NO;
                        [self updateThumbnailVisibility];
                    }];
                    [MMBackgroundedPaperView writeBackgroundImageToDisk:img backgroundTexturePath:[self backgroundTexturePath]];
                } else {
                    isLoadingBackgroundTexture = NO;
                    [self performSelectorOnMainThread:@selector(updateThumbnailVisibility) withObject:nil waitUntilDone:NO];
                }
            }
            
            [self setDefaultRotationForBackgroundSize:backgroundSize];
        } else {
            isLoadingBackgroundTexture = NO;
            [self performSelectorOnMainThread:@selector(updateThumbnailVisibility) withObject:nil waitUntilDone:NO];
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
    }else if(_ruledOrGridBackgroundView){
        UIGraphicsPushContext(context);

        [_ruledOrGridBackgroundView drawInContext:context forSize:thumbSize];
        
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
        pageBackground.bounds = self.originalUnscaledBounds;
        [pageBackground aspectFillBackgroundImageIntoView];

        [addedScrap setBackgroundView:[pageBackground stampBackgroundFor:[addedScrap state]]];
    }else if(_ruledOrGridBackgroundView){
        [addedScrap setBackgroundView:[_ruledOrGridBackgroundView stampBackgroundFor:[addedScrap state]]];
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
    return CGPointMake(CGRectGetMidX(self.originalUnscaledBounds), CGRectGetMidY(self.originalUnscaledBounds));
}

#pragma mark - Export to PDF

- (void)exportVisiblePageToPDF:(void (^)(NSURL* urlToPDF))completionBlock {
    NSString* tmpPagePath = [[NSTemporaryDirectory() stringByAppendingString:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"pdf"];
    
    __block CGContextRef context;
    __block CFDataRef boxData;
    
    [self exportVisiblePage:completionBlock rotation:ExportRotationPortrait startingContextBlock:^CGContextRef(CGRect finalExportBounds, CGFloat scale, CGFloat defaultRotation) {
        CGRect exportedPageSize = CGRectFromSize(finalExportBounds.size);
        context = CGPDFContextCreateWithURL((__bridge CFURLRef)([NSURL fileURLWithPath:tmpPagePath]), &exportedPageSize, NULL);
        UIGraphicsPushContext(context);
        
        boxData = CFDataCreate(NULL, (const UInt8*)&exportedPageSize, sizeof(CGRect));
        
        CGPDFContextBeginPage(context, (CFDictionaryRef) @{ @"Rotate": @(defaultRotation),
                                                            (NSString*)kCGPDFContextMediaBox: (__bridge NSData*)boxData });

        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -finalExportBounds.size.height);

        return context;
    } endingContextBlock:^NSURL *(){
        CGPDFContextEndPage(context);
        CGPDFContextClose(context);
        UIGraphicsPopContext();
        CFRelease(context);
        CFRelease(boxData);
        
        return [NSURL fileURLWithPath:tmpPagePath];
    }];
}

- (void)exportVisiblePageToImage:(void (^)(NSURL* urlToImage))completionBlock {
    [self exportVisiblePage:completionBlock rotation:ExportRotationPortrait startingContextBlock:^CGContextRef(CGRect finalExportBounds, CGFloat scale, CGFloat defaultRotation) {
        
        UIGraphicsBeginImageContextWithOptions(finalExportBounds.size, NO, scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        return context;
    } endingContextBlock:^NSURL *{
        NSString* tmpPagePath = [[NSTemporaryDirectory() stringByAppendingString:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"png"];
        
        UIImage* outputImage = UIGraphicsGetImageFromCurrentImageContext();
        [UIImagePNGRepresentation(outputImage) writeToFile:tmpPagePath atomically:YES];
        
        UIGraphicsEndImageContext();
        
        return [NSURL fileURLWithPath:tmpPagePath];
    }];
}

// NOTE: this method will export the image in the same
// orientation as its original background. if there is
// no background, then it will be exported portrait
- (void)exportVisiblePage:(void (^)(NSURL* urlToImage))completionBlock
                 rotation:(ExportRotation)exportRotation
     startingContextBlock:(CGContextRef (^)(CGRect finalExportBounds, CGFloat scale, CGFloat defaultRotation))startContextBlock
       endingContextBlock:(NSURL* (^)())endContextBlock{
    
    MMPDF* pdf = nil;
    UIImage* backgroundImage = nil;
    NSURL* backgroundAssetURL = [self backgroundAssetURL];
    
    // default the page size to the screen dimensions in PDF ppi.
    CGSize screenSize = [[[UIScreen mainScreen] fixedCoordinateSpace] bounds].size;
    __block CGRect finalExportBounds = CGRectFromSize(screenSize);
    CGSize backgroundSize = CGSizeZero;
    CGFloat defaultRotation = 0;
    CGFloat scale = [[UIScreen mainScreen] scale];

    if ([[[[backgroundAssetURL path] pathExtension] lowercaseString] isEqualToString:@"pdf"]) {
        pdf = [[MMPDF alloc] initWithURL:backgroundAssetURL];
        if ([pdf pageCount]) {
            backgroundSize = [pdf sizeForPage:0];
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
            
            if(backgroundSize.height > backgroundSize.width){
                finalExportBounds = CGSizeFill(backgroundSize, screenSize);
            }else{
                finalExportBounds = CGSizeFill(backgroundSize, CGSizeSwap(screenSize));
            }
            //
            //            NSLog(@"Fit screen to PDF (pts): %.2f %.2f %.2f %.2f", scaledScreen.origin.x, scaledScreen.origin.y, scaledScreen.size.width, scaledScreen.size.height);
        }
    } else if ([self backgroundTexturePath]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self backgroundTexturePath]]) {
            backgroundAssetURL = [NSURL fileURLWithPath:[self backgroundTexturePath]];
            backgroundImage = [UIImage imageWithContentsOfFile:[backgroundAssetURL path]];
            if (backgroundImage) {
                backgroundSize = [backgroundImage size];
                
                if(backgroundSize.height > backgroundSize.width){
                    finalExportBounds = CGSizeFill(backgroundSize, screenSize);
                }else{
                    finalExportBounds = CGSizeFill(backgroundSize, CGSizeSwap(screenSize));
                }
            }
        }
    }
    
    // determine how many times we need to rotate the page content
    // for it to be in the target rotation
    // negative == rotate right
    // positive == rotate left
    NSInteger fullRotation = 0;
    
    if(_idealExportRotation == ExportRotationLandscapeLeft){
        fullRotation = 1;
    }else if(_idealExportRotation == ExportRotationLandscapeRight){
        fullRotation = -1;
    }
    
    if(_defaultExportRotation == ExportRotationLandscapeLeft){
        fullRotation = fullRotation - 1;
    }else if(_defaultExportRotation == ExportRotationLandscapeRight){
        fullRotation = fullRotation + 1;
    }
    
    // now we know our target rotation, so let's export:
    
    if ([[self.drawableView state] isStateLoaded]) {
        
        MMImmutableScrapsOnPaperState* immutableScrapState = [scrapsOnPaperState immutableStateForPath:nil];
        [self.drawableView exportToImageOnComplete:^(UIImage* image) {
            NSInteger targetRotation = fullRotation;

            ////////////////////////////////////////////////////////
            //
            // Rotation Step #1
            // calculate the proper export bounds for the page
            // given the input preference for landscape left, landscape
            // right, or portrait
            //
            CGRect preRotationExportBounds = finalExportBounds;
            CGRect postRotationExportBounds = finalExportBounds;
            while(targetRotation != 0){
                postRotationExportBounds = CGRectSwap(postRotationExportBounds);

                // move 1 closer to 0
                targetRotation -= SIGN(fullRotation);
            }
            //
            ////////////////////////////////////////////////////////

            CGContextRef context = startContextBlock(postRotationExportBounds, scale, defaultRotation);
            CGContextSaveThenRestoreForBlock(context, ^{
                // flip
                CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
                
                ////////////////////////////////////////////////////////
                //
                // Rotation Step #2
                // Handle rotating the canvas to adjust for user specified
                // landscape left, landscape right, or portrait rotation
                //
                NSInteger targetRotation = fullRotation;

                CGContextTranslateCTM(context, postRotationExportBounds.size.width / 2, postRotationExportBounds.size.height / 2);

                while(targetRotation != 0){
                    CGFloat theta = 90.0 * M_PI / 180.0 * -1 * SIGN(fullRotation);
                    CGContextRotateCTM(context, theta);
                    
                    // move 1 closer to 0
                    targetRotation -= SIGN(fullRotation);
                }
                
                CGContextTranslateCTM(context, -preRotationExportBounds.size.width / 2, -preRotationExportBounds.size.height / 2);
                //
                ////////////////////////////////////////////////////////

                // guarantee at least a white background
                [[UIColor whiteColor] setFill];
                [[UIBezierPath bezierPathWithRect:finalExportBounds] fill];
                
                if (pdf) {
                    CGContextSaveThenRestoreForBlock(context, ^{
                        // PDF background
                        CGPDFDocumentRef pdfDocRef = [pdf openPDF];
                        [pdf renderPage:0 intoContext:context withSize:finalExportBounds.size withPDFRef:pdfDocRef];
                    });
                } else if (backgroundImage) {
                    // image background
                    CGContextSaveThenRestoreForBlock(context, ^{
                        CGRect rectForImage = CGSizeFill(backgroundSize, finalExportBounds.size);
                        [backgroundImage drawInRect:rectForImage];
                    });
                } else if(_ruledOrGridBackgroundView){
                    [_ruledOrGridBackgroundView drawInContext:context forSize:finalExportBounds.size];
                }
                
                if(backgroundSize.width > backgroundSize.height){
                    // if the background is landscape, then we need to rotate our
                    // canvas so that the landscape PDF is drawn on our
                    // vertical canvas properly.
                    CGFloat theta = 90.0 * M_PI / 180.0;
                    if([self usesCorrectBackgroundRotation]){
                        theta = -theta;
                    }
                    
                    CGContextTranslateCTM(context, finalExportBounds.size.width / 2, finalExportBounds.size.height / 2);
                    CGContextRotateCTM(context, theta);
                    
                    finalExportBounds = CGRectSwap(finalExportBounds);

                    CGContextTranslateCTM(context, -finalExportBounds.size.width / 2, -finalExportBounds.size.height / 2);
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
            
            NSURL* fullyRenderedPDFURL = endContextBlock();
            
            [pdf closePDF];
            
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

@end
