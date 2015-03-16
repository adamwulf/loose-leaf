//
//  MMImageSidebarContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/29/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMAbstractSidebarContentView.h"
#import "MMPhotoManager.h"
#import "MMAlbumRowView.h"
#import "MMBufferedImageView.h"
#import "MMImageSidebarContainerView.h"
#import "MMDisplayAssetCell.h"
#import "MMPhotosPermissionCell.h"
#import "MMEmptyCollectionViewCell.h"
#import "MMDisplayAssetGroupCell.h"
#import "MMAssetGroupListLayout.h"
#import "MMAssetListLayout.h"
#import "MMRotationManager.h"
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import "NSArray+Map.h"

@implementation MMAbstractSidebarContentView{
    NSMutableDictionary* currentRowForAlbum;
    MMEmptyCollectionViewCell* emptyView;
    
    CGPoint lastAlbumScrollOffset;
    CGPoint lastPhotoScrollOffset;
}

@synthesize delegate;
@synthesize isShowing;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        currentRowForAlbum = [NSMutableDictionary dictionary];
        albumListScrollView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[self albumsLayout]];
        albumListScrollView.dataSource = self;
        albumListScrollView.delegate = self;
        albumListScrollView.backgroundColor = [UIColor clearColor];
        
        [albumListScrollView registerClass:[MMDisplayAssetGroupCell class] forCellWithReuseIdentifier:@"MMDisplayAssetGroup"];
        
        photoListScrollView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[self photosLayout]];
        photoListScrollView.dataSource = self;
        photoListScrollView.alpha = 0;
        photoListScrollView.backgroundColor = [UIColor clearColor];
        
        [photoListScrollView registerClass:[MMDisplayAssetCell class] forCellWithReuseIdentifier:@"MMDisplayAssetCell"];
        [photoListScrollView registerClass:[MMPhotosPermissionCell class] forCellWithReuseIdentifier:@"MMPhotosPermissionCell"];

        currentAlbum = nil;
        
        [self addSubview:albumListScrollView];
        [self addSubview:photoListScrollView];
        
        
        NSObject * transparent = (NSObject *) [[UIColor colorWithWhite:0 alpha:0] CGColor];
        NSObject * opaque = (NSObject *) [[UIColor colorWithWhite:0 alpha:1] CGColor];
        
        CALayer * maskLayer = [CALayer layer];
        maskLayer.frame = CGRectMake(self.bounds.origin.x-100,0,self.bounds.size.width+200,self.bounds.size.height);
        
        CAGradientLayer * gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(maskLayer.bounds.origin.x, 0,
                                         maskLayer.bounds.size.width, self.bounds.size.height);
        
        gradientLayer.colors = [NSArray arrayWithObjects: transparent, opaque, nil];
        
        CGFloat fadePercentage = kTopBottomMargin / self.bounds.size.height;
        // Set percentage of scrollview that fades at top & bottom
        gradientLayer.locations = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:0],
                                   [NSNumber numberWithFloat:fadePercentage], nil];
        
        [maskLayer addSublayer:gradientLayer];
        self.layer.mask = maskLayer;

    }
    return self;
}

-(UICollectionViewLayout*) albumsLayout{
    return [[MMAssetGroupListLayout alloc] init];
}

-(UICollectionViewLayout*) photosLayout{
    return [[MMAssetListLayout alloc] initForRotation:[self idealRotationForOrientation]];
}

-(CGFloat) rowHeight{
    return ceilf(self.bounds.size.width / 2);
}

-(BOOL) hasPermission{
    return YES;
}

-(NSString*) messageTextWhenEmpty{
    return @"Nothing to show";
}

-(void) updateEmptyErrorMessage{
    if(isShowing && ![self collectionView:albumListScrollView numberOfItemsInSection:0] && [self hasPermission]){
        if(!emptyView){
            emptyView = [[MMEmptyCollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width)];
        }
        [emptyView setText:[self messageTextWhenEmpty]];
        [self addSubview:emptyView];
        [emptyView updatePhotoRotation:NO];
    }else if(emptyView){
        [emptyView removeFromSuperview];
        emptyView = nil;
    }
}

-(void) reset:(BOOL)animated{
    albumListScrollView.hidden = NO;
    albumListScrollView.alpha = 1;
    photoListScrollView.alpha = 0;
    [self updateEmptyErrorMessage];
}

-(void) show:(BOOL)animated{
    BOOL needsReload = !isShowing;
    [[MMPhotoManager sharedInstance] initializeAlbumCache];
    [self updatePhotoRotation:NO];
    isShowing = YES;
    [self updateEmptyErrorMessage];
    if(needsReload){
        [albumListScrollView reloadData];
        albumListScrollView.contentOffset = lastAlbumScrollOffset;
    }
}

-(void) hide:(BOOL)animated{
    lastAlbumScrollOffset = albumListScrollView.contentOffset;
    lastPhotoScrollOffset = photoListScrollView.contentOffset;
    isShowing = NO;
}

-(void) killMemory{
//    [albumListScrollView killMemory];
    if(![self isShowing]){
        // only clear the cache if its been a while (?)
        [photoListScrollView reloadData];
        [self updateEmptyErrorMessage];
        lastPhotoScrollOffset = CGPointZero;
        lastAlbumScrollOffset = CGPointZero;
    }
}

#pragma mark - MMPhotoManagerDelegate

-(void) doneLoadingPhotoAlbums{
    [self updateEmptyErrorMessage];
    if(albumListScrollView.alpha){
        [albumListScrollView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MMDisplayAssetGroupCell* groupCell = obj;
            [groupCell loadedPreviewPhotos];
        }];
//        [albumListScrollView reloadData];
//        albumListScrollView.contentOffset = lastAlbumScrollOffset;
    }
    if(photoListScrollView.alpha){
        [photoListScrollView reloadData];
        photoListScrollView.contentOffset = lastPhotoScrollOffset;
    }
}

-(void) albumUpdated:(MMPhotoAlbum *)album{
    NSInteger index = [self indexForAlbum:album];
    NSArray* visibleItems = [[albumListScrollView indexPathsForVisibleItems] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSIndexPath* indexPath = evaluatedObject;
        if(indexPath.row == index){
            return YES;
        }
        return NO;
    }]];
    if(visibleItems){
//        NSLog(@"update album row: %@", visibleItems);
    }
}

#pragma mark - Row Management

-(NSInteger) indexForAlbum:(MMPhotoAlbum*)album{
    @throw kAbstractMethodException;
}

-(MMPhotoAlbum*) albumAtIndex:(NSInteger)index{
    @throw kAbstractMethodException;
}


#pragma mark - Rotation

-(CGFloat) idealRotationForOrientation{
    CGFloat visiblePhotoRotation = 0;
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
    return visiblePhotoRotation;
}

-(void) updatePhotoRotation:(BOOL)animated{
    void(^updateVisibleRowsWithRotation)() = ^{
        if(albumListScrollView.alpha){
            [albumListScrollView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if([obj respondsToSelector:@selector(updatePhotoRotation)]){
                    [obj updatePhotoRotation];
                }
            }];
        }
    };
    
    if(animated){
        [[NSThread mainThread] performBlock:^{
            [photoListScrollView reloadData];
            [photoListScrollView setCollectionViewLayout:[self photosLayout] animated:YES];
            [UIView animateWithDuration:.3 animations:updateVisibleRowsWithRotation];
        }];
    }else{
        [[NSThread mainThread] performBlock:^{
            [photoListScrollView reloadData];
            [photoListScrollView setCollectionViewLayout:[self photosLayout] animated:NO];
            updateVisibleRowsWithRotation();
        }];
    }
    [emptyView updatePhotoRotation:animated];
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[albumListScrollView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj resetDeleteAdjustment:YES];
    }];
}

-(NSString*) description{
    @throw kAbstractMethodException;
}



#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(collectionView == albumListScrollView){
        return 0;
    }else{
        // we're only working with the photoListScrollView. there's no albums here
        if([self hasPermission]){
            return currentAlbum.numberOfPhotos;
        }else{
            return 1;
        }
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return isShowing ? 1 : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == albumListScrollView){
        MMDisplayAssetGroupCell* albumCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MMDisplayAssetGroup" forIndexPath:indexPath];
        albumCell.album = [self albumAtIndex:indexPath.row];
        return albumCell;
    }else{
        if([self hasPermission]){
            MMDisplayAssetCell* photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MMDisplayAssetCell" forIndexPath:indexPath];
            [photoCell loadPhotoFromAlbum:currentAlbum atIndex:indexPath.row forVisibleIndex:indexPath.row];
            photoCell.delegate = self;
            return photoCell;
        }else{
            MMPhotosPermissionCell* permission = [collectionView dequeueReusableCellWithReuseIdentifier:@"MMPhotosPermissionCell" forIndexPath:indexPath];
            permission.shouldShowLine = NO;
            [permission showPhotosSteps];
            return permission;
        }
    }
}

#pragma mark - MMSinglePhotoCollectionViewCellDelegate

-(void) pictureTakeWithCamera:(UIImage*)img fromView:(MMBorderedCamView*)cameraView{
    [delegate pictureTakeWithCamera:img fromView:cameraView];
}

-(void) photoWasTapped:(MMDisplayAsset *)asset
              fromView:(MMBufferedImageView *)bufferedImage
          withRotation:(CGFloat)rotation{
    MMAssetListLayout* layout = (MMAssetListLayout*) photoListScrollView.collectionViewLayout;
    [delegate photoWasTapped:asset fromView:bufferedImage withRotation:(rotation + layout.rotation) fromContainer:self];
}


#pragma mark - UICollectionViewDelegate

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == albumListScrollView){
        [self setUserInteractionEnabled:NO];
        currentAlbum = [self albumAtIndex:indexPath.row];
        photoListScrollView.contentOffset = CGPointZero;
        
        [photoListScrollView reloadData];
        
        [UIView animateWithDuration:.3 animations:^{
            albumListScrollView.alpha = 0;
            photoListScrollView.alpha = 1;
        }  completion:^(BOOL finished){
            [self setUserInteractionEnabled:YES];
            albumListScrollView.hidden = YES;
        }];
    }
}


@end
