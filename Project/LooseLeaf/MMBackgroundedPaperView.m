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

-(void) isShowingDrawableView:(BOOL)showDrawableView andIsShowingThumbnail:(BOOL)showThumbnail{
//    if(showDrawableView && !showThumbnail){
//        paperBackgroundView.hidden = NO;
//    }else{
//        paperBackgroundView.hidden = YES;
//    }
}

-(UIImage*) pageBackgroundTexture{
    return paperBackgroundView.image;
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

-(void) addDrawableViewToContentView{
    CheckMainThread;
    // default will be to just append drawable view. subclasses
    // can (and will) change behavior
//    if(paperBackgroundView){
//        [self.contentView insertSubview:drawableView aboveSubview:paperBackgroundView];
//    }else{
        [super addDrawableViewToContentView];
//    }
}

-(void) newlyCutScrapFromPaperView:(MMScrapView*)addedScrap{
    if(self.pageBackgroundTexture){
        MMScrapBackgroundView* backgroundView = [[MMScrapBackgroundView alloc] initWithImage:self.pageBackgroundTexture forScrapState:addedScrap.state];
        
        // clone the background so that the new scrap's
        // background aligns with the old scrap's background
        CGFloat orgRot = 0;
        CGFloat newRot = addedScrap.state.delegate.rotation;
        CGFloat rotDiff = orgRot - newRot;
        
        CGPoint orgC = CGPointMake(CGRectGetMidX([[self page] bounds]), CGRectGetMidY([[self page] bounds]));
        CGPoint newC = addedScrap.state.delegate.center;
        CGPoint moveC = CGPointMake(newC.x - orgC.x, newC.y - orgC.y);
        
        CGPoint convertedC = [addedScrap.state.contentView convertPoint:orgC fromView:[self page]];
        CGPoint refPoint = CGPointMake(addedScrap.state.contentView.bounds.size.width/2,
                                       addedScrap.state.contentView.bounds.size.height/2);
        CGPoint moveC2 = CGPointMake(convertedC.x - refPoint.x, convertedC.y - refPoint.y);
        
        // we have the correct adjustment value,
        // but now we need to account for the fact
        // that the new scrap has a different rotation
        // than the start scrap
        
        moveC = CGPointApplyAffineTransform(moveC, CGAffineTransformMakeRotation(orgRot - newRot));
        
        backgroundView.backgroundRotation = rotDiff;
        backgroundView.backgroundScale = self.pageBackgroundTexture.scale;
        backgroundView.backgroundOffset = moveC2;
        
        [addedScrap setBackgroundView:backgroundView];
    }
}

@end
