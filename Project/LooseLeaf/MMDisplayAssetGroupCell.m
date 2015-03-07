//
//  MMAlbumCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMDisplayAssetGroupCell.h"
#import "MMPhotoAlbum.h"
#import "MMBufferedImageView.h"
#import "MMRotationManager.h"
#import "Constants.h"

@implementation MMDisplayAssetGroupCell{
    MMPhotoAlbum* album;
    UILabel* name;
    NSArray* bufferedImageViews;
    CGFloat visiblePhotoRotation;
    CGFloat initialX[5];
    CGFloat finalX[5];
}

@synthesize album;
@synthesize bufferedImageViews;

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        // load 5 preview image views
        CGFloat maxDim = self.bounds.size.height;
        CGFloat stepX = (self.bounds.size.width - maxDim) / 4;
        CGFloat currX = 0;
        for(int i=0;i<5;i++){
            MMBufferedImageView* imgView = [[MMBufferedImageView alloc] initWithFrame:CGRectMake(currX, 0, maxDim, maxDim)];
            imgView.rotation = RandomPhotoRotation(i);
            [self insertSubview:imgView atIndex:0];
            currX += stepX;
            initialX[5-i-1] = imgView.center.x;
            finalX[5-i-1] = imgView.center.x - (i+1)*stepX/2;
        }
        bufferedImageViews = [NSArray arrayWithArray:self.subviews];
        
        // clarity
        self.opaque = NO;
//        self.clipsToBounds = NO;
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
        MMPhoto* img = nil;
        int indexOfPhoto = 4-i;
        if(indexOfPhoto<[album.previewPhotos count]){
            img = [album.previewPhotos objectAtIndex:indexOfPhoto];
        }
        MMBufferedImageView* v = [bufferedImageViews objectAtIndex:i];
        if(img){
            [v setImage:img.aspectRatioThumbnail];
            v.hidden = NO;
        }else{
            v.hidden = YES;
        }
    }
}

#pragma mark - Rotation

-(void) updatePhotoRotation{
    
    UIInterfaceOrientation orient = [[MMRotationManager sharedInstance] lastBestOrientation];
    if(orient == UIInterfaceOrientationLandscapeRight){
        visiblePhotoRotation = M_PI / 2;
    }else if(orient == UIInterfaceOrientationPortraitUpsideDown){
        visiblePhotoRotation = M_PI;
    }else if(orient == UIInterfaceOrientationLandscapeLeft){
        visiblePhotoRotation = -M_PI / 2;
    }else{
        visiblePhotoRotation = 0;
    }
    
    int i=0;
    for (MMBufferedImageView* imageView in bufferedImageViews) {
        imageView.rotation = visiblePhotoRotation + RandomPhotoRotation(i);
        i++;
    }
}

#pragma mark - Swipe for Delete

-(void) adjustForDelete:(CGFloat)adjustment{
    NSLog(@"adjust: %f", adjustment);
    adjustment = MAX(0, adjustment);
    
    for(int i=0;i<5;i++){
        CGFloat ix = initialX[i];
        CGFloat fx = finalX[i];
        CGFloat diff = fx - ix;
        CGFloat x = ix + diff*adjustment;
        
        UIView* imgView = [bufferedImageViews objectAtIndex:i];
        CGPoint c = imgView.center;
        c.x = x;
        imgView.center = c;
    }

}

@end
