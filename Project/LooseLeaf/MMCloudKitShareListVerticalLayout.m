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
    UICollectionViewLayout* previousLayout;
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
    ret.bounds = CGRectMake(0, 0, width, height);
    
    if(shouldFlip){
        // flip the index of each section of 4
        int index = floorf(indexPath.row/4)*4 + (4 - indexPath.row % 4 - 1);

        //
        // need to account for the last square of items
        // so that its flush with the previous
        // when it's upside down, even if it doesn't
        // contain 4 items.
        NSInteger numItems = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
        if(index >= numItems - numItems%4){
            int offset = 4 - numItems%4;
            if(offset != 4){
                index -= offset;
            }
        }
        
        // set the center + rotation
        ret.center = CGPointMake(width/2, index * height + height/2);
        ret.transform = CGAffineTransformMakeRotation(-M_PI);
    }else{
        ret.center = CGPointMake(width/2, indexPath.row * height + height/2);
        ret.transform = CGAffineTransformIdentity;
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
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
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
    // keep our content offset
    return self.collectionView.contentOffset.y == 0 ? self.collectionView.contentOffset : proposedContentOffset;
}

-(void) prepareForTransitionFromLayout:(UICollectionViewLayout *)oldLayout{
    // save our previous layout so that
    // we can animate from it as we come into view
    previousLayout = oldLayout;
}

-(UICollectionViewLayoutAttributes*) initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
    if(previousLayout){
        return [previousLayout layoutAttributesForItemAtIndexPath:itemIndexPath];
    }else{
        return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    }
}

-(UICollectionViewLayoutAttributes*) finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
}


@end
