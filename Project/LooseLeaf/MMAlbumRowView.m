//
//  MMAlbumRowView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMAlbumRowView.h"
#import "MMPhotoManager.h"
#import "MMBufferedImageView.h"

@implementation MMAlbumRowView{
    MMPhotoAlbum* album;
    UILabel* name;
}

@synthesize album;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // load 5 preview image views
        CGFloat maxDim = self.bounds.size.height;
        CGFloat stepX = (self.bounds.size.width - maxDim) / 4;
        CGFloat currX = 0;
        for(int i=0;i<5;i++){
            MMBufferedImageView* imgView = [[MMBufferedImageView alloc] initWithFrame:CGRectMake(currX, 0, maxDim, maxDim)];
            int maxRotDeg = 20;
            CGFloat angle = (rand() % maxRotDeg - maxRotDeg/2) / 360.0 * M_PI;
            imgView.transform = CGAffineTransformMakeRotation(angle);
            [self insertSubview:imgView atIndex:0];
            currX += stepX;
        }
        
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
        if(!album){
            [self loadedPreviewPhotos];
        }
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
        MMBufferedImageView* v = (MMBufferedImageView*)[self.subviews objectAtIndex:i];
        if(img){
            [v setImage:img];
            v.hidden = NO;
        }else{
            v.hidden = YES;
        }
    }
}


@end
