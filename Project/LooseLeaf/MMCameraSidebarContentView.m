//
//  MMCameraSidebarContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCameraSidebarContentView.h"
#import "MMPhotoManager.h"
#import "MMImageSidebarContainerView.h"
#import "MMPermissionPhotosCollectionViewCell.h"
#import "MMPermissionCameraPhotosCollectionViewCell.h"
#import "NSThread+BlockAdditions.h"
#import "CaptureSessionManager.h"
#import "MMRotationManager.h"
#import "MMCameraCollectionViewCell.h"
#import "MMSinglePhotoCollectionViewCell.h"
#import "MMPhotoAlbumListLayout.h"
#import "UIView+Debug.h"
#import "Constants.h"

@implementation MMCameraSidebarContentView{
    MMCameraCollectionViewCell * cachedCameraCell;
    CGPoint lastCameraRollOffset;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // don't use the albumListScrollView at all
        [albumListScrollView removeFromSuperview];
        albumListScrollView = nil;
        
        photoListScrollView.alpha = 1;
        
        currentAlbum = [[MMPhotoManager sharedInstance] cameraRoll];
        
        [photoListScrollView registerClass:[MMCameraCollectionViewCell class] forCellWithReuseIdentifier:@"MMCameraCollectionViewCell"];
        [photoListScrollView registerClass:[MMPermissionPhotosCollectionViewCell class] forCellWithReuseIdentifier:@"MMPermissionPhotosCollectionViewCell"];
        [photoListScrollView registerClass:[MMPermissionCameraPhotosCollectionViewCell class]
                forCellWithReuseIdentifier:@"MMPermissionCameraPhotosCollectionViewCell"];
    }
    return self;
}

-(void) reset:(BOOL)animated{
    // noop
}

-(void) show:(BOOL)animated{
    if(isShowing){
        [photoListScrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        return;
    }
    isShowing = YES;
    
    albumListScrollView.alpha = 0;
    photoListScrollView.alpha = 1;
    [[MMPhotoManager sharedInstance] initializeAlbumCache];

    currentAlbum = [[MMPhotoManager sharedInstance] cameraRoll];
    [self doneLoadingPhotoAlbums];
    [self updatePhotoRotation:NO];
}

-(void) hide:(BOOL)animated{
    isShowing = NO;

    albumListScrollView.alpha = 0;
    photoListScrollView.alpha = 1;
    
    lastCameraRollOffset = photoListScrollView.contentOffset;
}

-(void) killMemory{
    [super killMemory];
    if(!isShowing){
        cachedCameraCell = nil;
    }
}

-(void) updateEmptyErrorMessage{
    // noop
}

#pragma mark - MMPhotoManagerDelegate

-(void) doneLoadingPhotoAlbums{
    currentAlbum = [[MMPhotoManager sharedInstance] cameraRoll];
    if(self.isShowing && photoListScrollView.alpha){
        [photoListScrollView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [photoListScrollView setContentOffset:lastCameraRollOffset animated:NO];
        });
    }
}

-(void) albumUpdated:(MMPhotoAlbum *)album{
    if(album == [[MMPhotoManager sharedInstance] cameraRoll]){
        currentAlbum = album;
        [self doneLoadingPhotoAlbums];
    }
}

#pragma mark - Description

-(NSString*) description{
    return @"Camera Roll";
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    // we're only working with the photoListScrollView. there's no albums here
    if(section == 0){
        return 1;
    }else{
        if([MMPhotoManager hasPhotosPermission]){
            return currentAlbum.numberOfPhotos;
        }else{
            return 1;
        }
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    // 1 section for camera row, and 1 section for camera roll photos
    if(isShowing && !([CaptureSessionManager hasCamera] && [CaptureSessionManager hasCameraPermission]) &&
       ![MMPhotoManager hasPhotosPermission]){
        return 1;
    }
    NSInteger ret = isShowing ? 2 : 0;
    return ret;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if ([CaptureSessionManager hasCamera] && [CaptureSessionManager hasCameraPermission]) {
            if(cachedCameraCell){
                return cachedCameraCell;
            }else{
                cachedCameraCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MMCameraCollectionViewCell" forIndexPath:indexPath];
                cachedCameraCell.delegate = self;
                return cachedCameraCell;
            }
        }else if([MMPhotoManager hasPhotosPermission]){
            MMPermissionPhotosCollectionViewCell* cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"MMPermissionPhotosCollectionViewCell" forIndexPath:indexPath];
            [cell showCameraSteps];
            return cell;
        }else{
            return [collectionView dequeueReusableCellWithReuseIdentifier:@"MMPermissionCameraPhotosCollectionViewCell"
                                                             forIndexPath:indexPath];
        }
    }
    if([MMPhotoManager hasPhotosPermission]){
        MMSinglePhotoCollectionViewCell* photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MMSinglePhotoCollectionViewCell" forIndexPath:indexPath];
        [photoCell loadPhotoFromAlbum:currentAlbum atIndex:indexPath.row forVisibleIndex:indexPath.row];
        photoCell.delegate = self;
        return photoCell;
    }else{
        MMPermissionPhotosCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MMPermissionPhotosCollectionViewCell" forIndexPath:indexPath];
        [cell showPhotosSteps];
        return cell;
    }
}

@end
