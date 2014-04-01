//
//  MMAlbumRowView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMAlbumRowView.h"
#import "MMPhotoManager.h"
#import "MMBufferedImage.h"

@implementation MMAlbumRowView{
    MMPhotoAlbum* album;
    UILabel* name;
    NSMutableArray* drawnSubviews;
    CGAffineTransform rotations[5];
}

@synthesize album;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        drawnSubviews = [NSMutableArray array];
        // load 5 preview image views
        CGFloat maxDim = self.bounds.size.height;
        CGFloat stepX = (self.bounds.size.width - maxDim) / 4;
        CGFloat currX = 0;
        for(int i=0;i<5;i++){
            MMBufferedImage* imgView = [[MMBufferedImage alloc] initWithFrame:CGRectMake(currX, 0, maxDim, maxDim)];
            int maxRotDeg = 20;
            CGFloat angle = (rand() % maxRotDeg - maxRotDeg/2) / 360.0 * M_PI;
            CGAffineTransform transform = CGAffineTransformMakeTranslation(maxDim/2.0, maxDim/2.0);
            transform = CGAffineTransformRotate(transform, angle);
            transform = CGAffineTransformTranslate(transform,-maxDim/2.0,-maxDim/2.0);
            rotations[i] = transform;
            currX += stepX;
//            [self addSubview:imgView];
            [drawnSubviews addObject:imgView];
        }
        
        
//        name = [[UILabel alloc] initWithFrame:self.bounds];
//        [self addSubview:name];
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
        if(i<[album.previewPhotos count]){
            img = [album.previewPhotos objectAtIndex:i];
        }
        MMBufferedImage* v = (MMBufferedImage*)[drawnSubviews objectAtIndex:i];
        if(img){
            [v setImage:img];
            v.hidden = NO;
        }else{
            v.hidden = YES;
        }
        [self setNeedsDisplay];
    }
}

-(void) drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    for(int i=[drawnSubviews count]-1;i>=0;i--){
        MMBufferedImage* v = [drawnSubviews objectAtIndex:i];
        if(!v.hidden){
            CGRect fr = v.frame;
            CGContextTranslateCTM(context, fr.origin.x, fr.origin.y);
            CGContextConcatCTM(context, rotations[i]);
            [v drawRect:fr];
            CGContextConcatCTM(context, CGAffineTransformInvert(rotations[i]));
            CGContextTranslateCTM(context, -fr.origin.x, -fr.origin.y);
        }
    }
}



@end
