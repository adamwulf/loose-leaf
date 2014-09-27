//
//  MMPhotoListLayout.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/18/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPhotoAlbumListLayout.h"
#import "CaptureSessionManager.h"
#import "MMPermissionCameraCollectionViewCell.h"
#import "Constants.h"

@implementation MMPhotoAlbumListLayout{
    CGFloat rotation;
}

@synthesize rotation;

-(id) initForRotation:(CGFloat)_rotation{
    if(self = [super init]){
        rotation = _rotation;
    }
    return self;
}

-(BOOL) hasSectionForCamera{
    return self.collectionView.numberOfSections > 1;
}

-(NSInteger) sectionIndexForPhotos{
    return self.hasSectionForCamera ? 1 : 0;
}

-(CGFloat) photoRowHeight{
    return self.collectionView.bounds.size.width / 2;
}

-(CGFloat) cameraRowHeight{
    if(self.hasSectionForCamera){
        if ([CaptureSessionManager hasCamera] && [CaptureSessionManager hasCameraPermission]) {
            return [self photoRowHeight] * 2 + kCameraMargin;
        }else{
            return [self photoRowHeight] * [MMPermissionCameraCollectionViewCell idealPhotoRowHeight] + kCameraMargin;
        }
    }
    return 0;
}

-(CGSize)collectionViewContentSize{
    if(!self.collectionView.numberOfSections){
        return CGSizeZero;
    }
    
    NSInteger numberOfPhotos = [self.collectionView numberOfItemsInSection:self.sectionIndexForPhotos];
    
    return CGSizeMake(self.collectionView.bounds.size.width, [self cameraRowHeight] + ceil(numberOfPhotos/2.0) * [self photoRowHeight]);
}

-(UICollectionViewLayoutAttributes*) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes* ret = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat width = self.collectionView.bounds.size.width;
    
    if(indexPath.section == 0 && self.hasSectionForCamera){
        // camera
        ret.bounds = CGRectMake(0, 0, width, [self cameraRowHeight]);
        ret.center = CGPointMake(width/2, [self cameraRowHeight]/2);
        ret.transform = CGAffineTransformIdentity;
        return ret;
    }

    NSInteger indexOfPhoto = indexPath.row;

    NSInteger rowNumber = floorf(indexOfPhoto / 2.0);
    NSInteger colNumber = indexOfPhoto % 2;
    
    CGFloat x = colNumber * width/2;
    CGFloat y = rowNumber * [self photoRowHeight];
    
    CGRect b = CGRectMake(0, 0, width/2, [self photoRowHeight]);
    ret.bounds = b;
    ret.center = CGPointMake(x + ret.bounds.size.width/2, [self cameraRowHeight] + y + ret.bounds.size.height/2);
    ret.transform = CGAffineTransformMakeRotation(rotation);
    
    return ret;
}


-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    if(!self.collectionView.numberOfSections){
        return @[];
    }
    
    NSMutableArray* attrs = [NSMutableArray array];

    if(self.hasSectionForCamera){
        if(rect.origin.y < [self cameraRowHeight]){
            // should show camera
            [attrs addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
            rect.size.height -= rect.origin.y;
            rect.origin.y = 0;
        }else{
            rect.origin.y -= [self cameraRowHeight];
        }
    }

    NSInteger startRow = floorf(rect.origin.y / [self photoRowHeight]);
    NSInteger maxRow = ceilf((rect.origin.y + rect.size.height) / [self photoRowHeight]);
    
    NSInteger maxPhotos = [self.collectionView numberOfItemsInSection:self.sectionIndexForPhotos];
    
    for(NSInteger index = startRow; index < maxRow; index++){
        NSInteger leftPhoto = index * 2;
        NSInteger rightPhoto = leftPhoto + 1;
        
        if(leftPhoto >= 0 && leftPhoto < maxPhotos){
            [attrs addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:leftPhoto inSection:self.sectionIndexForPhotos]]];
        }
        if(rightPhoto >= 0 && rightPhoto < maxPhotos){
            [attrs addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:rightPhoto inSection:self.sectionIndexForPhotos]]];
        }
    }
    return attrs;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}

-(CGPoint) targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset{
    // keep our content offset
    return self.collectionView.contentOffset.y == 0 ? self.collectionView.contentOffset : proposedContentOffset;
}

-(void) prepareForTransitionFromLayout:(UICollectionViewLayout *)oldLayout{
    // noop
}

-(UICollectionViewLayoutAttributes*) initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
}

-(UICollectionViewLayoutAttributes*) finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
}

@end
