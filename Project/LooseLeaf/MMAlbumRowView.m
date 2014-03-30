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
    NSArray* photoViews;
}

- (id)initWithFrame:(CGRect)frame andAlbum:(MMPhotoAlbum*)_album{
    self = [super initWithFrame:frame];
    if (self) {
        album = _album;
        album.delegate = self;
        photoViews = [NSArray array];
        [album loadPreviewPhotos];
        [self loadedPreviewPhotos];
        
        // clarity
        self.opaque = NO;
        self.clipsToBounds = YES;
    }
    return self;
}

-(void) dealloc{
    album.delegate = nil;
}

#pragma mark - MMPhotoAlbumDelegate;

-(void) loadedPreviewPhotos{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat imageHeight = self.bounds.size.height - 4;
    CGFloat dist = 2;
    for(UIImage* img in album.previewPhotos){
        MMBufferedImageView* imgView = [[MMBufferedImageView alloc] initWithImage:img];
        [self insertSubview:imgView atIndex:0];
        CGRect fr = imgView.frame;
        fr.origin.y = 2;
        fr.origin.x = dist;
        if(fr.size.height > imageHeight){
            fr.size.width *= imageHeight / fr.size.height;
            fr.size.height = imageHeight;
        }
        imgView.frame = fr;
        CGFloat angle = (rand() % 20 - 10) / 360.0 * M_PI;
        imgView.transform = CGAffineTransformMakeRotation(angle);
        
        dist += (self.bounds.size.width - self.bounds.size.height - 4) / 4;
    }
}



@end
