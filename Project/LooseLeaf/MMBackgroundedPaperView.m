//
//  MMBackgroundedPaperView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 2/25/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMBackgroundedPaperView.h"
#import "MMEditablePaperViewSubclass.h"

@implementation MMBackgroundedPaperView{
    UIImageView* paperBackgroundView;
}

-(BOOL) isVert:(UIImage*)img{
    return img.imageOrientation == UIImageOrientationDown ||
    img.imageOrientation == UIImageOrientationDownMirrored ||
    img.imageOrientation == UIImageOrientationUp ||
    img.imageOrientation == UIImageOrientationUpMirrored;
    
}

-(void) isShowingDrawableView:(BOOL)showDrawableView andIsShowingThumbnail:(BOOL)showThumbnail{
    if(showDrawableView && !showThumbnail){
        paperBackgroundView.hidden = NO;
    }else{
        paperBackgroundView.hidden = YES;
    }
}

-(void) setPageBackgroundTexture:(UIImage*)img{
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
        if(drawableView){
            [self.contentView insertSubview:paperBackgroundView belowSubview:drawableView];
        }else{
            [self.contentView insertSubview:paperBackgroundView belowSubview:scrapsOnPaperState.scrapContainerView];
        }
    }
    paperBackgroundView.image = img;
}

#pragma mark - Protected Methods

-(void) addDrawableViewToContentView{
    CheckMainThread;
    // default will be to just append drawable view. subclasses
    // can (and will) change behavior
    if(paperBackgroundView){
        [self.contentView insertSubview:drawableView belowSubview:paperBackgroundView];
    }else{
        [super addDrawableViewToContentView];
    }
}


@end
