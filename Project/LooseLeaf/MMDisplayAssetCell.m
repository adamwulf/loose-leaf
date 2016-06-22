//
//  MMSinglePhotoCollectionViewCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/18/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMDisplayAssetCell.h"
#import "MMBufferedImageView.h"
#import "Constants.h"

@implementation MMDisplayAssetCell{
    MMBufferedImageView* bufferedImage;
    NSInteger index;
    MMDisplayAssetGroup* album;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        bufferedImage = [[MMBufferedImageView alloc] initWithFrame:CGRectInset(self.bounds, 2, 2)];
        bufferedImage.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
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
            [delegate assetWasTapped:result fromView:bufferedImage withRotation:bufferedImage.rotation];
        }
    }];
}

#pragma mark - Notification

-(void) assetUpdated:(NSNotification*)note{
    // called when the underlying asset is updated.
    // this may or may not ever be called depending
    // on the asset (PDFs in particular use
    // this to update their thumbnail)
    dispatch_async(dispatch_get_main_queue(), ^{
        MMDisplayAsset* asset = [note object];
        bufferedImage.image = asset.aspectRatioThumbnail;
    });
}

#pragma mark - Properties

-(void) loadPhotoFromAlbum:(MMDisplayAssetGroup*)_album atIndex:(NSInteger)photoIndex forVisibleIndex:(NSInteger)visibleIndex{
    @try {
        album = _album;
        index = visibleIndex;
        NSIndexSet* assetsToLoad = [[NSIndexSet alloc] initWithIndex:index];
        [album loadPhotosAtIndexes:assetsToLoad usingBlock:^(MMDisplayAsset *result, NSUInteger index, BOOL *stop) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            if(result){
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetUpdated:) name:kDisplayAssetThumbnailGenerated object:result];
                [bufferedImage setPreferredAspectRatioForEmptyImage:result.fullResolutionSize];
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

-(void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
