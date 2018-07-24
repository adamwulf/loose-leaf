//
//  MMCameraSidebarContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMShapeSidebarContentView.h"
#import "MMPhotoManager.h"
#import "MMImageSidebarContainerView.h"
#import "MMPhotosPermissionCell.h"
#import "MMPermissionCameraPhotosCollectionViewCell.h"
#import "NSThread+BlockAdditions.h"
#import "MMRotationManager.h"
#import "MMCameraCollectionViewCell.h"
#import "MMPhotosListLayout.h"
#import "MMShapeAssetCell.h"
#import "UIView+Debug.h"
#import "MMAlbumGroupListLayout.h"
#import "Constants.h"
#import "MMBorderedCamView.h"
#import "MMShapeAssetGroup.h"


@interface MMShapeSidebarContentView (Protected)

- (CGFloat)idealRotationForOrientation;

@end


@implementation MMShapeSidebarContentView {
    CGPoint lastCameraRollOffset;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // don't use the albumListScrollView at all
        [albumListScrollView removeFromSuperview];
        albumListScrollView = nil;

        photoListScrollView.alpha = 1;

        currentAlbum = [MMShapeAssetGroup sharedInstance];

        [photoListScrollView registerClass:[MMShapeAssetCell class] forCellWithReuseIdentifier:@"MMShapeAssetCell"];
    }
    return self;
}

- (void)reset:(BOOL)animated {
    // noop
}

- (void)show:(BOOL)animated {
    if (isShowing) {
        [photoListScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        return;
    }
    isShowing = YES;

    albumListScrollView.alpha = 0;
    photoListScrollView.alpha = 1;

    [self updatePhotoRotation:NO];
}

- (void)hide:(BOOL)animated {
    isShowing = NO;

    albumListScrollView.alpha = 0;
    photoListScrollView.alpha = 1;

    lastCameraRollOffset = photoListScrollView.contentOffset;
}

- (BOOL)hasPermission {
    return YES;
}

- (UICollectionViewLayout*)albumsLayout {
    return [[MMAlbumGroupListLayout alloc] init];
}

- (UICollectionViewLayout*)photosLayout {
    return [[MMPhotosListLayout alloc] initForRotation:[self idealRotationForOrientation]];
}

- (void)updateEmptyErrorMessage {
    // noop
}

- (NSString*)messageTextWhenEmpty {
    return @"No Shapes";
}

#pragma mark - Description

- (NSString*)description {
    return @"Shapes";
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath {
    MMDisplayAssetCell* shapeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MMShapeAssetCell" forIndexPath:indexPath];
    [shapeCell loadPhotoFromAlbum:currentAlbum atIndex:indexPath.row];
    shapeCell.delegate = self;
    return shapeCell;
}

#pragma mark - MMDisplayAssetCellDelegate

- (void)assetWasTapped:(MMDisplayAsset*)asset fromView:(UIView<MMDisplayAssetCoordinator>*)bufferedImage withRotation:(CGFloat)rotation {
    lastCameraRollOffset = photoListScrollView.contentOffset;

    [super assetWasTapped:asset fromView:bufferedImage withRotation:rotation];
}

@end
