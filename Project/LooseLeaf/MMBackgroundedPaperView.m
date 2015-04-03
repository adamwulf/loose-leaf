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

@implementation MMBackgroundedPaperView{
    UIImageView* paperBackgroundView;
    NSString* backgroundTexturePath;
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

-(void) setPageBackgroundTexture:(UIImage*)img{
    [self setPageBackgroundTexture:img andSaveToDisk:YES];
}

-(void) setPageBackgroundTexture:(UIImage*)img andSaveToDisk:(BOOL)saveToDisk{
    CheckMainThread;
    if(img.size.width > img.size.height){
        // rotate
        img = [[UIImage alloc] initWithCGImage: img.CGImage
                                         scale: 1.0
                                   orientation: [self isVert:img] ? UIImageOrientationLeft : UIImageOrientationUp];
    }
    
    if(!paperBackgroundView){
        paperBackgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        paperBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        paperBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView insertSubview:paperBackgroundView atIndex:0];
//        if(drawableView){
//            [self.contentView insertSubview:paperBackgroundView belowSubview:drawableView];
//        }else{
//            [self.contentView insertSubview:paperBackgroundView belowSubview:scrapsOnPaperState.scrapContainerView];
//        }
//        if(drawableView && !drawableView.hidden){
//            paperBackgroundView.hidden = NO;
//        }else{
//            paperBackgroundView.hidden = YES;
//        }
    }
    paperBackgroundView.image = img;
    
    if(saveToDisk){
        dispatch_async([MMEditablePaperView importThumbnailQueue], ^{
            [UIImagePNGRepresentation(img) writeToFile:[self backgroundTexturePath] atomically:YES];
        });
    }
}

#pragma mark - Loading and Unloading State

-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize)pagePtSize andScale:(CGFloat)scale andContext:(JotGLContext *)context{
    [super loadStateAsynchronously:async withSize:pagePtSize andScale:scale andContext:context];
    
    void (^loadPageBackgroundFromDisk)() = ^{
        UIImage* img = [UIImage imageWithContentsOfFile:[self backgroundTexturePath]];
        if(img){
            [[NSThread mainThread] performBlock:^{
                [self setPageBackgroundTexture:img andSaveToDisk:NO];
            }];
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
    [paperBackgroundView removeFromSuperview];
    paperBackgroundView = nil;
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


@end
