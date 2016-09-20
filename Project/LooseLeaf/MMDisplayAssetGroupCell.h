//
//  MMAlbumCell.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDisplayAssetGroup.h"
#import "MMDisplayAssetGroupCellDelegate.h"


@interface MMDisplayAssetGroupCell : UICollectionViewCell {
    MMDisplayAssetGroup* album;
    CGFloat initialX[5];
    CGFloat finalX[5];
    CGFloat initRot[5];
    CGFloat rotAdj[5];
    CGFloat adjY[5];
    CGFloat visiblePhotoRotation;
}

@property (nonatomic, strong) MMDisplayAssetGroup* album;
@property (readonly) NSArray* bufferedImageViews;
@property (nonatomic) CGFloat squishFactor;
@property (nonatomic, weak) NSObject<MMDisplayAssetGroupCellDelegate>* delegate;

- (void)loadedPreviewPhotos;

- (void)updatePhotoRotation;

- (void)resetDeleteAdjustment:(BOOL)animated;

- (void)adjustForDelete:(CGFloat)adjustment;

// returns YES if should immediately delete, NO otherwise
- (BOOL)finishSwipeToDelete;

@end
