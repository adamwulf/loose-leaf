//
//  MMAlbumRowView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMAlbumRowView.h"
#import "MMPhotoManager.h"
#import "Constants.h"
#import "MMBufferedImageView.h"
#import "MMRotationManager.h"

@implementation MMAlbumRowView{
    MMPhotoAlbum* album;
    UILabel* name;
    NSArray* bufferedImageViews;
    CGFloat visiblePhotoRotation;
}

@synthesize album;
@synthesize delegate;
@synthesize bufferedImageViews;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // load 5 preview image views
        CGFloat maxDim = self.bounds.size.height;
        CGFloat stepX = (self.bounds.size.width - maxDim) / 4;
        CGFloat currX = 0;
        for(int i=0;i<5;i++){
            MMBufferedImageView* imgView = [[MMBufferedImageView alloc] initWithFrame:CGRectMake(currX, 0, maxDim, maxDim)];
            imgView.rotation = RandomPhotoRotation;
            [self insertSubview:imgView atIndex:0];
            currX += stepX;
        }
        bufferedImageViews = [NSArray arrayWithArray:self.subviews];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tap];
        
        // clarity
        self.opaque = NO;
        self.clipsToBounds = YES;
    }
    return self;
}

-(void) setAlbum:(MMPhotoAlbum *)_album{
    if(album != _album){
        album = _album;
        [album loadPreviewPhotos];
        name.text = album.name;
        [self loadedPreviewPhotos];
    }
}

#pragma mark - MMPhotoAlbumDelegate;

-(void) loadedPreviewPhotos{
    for(int i=0;i<5;i++){
        UIImage* img = nil;
        int indexOfPhoto = 4-i;
        if(indexOfPhoto<[album.previewPhotos count]){
            img = [album.previewPhotos objectAtIndex:indexOfPhoto];
        }
        MMBufferedImageView* v = [bufferedImageViews objectAtIndex:i];
        if(img){
            [v setImage:img];
            v.hidden = NO;
        }else{
            v.hidden = YES;
        }
    }
}

#pragma mark UIGestureRecgonizer

-(void) tapped:(UIGestureRecognizer*)gesture{
    if(gesture.state == UIGestureRecognizerStateRecognized){
        [self.delegate albumRowWasTapped:self];
    }
}

#pragma mark - Rotation

-(void) updatePhotoRotation{
    
    UIDeviceOrientation orient = [[MMRotationManager sharedInstance] currentDeviceOrientation];
    if(orient == UIDeviceOrientationLandscapeLeft){
        visiblePhotoRotation = M_PI / 2;
    }else if(orient == UIDeviceOrientationPortraitUpsideDown){
        visiblePhotoRotation = M_PI;
    }else if(orient == UIDeviceOrientationLandscapeRight){
        visiblePhotoRotation = -M_PI / 2;
    }else{
        visiblePhotoRotation = 0;
    }
    
    for (MMBufferedImageView* imageView in bufferedImageViews) {
        imageView.rotation = visiblePhotoRotation + RandomPhotoRotation;
    }
}


@end
