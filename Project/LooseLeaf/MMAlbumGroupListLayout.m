//
//  MMPDFListLayout.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/10/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMAlbumGroupListLayout.h"


@implementation MMAlbumGroupListLayout

- (CGFloat)albumRowHeight {
    return self.collectionView.bounds.size.width * 2 / 5;
}


@end
