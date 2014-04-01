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
    CGFloat topBottomMargin;
}

@synthesize rowHeight;

- (id)initWithFrame:(CGRect)frame withRowHeight:(CGFloat)_rowHeight andMargins:(CGFloat)topBottomMargin{
    self = [super initWithFrame:frame];
    if (self) {
        rowHeight = _rowHeight;
        // Initialization code
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

-(NSInteger) rowIndexForY:(CGFloat)y{
    NSInteger currIndex = floorf((y - topBottomMargin) / self.rowHeight);
    return currIndex;
}

-(BOOL) rowIndexIsVisible:(NSInteger)index{
    CGFloat minY = topBottomMargin + index * self.rowHeight;
    CGFloat maxY = minY + self.rowHeight;
    if(minY < self.contentOffset.y + self.bounds.size.height &&
       maxY > self.contentOffset.y){
        return YES;
    }
    return NO;
}

@end
