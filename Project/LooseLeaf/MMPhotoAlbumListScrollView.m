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
@synthesize dataSource;

- (id)initWithFrame:(CGRect)frame withRowHeight:(CGFloat)_rowHeight andMargins:(CGFloat)_topBottomMargin{
    self = [super initWithFrame:frame];
    if (self) {
        rowHeight = _rowHeight;
        topBottomMargin = _topBottomMargin;
        // Initialization code
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.delegate = self;
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

-(void) refreshVisibleRows{
    // remove invisible rows
    for(UIView* row in self.subviews){
        if(!row.hidden && ![self rowIndexIsVisible:row.tag]){
            row.hidden = YES;
            [self.dataSource prepareRowForReuse:row forScrollView:self];
            [self.dataSource.currentRowAtIndex removeObjectForKey:[NSNumber numberWithInt:row.tag]];
            [self.dataSource.bufferOfUnusedAlbumRows addObject:row];
        }
    }
    
    // loop through visible albums
    // and make sure row is at the right place
    CGFloat currOffset = self.contentOffset.y;
    while([self rowIndexIsVisible:[self rowIndexForY:currOffset]]){
        NSInteger currIndex = [self rowIndexForY:currOffset];
        if(currIndex >= 0){
            // load the row
            [self.dataSource rowAtIndex:currIndex];
        }
        currOffset += self.rowHeight;
    }
    
    NSInteger totalAlbumCount = [self.dataSource numberOfRowsFor:self];
    CGFloat contentHeight = 2*topBottomMargin + self.rowHeight * totalAlbumCount;
    self.contentSize = CGSizeMake(self.bounds.size.width, contentHeight);
}


#pragma mark - UIScrollViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)_scrollView{
    [self refreshVisibleRows];
}


@end
