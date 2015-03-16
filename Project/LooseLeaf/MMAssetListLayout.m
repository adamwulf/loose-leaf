//
//  MMPhotoListLayout.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/18/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMAssetListLayout.h"
#import "CaptureSessionManager.h"
#import "MMPhotosPermissionCell.h"
#import "MMPhotoManager.h"
#import "Constants.h"

@implementation MMAssetListLayout{
    CGFloat rotation;
}

@synthesize rotation;

-(id) initForRotation:(CGFloat)_rotation{
    if(self = [super init]){
        rotation = _rotation;
    }
    return self;
}

-(NSInteger) sectionIndexForPhotos{
    return 0;
}

-(CGFloat) photoRowHeight{
    return self.collectionView.bounds.size.width / 2;
}

-(CGFloat) cameraRowHeight{
    return 0;
}

-(CGSize)collectionViewContentSize{
    NSInteger numSections = self.collectionView.numberOfSections;
    if(!numSections){
        return CGSizeZero;
    }
    NSInteger numberOfPhotos = [self.collectionView numberOfItemsInSection:self.sectionIndexForPhotos];
    return CGSizeMake(self.collectionView.bounds.size.width, ceil(numberOfPhotos/2.0) * [self photoRowHeight]);
}

-(UICollectionViewLayoutAttributes*) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes* ret = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat width = self.collectionView.bounds.size.width - 2*kWidthOfSidebarButtonBuffer;

    NSInteger indexOfPhoto = indexPath.row;

    NSInteger rowNumber = floorf(indexOfPhoto / 2.0);
    NSInteger colNumber = indexOfPhoto % 2;
    
    CGFloat x = colNumber * width/2 + 2*kWidthOfSidebarButtonBuffer;
    CGFloat y = rowNumber * [self photoRowHeight];
    
    CGRect b = CGRectMake(0, 0, width/2, [self photoRowHeight]);
    ret.bounds = b;
    CGPoint c = CGPointMake(x + ret.bounds.size.width/2, y + ret.bounds.size.height/2);
    ret.center = c;
    ret.transform = CGAffineTransformMakeRotation(rotation);
    
    return ret;
}


-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    if(!self.collectionView.numberOfSections){
        return @[];
    }
    
    NSMutableArray* attrs = [NSMutableArray array];

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
