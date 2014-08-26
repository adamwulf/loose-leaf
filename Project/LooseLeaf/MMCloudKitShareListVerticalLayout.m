//
//  MMCloudKitShareListVerticalLayout.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/26/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitShareListVerticalLayout.h"
#import "Constants.h"

@implementation MMCloudKitShareListVerticalLayout{
    BOOL shouldFlip;
}

-(id) initWithFlip:(BOOL)_shouldFlip{
    if(self = [super init]){
        shouldFlip = _shouldFlip;
    }
    return self;
}

-(CGFloat) buttonWidth{
    return self.collectionView.bounds.size.width / 4;
}

-(CGSize)collectionViewContentSize{
    NSInteger numItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    return CGSizeMake(self.collectionView.bounds.size.width, numItems * [self buttonWidth]);
}

-(UICollectionViewLayoutAttributes*) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes* ret = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat height = [self buttonWidth];
    CGFloat width = self.collectionView.bounds.size.width;
    ret.frame = CGRectMake(0, indexPath.row * height, width, height);
    
    if(shouldFlip){
        int index = indexPath.row;
        index = floorf(indexPath.row/4)*4 + (4 - indexPath.row % 4 - 1);
        ret.frame = CGRectMake(0, index * height, width, height);
        ret.transform = CGAffineTransformMakeRotation(M_PI);
    }
    return ret;
}


-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSInteger numItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    NSInteger firstIndex = floorf(rect.origin.y / [self buttonWidth]);
    NSInteger lastIndex = floorf((rect.origin.y + rect.size.height) / [self buttonWidth]);
    if(shouldFlip){
        // round to sections of 4
        firstIndex -= firstIndex % 4;
        lastIndex += 4 - lastIndex % 4;
    }
    
    NSMutableArray* attrs = [NSMutableArray array];
    for (int index = firstIndex; index <= lastIndex; index++) {
        if(index >= 0 && index < numItems){
            [attrs addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]]];
        }
    }
    return attrs;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}

-(CGPoint) targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset{
    NSLog(@"target offset: %f %f", proposedContentOffset.x, proposedContentOffset.y);
    NSLog(@"current offset: %f %f", self.collectionView.contentOffset.x, self.collectionView.contentOffset.y);
//    return [super targetContentOffsetForProposedContentOffset:proposedContentOffset];
    return self.collectionView.contentOffset;
}



@end
