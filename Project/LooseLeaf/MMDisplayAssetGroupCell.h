//
//  MMAlbumCell.h
//  LooseLeaf
//
//  Created by Adam Wulf on 3/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMPhotoAlbum.h"

@interface MMDisplayAssetGroupCell : UICollectionViewCell

@property (nonatomic, strong) MMPhotoAlbum* album;
@property (readonly) NSArray* bufferedImageViews;
@property (nonatomic) CGFloat squishFactor;

-(void) loadedPreviewPhotos;

-(void) updatePhotoRotation;

-(void) adjustForDelete:(CGFloat)adjustment;

// returns YES if should immediately delete, NO otherwise
-(BOOL) finishSwipeToDelete;

@end
