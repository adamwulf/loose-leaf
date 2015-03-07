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
    CGFloat initRot[5];
    CGFloat rotAdj[5];
    CGFloat adjY[5];
}

@synthesize album;
@synthesize bufferedImageViews;

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        // load 5 preview image views
        CGFloat currX = 2*kBounceWidth;
        CGFloat maxDim = self.bounds.size.height;
        CGFloat stepX = (self.bounds.size.width - maxDim - currX) / 4;
        for(int i=0;i<5;i++){
            MMBufferedImageView* imgView = [[MMBufferedImageView alloc] initWithFrame:CGRectMake(currX, 0, maxDim, maxDim)];
            imgView.rotation = RandomPhotoRotation(i);
            [self insertSubview:imgView atIndex:0];
            currX += stepX;
            initialX[5-i-1] = imgView.center.x;
            finalX[5-i-1] = imgView.center.x - (i+1)*stepX/2;
            initRot[5-i-1] = imgView.rotation;
            rotAdj[5-i-1] = RandomPhotoRotation(i+1);
            adjY[5-i-1] = 4 + rand()%4 * (i%2 ? 1 : -1);
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
    adjustment = MAX(0, adjustment);
    
    for(int i=0;i<5;i++){
        CGFloat ix = initialX[i];
        CGFloat fx = finalX[i];
        CGFloat diff = fx - ix;
        CGFloat x = ix + diff*adjustment;
        
        MMBufferedImageView* imgView = [bufferedImageViews objectAtIndex:i];
        CGPoint c = imgView.center;
        c.x = x;
        c.y = self.bounds.size.height/2 + adjY[i]*adjustment;
        imgView.center = c;
        
        imgView.rotation = initRot[i] + adjustment*rotAdj[i];
    }

}

@end
