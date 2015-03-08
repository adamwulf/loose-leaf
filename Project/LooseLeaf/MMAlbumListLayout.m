//
//  MMAlbumListLayout.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMAlbumListLayout.h"

@implementation MMAlbumListLayout{
    NSMutableArray* deleteIndexPaths;
    NSMutableArray* insertIndexPaths;
}

-(id) init{
    if(self = [super init]){
        // noop
    }
    return self;
}

-(CGFloat) albumRowHeight{
    return self.collectionView.bounds.size.width / 2;
}

-(CGSize)collectionViewContentSize{
    NSInteger numSections = self.collectionView.numberOfSections;
    if(!numSections){
        return CGSizeZero;
    }
    
    NSInteger numberOfAlbums = [self.collectionView numberOfItemsInSection:0];
    return CGSizeMake(self.collectionView.bounds.size.width, ceil(numberOfAlbums) * [self albumRowHeight]);
}

-(UICollectionViewLayoutAttributes*) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes* ret = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat x = 0;
    CGFloat y = indexPath.row * [self albumRowHeight];
    
    CGRect b = CGRectMake(0, 0, self.collectionView.bounds.size.width, [self albumRowHeight]);
    ret.bounds = b;
    CGPoint c = CGPointMake(x + ret.bounds.size.width/2, y + ret.bounds.size.height/2);
    ret.center = c;
    
    return ret;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    if(!self.collectionView.numberOfSections){
        return @[];
    }
    
    NSMutableArray* attrs = [NSMutableArray array];
    
    NSInteger startRow = MAX(floorf(rect.origin.y / [self albumRowHeight]), 0);
    NSInteger maxRow = ceilf((rect.origin.y + rect.size.height) / [self albumRowHeight]);
    
    NSInteger maxAlbumCount = [self.collectionView numberOfItemsInSection:0];
    
    for(NSInteger index = startRow; index < maxRow && index < maxAlbumCount; index++){
        [attrs addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]]];
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

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    // Keep track of insert and delete index paths
    [super prepareForCollectionViewUpdates:updateItems];
    
    deleteIndexPaths = [NSMutableArray array];
    insertIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *update in updateItems)
    {
        if (update.updateAction == UICollectionUpdateActionDelete)
        {
            [deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        }
        else if (update.updateAction == UICollectionUpdateActionInsert)
        {
            [insertIndexPaths addObject:update.indexPathAfterUpdate];
        }
    }
}

-(UICollectionViewLayoutAttributes*) finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
    UICollectionViewLayoutAttributes* attrs = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    if([deleteIndexPaths containsObject:itemIndexPath]){
        attrs.center = CGPointMake(attrs.center.x-attrs.bounds.size.width, attrs.center.y);
    }
    return attrs;
}


@end
