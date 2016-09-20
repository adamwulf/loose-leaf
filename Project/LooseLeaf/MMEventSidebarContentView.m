//
//  MMEventSidebarContentView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/9/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMEventSidebarContentView.h"
#import "MMAlbumGroupListLayout.h"
#import "MMPhotosListLayout.h"
#import "MMPhotoManager.h"


@implementation MMEventSidebarContentView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)reset:(BOOL)animated {
    if ([self hasPermission]) {
        [super reset:animated];
    } else {
        albumListScrollView.alpha = 0;
        photoListScrollView.alpha = 1;
    }
}

- (BOOL)hasPermission {
    return [MMPhotoManager hasPhotosPermission];
}

- (UICollectionViewLayout*)albumsLayout {
    return [[MMAlbumGroupListLayout alloc] init];
}

- (UICollectionViewLayout*)photosLayout {
    return [[MMPhotosListLayout alloc] initForRotation:[self idealRotationForOrientation]];
}

- (NSString*)messageTextWhenEmpty {
    return @"No Events to show";
}

#pragma mark - Row Management

- (NSInteger)indexForAlbum:(MMPhotoAlbum*)album {
    if (album.type == ALAssetsGroupAlbum) {
        return [[[MMPhotoManager sharedInstance] events] indexOfObject:album];
    }
    return -1;
}

- (MMPhotoAlbum*)albumAtIndex:(NSInteger)index {
    if (index < [[[MMPhotoManager sharedInstance] events] count]) {
        return [[[MMPhotoManager sharedInstance] events] objectAtIndex:index];
    }
    return nil;
}

#pragma mark - MMCachedRowsScrollViewDataSource

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == albumListScrollView) {
        return [[[MMPhotoManager sharedInstance] events] count];
    } else {
        return [super collectionView:collectionView numberOfItemsInSection:section];
    }
}

#pragma mark - Description

- (NSString*)description {
    return @"Photo Events";
}


@end
