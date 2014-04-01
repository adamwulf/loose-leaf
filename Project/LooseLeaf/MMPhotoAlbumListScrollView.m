//
//  MMPhotoAlbumListScrollView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPhotoAlbumListScrollView.h"

@implementation MMPhotoAlbumListScrollView{
    CGFloat rowHeight;
}

@synthesize rowHeight;

- (id)initWithFrame:(CGRect)frame withRowHeight:(CGFloat)_rowHeight
{
    self = [super initWithFrame:frame];
    if (self) {
        rowHeight = _rowHeight;
        // Initialization code
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}


@end
