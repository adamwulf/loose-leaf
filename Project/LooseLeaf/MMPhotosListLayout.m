//
//  MMPhotosListLayout.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/16/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMPhotosListLayout.h"
#import "MMPhotoManager.h"
#import "MMPhotosPermissionCell.h"
#import "Constants.h"

@implementation MMPhotosListLayout

-(CGFloat) cameraRowHeight{
    if(![self hasPermission]){
        return [self photoRowHeight] * [MMPhotosPermissionCell idealPhotoRowHeight] + kCameraMargin;
    }
    return 0;
}

-(BOOL) hasPermission{
    return [MMPhotoManager hasPhotosPermission];
}

-(CGSize)collectionViewContentSize{
    NSInteger numSections = self.collectionView.numberOfSections;
    if(!numSections){
        return CGSizeZero;
    }
    if(![MMPhotoManager hasPhotosPermission]){
        return CGSizeMake(self.collectionView.bounds.size.width, [self cameraRowHeight]);
    }
    return [super collectionViewContentSize];
}

-(UICollectionViewLayoutAttributes*) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes* ret = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    if(![MMPhotoManager hasPhotosPermission]){
        CGFloat width = self.collectionView.bounds.size.width - 2*kWidthOfSidebarButtonBuffer;
        // don't have photo permissions
        ret.bounds = CGRectMake(0, 0, width, [self cameraRowHeight]);
        ret.center = CGPointMake(self.collectionView.bounds.size.width/2 + kWidthOfSidebarButtonBuffer, kWidthOfSidebarButtonBuffer + [self cameraRowHeight]/2);
        ret.transform = CGAffineTransformIdentity;
        return ret;
    }
    
    return [super layoutAttributesForItemAtIndexPath:indexPath];
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    if(!self.collectionView.numberOfSections){
        return @[];
    }
    
    NSMutableArray* attrs = [NSMutableArray array];
    
    // add the camera attributes
    if(![self hasPermission]){
        // should show camera
        [attrs addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
    }else{
        // add the rest of the attributes
        [attrs addObjectsFromArray:[super layoutAttributesForElementsInRect:rect]];
    }
    
    return attrs;
}


@end
