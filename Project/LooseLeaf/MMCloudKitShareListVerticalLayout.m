//
//  MMCloudKitShareListVerticalLayout.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/26/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCloudKitShareListVerticalLayout.h"
#import "Constants.h"


@implementation MMCloudKitShareListVerticalLayout {
    UICollectionViewLayout* previousLayout;
    BOOL shouldFlip;
}

- (id)initWithFlip:(BOOL)_shouldFlip {
    if (self = [super init]) {
        shouldFlip = _shouldFlip;
    }
    return self;
}

- (CGFloat)buttonWidth {
    return self.collectionView.bounds.size.width / 4;
}

- (NSInteger)entireRowCount {
    NSInteger ret = 0;
    for (int section = 0; section < [self.collectionView numberOfSections]; section++) {
        ret += [self.collectionView numberOfItemsInSection:section];
    }
    return ret;
}

- (CGSize)collectionViewContentSize {
    NSInteger numItems = [self entireRowCount];
    CGFloat sizeOfPeopleRows = (numItems - 1) * [self buttonWidth];
    CGFloat sizeOfInviteButton = 1 * 150;
    return CGSizeMake(self.collectionView.bounds.size.width - 2 * kWidthOfSidebarButtonBuffer, sizeOfPeopleRows + sizeOfInviteButton);
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath*)indexPath {
    UICollectionViewLayoutAttributes* ret = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

    BOOL isLastCell = indexPath.section == [self.collectionView numberOfSections] - 1 &&
        indexPath.row == [self.collectionView numberOfItemsInSection:indexPath.section] - 1;

    CGFloat contactHeight = [self buttonWidth];
    CGFloat width = self.collectionView.bounds.size.width - 2 * kWidthOfSidebarButtonBuffer;
    CGFloat cellHeight = isLastCell ? 150.0 : contactHeight;

    ret.bounds = CGRectMake(0, 0, width, isLastCell ? 150 : cellHeight);

    NSInteger numRowsInPrevSections = 0;
    for (int i = 0; i < indexPath.section; i++) {
        numRowsInPrevSections += [self.collectionView numberOfItemsInSection:i];
    }

    NSInteger trueIndexInList = numRowsInPrevSections + indexPath.row;

    if (shouldFlip) {
        ret.center = CGPointMake(width / 2, trueIndexInList * contactHeight + cellHeight / 2);
        ret.transform = CGAffineTransformMakeRotation(-M_PI);
    } else {
        ret.center = CGPointMake(width / 2, trueIndexInList * contactHeight + cellHeight / 2);
        ret.transform = CGAffineTransformIdentity;
    }
    return ret;
}


- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger firstIndex = floorf(rect.origin.y / [self buttonWidth]);
    NSInteger lastIndex = floorf((rect.origin.y + rect.size.height) / [self buttonWidth]);
    if (shouldFlip) {
        // round to sections of 4
        firstIndex -= firstIndex % 4;
        lastIndex += 4 - lastIndex % 4;
    }

    NSInteger totalCount = 0;
    NSMutableArray* attrs = [NSMutableArray array];
    for (NSInteger section = 0; section < self.collectionView.numberOfSections; section++) {
        for (NSInteger index = 0; index < [self.collectionView numberOfItemsInSection:section]; index++) {
            if (totalCount >= firstIndex && totalCount <= lastIndex) {
                [attrs addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section]]];
            }
            totalCount++;
        }
    }
    return attrs;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    // keep our content offset
    return self.collectionView.contentOffset.y == 0 ? self.collectionView.contentOffset : proposedContentOffset;
}

- (void)prepareForTransitionFromLayout:(UICollectionViewLayout*)oldLayout {
    // save our previous layout so that
    // we can animate from it as we come into view
    previousLayout = oldLayout;
}

- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath*)itemIndexPath {
    if (previousLayout) {
        return [previousLayout layoutAttributesForItemAtIndexPath:itemIndexPath];
    } else {
        return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    }
}

- (UICollectionViewLayoutAttributes*)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath*)itemIndexPath {
    return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
}


@end
