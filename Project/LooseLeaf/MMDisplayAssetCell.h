//
//  MMDisplayAssetCell.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/18/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDisplayAssetCellDelegate.h"
#import "MMDisplayAssetGroup.h"


@interface MMDisplayAssetCell : UICollectionViewCell

@property (nonatomic, assign, readonly) NSInteger index;
@property (nonatomic, readonly) MMDisplayAssetGroup* album;
@property (nonatomic, weak) NSObject<MMDisplayAssetCellDelegate>* delegate;
@property (nonatomic, assign) CGFloat rotation;

- (void)loadPhotoFromAlbum:(MMDisplayAssetGroup*)album atIndex:(NSInteger)photoIndex;

@end
