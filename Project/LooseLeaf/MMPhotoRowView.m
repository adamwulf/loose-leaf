//
//  MMPhotoRowView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/1/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPhotoRowView.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import "MMBufferedImageView.h"

@implementation MMPhotoRowView{
    MMBufferedImageView* leftImageView;
    MMBufferedImageView* rightImageView;
    
    MMPhotoAlbum* loadedAlbum;
    NSInteger loadedIndex;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        CGFloat maxDim = self.bounds.size.height;

        leftImageView = [[MMBufferedImageView alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, maxDim, maxDim), 10, 10)];
        leftImageView.transform = CGAffineTransformMakeRotation(RandomPhotoRotation);
        [self addSubview:leftImageView];

        rightImageView = [[MMBufferedImageView alloc] initWithFrame:CGRectInset(CGRectMake(self.bounds.size.width - maxDim, 0, maxDim, maxDim), 10, 10)];
        rightImageView.transform = CGAffineTransformMakeRotation(RandomPhotoRotation);
        [self addSubview:rightImageView];

        leftImageView.layer.borderColor = [UIColor orangeColor].CGColor;
        leftImageView.layer.borderWidth = 1;
        
        rightImageView.layer.borderColor = [UIColor purpleColor].CGColor;
        rightImageView.layer.borderWidth = 1;
        
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 1;
    }
    return self;
}


-(void) loadPhotosFromAlbum:(MMPhotoAlbum*)album atRow:(NSInteger)rowIndex{
    if(loadedAlbum != album || loadedIndex != rowIndex){
        loadedAlbum = album;
        loadedIndex = rowIndex;
        
        // now flip the index so we load
        // in reverse order
        rowIndex = (ceilf(album.numberOfPhotos / 2.0) - 1) - rowIndex;
        if(!loadedAlbum){
            leftImageView.hidden = YES;
            rightImageView.hidden = YES;
        }else{
            NSIndexSet* assetsToLoad = nil;
            NSInteger firstIndex = rowIndex*2;
            if(rowIndex >= ceilf(album.numberOfPhotos / 2.0) || rowIndex < 0){
                leftImageView.image = nil;
                rightImageView.image = nil;
                rightImageView.hidden = YES;
                leftImageView.hidden = YES;
            }else{
                leftImageView.hidden = NO;
                if(firstIndex == album.numberOfPhotos - 1){
                    // we only show 1 photo
                    assetsToLoad = [[NSIndexSet alloc] initWithIndex:rowIndex*2];
                    rightImageView.hidden = YES;
                }else{
                    // we show 2 photos
                    assetsToLoad = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(rowIndex*2, 2)];
                    rightImageView.hidden = NO;
                }
                leftImageView.image = nil;
                rightImageView.image = nil;
                [album loadPhotosAtIndexes:assetsToLoad usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if(result){
                        if(index % 2 || [assetsToLoad count] == 1){
                            leftImageView.image = [UIImage imageWithCGImage:result.aspectRatioThumbnail];
                            leftImageView.hidden = NO;
                        }else{
                            rightImageView.image = [UIImage imageWithCGImage:result.aspectRatioThumbnail];
                            rightImageView.hidden = NO;
                        }
                    }
                }];
            }
        }
    }
}

-(void) unload{
    loadedAlbum = nil;
    loadedIndex = 0;
    leftImageView.image = nil;
    rightImageView.image = nil;
    leftImageView.hidden = YES;
    rightImageView.hidden = YES;
}

@end
