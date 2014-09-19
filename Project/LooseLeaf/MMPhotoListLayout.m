//
//  MMPhotoListLayout.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/18/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPhotoListLayout.h"
#import "Constants.h"

@implementation MMPhotoListLayout{
    UIDynamicAnimator *dynamicAnimator;
}

-(id) init{
    if(self = [super init]){
        // noop
        self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    }
    return self;
}

-(CGFloat) photoRowHeight{
    return self.collectionView.bounds.size.width / 2;
}

-(CGFloat) cameraRowHeight{
    return [self photoRowHeight] * 2 + kCameraMargin;
}

-(CGSize)collectionViewContentSize{
    
    NSInteger numberOfPhotos = [self.collectionView numberOfItemsInSection:1];
    
    return CGSizeMake(self.collectionView.bounds.size.width, [self cameraRowHeight] + ceil(numberOfPhotos/2.0) * [self photoRowHeight]);
}

-(UICollectionViewLayoutAttributes*) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes* ret = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat width = self.collectionView.bounds.size.width;
    
    if(indexPath.section == 0){
        // camera
        ret.bounds = CGRectMake(0, 0, width, [self cameraRowHeight]);
        ret.center = CGPointMake(width/2, [self cameraRowHeight]/2);
        ret.transform = CGAffineTransformIdentity;
        return ret;
    }

    NSInteger maxPhotos = [self.collectionView numberOfItemsInSection:1];
    NSInteger indexOfPhoto = maxPhotos - indexPath.row - 1;

    NSInteger rowNumber = floorf(indexOfPhoto / 2.0);
    NSInteger colNumber = indexOfPhoto % 2;
    
    CGFloat x = colNumber * width/2;
    CGFloat y = rowNumber * [self photoRowHeight];
    
    CGRect b = CGRectMake(0, 0, width/2, [self photoRowHeight]);
    ret.bounds = b;
    ret.center = CGPointMake(x + ret.bounds.size.width/2, [self cameraRowHeight] + y + ret.bounds.size.height/2);
    ret.transform = CGAffineTransformIdentity;
    
//    NSLog(@"layout for %d at index %d", (int) indexOfPhoto, (int)indexPath.row);
    
    return ret;
}


-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attrs = [NSMutableArray array];

    if(rect.origin.y < [self cameraRowHeight]){
        // should show camera
        [attrs addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
        rect.size.height -= rect.origin.y;
        rect.origin.y = 0;
    }else{
        rect.origin.y -= [self cameraRowHeight];
    }

    NSInteger startRow = floorf(rect.origin.y / [self photoRowHeight]);
    NSInteger maxRow = ceilf((rect.origin.y + rect.size.height) / [self photoRowHeight]);
    
    NSInteger maxPhotos = [self.collectionView numberOfItemsInSection:1];
    
    for(NSInteger index = startRow; index < maxRow; index++){
        NSInteger leftPhoto = index * 2;
        NSInteger rightPhoto = leftPhoto + 1;
        
        if(leftPhoto < maxPhotos){
            [attrs addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:maxPhotos - leftPhoto - 1 inSection:1]]];
        }
        if(rightPhoto < maxPhotos){
            [attrs addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:maxPhotos - rightPhoto - 1 inSection:1]]];
        }
    }
    
    NSLog(@"asking for rect from %f to %f (%d to %d)", rect.origin.y, rect.origin.y + rect.size.height, (int) startRow, (int) maxRow);

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
