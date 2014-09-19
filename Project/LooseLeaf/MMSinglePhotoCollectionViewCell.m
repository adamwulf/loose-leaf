//
//  MMSinglePhotoCollectionViewCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/18/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMSinglePhotoCollectionViewCell.h"
#import "MMBufferedImageView.h"
#import "Constants.h"
#import "UIView+Debug.h"

@implementation MMSinglePhotoCollectionViewCell{
    MMBufferedImageView* bufferedImage;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        bufferedImage = [[MMBufferedImageView alloc] initWithFrame:CGRectInset(self.bounds, 2, 2)];
        bufferedImage.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:bufferedImage];
        [self showDebugBorder];
    }
    return self;
}

#pragma mark - Properties

-(void) loadPhotoFromAlbum:(MMPhotoAlbum*)album atIndex:(NSInteger)photoIndex forVisibleIndex:(NSInteger)visibleIndex{
    @try {
        NSIndexSet* assetsToLoad = [[NSIndexSet alloc] initWithIndex:visibleIndex];
        [album loadPhotosAtIndexes:assetsToLoad usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result){
                bufferedImage.image = [UIImage imageWithCGImage:result.aspectRatioThumbnail];
                bufferedImage.rotation = RandomPhotoRotation(photoIndex);
            }else{
                // was an error. possibly syncing the ipad to iphoto,
                // so the album is updated faster than we can enumerate.
                // just noop.
                // https://github.com/adamwulf/loose-leaf/issues/529
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"gotcha");
    }
}

-(CGFloat) rotation{
    return bufferedImage.rotation;
}

-(void) setRotation:(CGFloat)rotation{
    bufferedImage.rotation = rotation;
}

@end
