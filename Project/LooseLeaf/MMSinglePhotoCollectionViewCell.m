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

@implementation MMSinglePhotoCollectionViewCell{
    MMBufferedImageView* bufferedImage;
    NSInteger index;
    MMPhotoAlbum* album;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        bufferedImage = [[MMBufferedImageView alloc] initWithFrame:CGRectInset(self.bounds, 2, 2)];
        bufferedImage.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:bufferedImage];
        
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [bufferedImage addGestureRecognizer:tapGesture];
    }
    return self;
}

@synthesize delegate;

#pragma mark - Gesture

-(void) tapped:(id)gesture{
    [album loadPhotosAtIndexes:[[NSIndexSet alloc] initWithIndex:index] usingBlock:^(MMDisplayAsset *result, NSUInteger _index, BOOL *stop) {
        if(result){
            [delegate photoWasTapped:result fromView:bufferedImage withRotation:bufferedImage.rotation];
        }
    }];
}

#pragma mark - Properties

-(void) loadPhotoFromAlbum:(MMPhotoAlbum*)_album atIndex:(NSInteger)photoIndex forVisibleIndex:(NSInteger)visibleIndex{
    @try {
        album = _album;
        index = visibleIndex;
        NSIndexSet* assetsToLoad = [[NSIndexSet alloc] initWithIndex:index];
        [album loadPhotosAtIndexes:assetsToLoad usingBlock:^(MMDisplayAsset *result, NSUInteger index, BOOL *stop) {
            if(result){
                bufferedImage.image = result.aspectRatioThumbnail;
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
        DebugLog(@"gotcha");
    }
}

-(CGFloat) rotation{
    return bufferedImage.rotation;
}

-(void) setRotation:(CGFloat)rotation{
    bufferedImage.rotation = rotation;
}

@end
