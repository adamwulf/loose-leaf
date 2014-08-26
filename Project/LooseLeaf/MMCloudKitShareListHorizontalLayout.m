//
//  MMCloudKitShareListHorizontalLayout.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/26/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitShareListHorizontalLayout.h"
#import "Constants.h"

@implementation MMCloudKitShareListHorizontalLayout

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
    ret.bounds = CGRectMake(0, 0, width, height);
    ret.center = CGPointMake(width/2, indexPath.row * height + height/2);
    
    int transformIndex = indexPath.row % 4; // 4 cells rotate together
    
    if(transformIndex == 0){
        ret.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(-1.5*[self buttonWidth], +1.5*[self buttonWidth]), -M_PI_2);
    }else if(transformIndex == 1){
        ret.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(-0.5*[self buttonWidth], +0.5*[self buttonWidth]), -M_PI_2);
    }else if(transformIndex == 2){
        ret.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(+0.5*[self buttonWidth], -0.5*[self buttonWidth]), -M_PI_2);
    }else{
        ret.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(+1.5*[self buttonWidth], -1.5*[self buttonWidth]), -M_PI_2);
    }
    
    return ret;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSInteger numItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    NSInteger firstIndex = floorf(rect.origin.y / [self buttonWidth]);
    NSInteger lastIndex = floorf((rect.origin.y + rect.size.height) / [self buttonWidth]);
    // round to sections of 4
    firstIndex -= firstIndex % 4;
    lastIndex += 4 - firstIndex % 4;
    
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

@end
