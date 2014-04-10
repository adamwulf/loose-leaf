//
//  MMPhotoAlbumListScrollView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMCachedRowsScrollView.h"

@implementation MMCachedRowsScrollView{
    CGFloat rowHeight;
    CGFloat topBottomMargin;
    NSMutableDictionary* currentRowAtIndex;
    NSMutableArray* bufferOfUnusedRows;
}

@synthesize rowHeight;
@synthesize dataSource;

- (id)initWithFrame:(CGRect)frame withRowHeight:(CGFloat)_rowHeight andMargins:(CGFloat)_topBottomMargin{
    self = [super initWithFrame:frame];
    if (self) {
        rowHeight = _rowHeight;
        topBottomMargin = _topBottomMargin;
        currentRowAtIndex = [NSMutableDictionary dictionary];
        bufferOfUnusedRows = [NSMutableArray array];
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

-(UIView*) rowAtIndex:(NSInteger) index{
    if(index < 0) return nil; // no negative index
    UIView* row = [currentRowAtIndex objectForKey:[NSNumber numberWithInt:index]];
    if(!row){
        CGRect fr = CGRectMake(0, topBottomMargin + index * self.rowHeight, self.bounds.size.width, self.rowHeight);
        BOOL needsAddedSubview = NO;
        if([bufferOfUnusedRows count]){
            row = [bufferOfUnusedRows lastObject];
            [bufferOfUnusedRows removeLastObject];
            row.frame = fr;
        }else{
            needsAddedSubview = YES;
        }
        // we might not have the row object yet. so tell
        // our datasource to update the row and/or create
        // it if need be.
        row = [self.dataSource updateRow:row atIndex:index forFrame:fr forScrollView:self];
        // rows might be nil if our datasource wants
        // the row's space to be there but no content
        // to show up.
        // so we need to double check that we actually have
        // a row here to work with
        if(needsAddedSubview){
            [self addSubview:row];
        }
        // now we definitely have the row, so set its tag and cache it
        row.tag = index;
        [currentRowAtIndex setObject:row forKey:[NSNumber numberWithInt:index]];
        if([self rowIndexIsVisible:index]){
            row.hidden = NO;
        }else{
            row.hidden = YES;
        }
    }
    return row;
}

-(void) enumerateVisibleRowsWithBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block{
    CGFloat currOffset = self.contentOffset.y;
    NSInteger numberOfRows = [self.dataSource numberOfRowsFor:self];
    while([self rowIndexIsVisible:[self rowIndexForY:currOffset]] && [self rowIndexForY:currOffset] < numberOfRows){
        NSInteger currIndex = [self rowIndexForY:currOffset];
        BOOL stop = NO;
        if(currIndex >= 0){
            // load the row
            UIView* row = [self rowAtIndex:currIndex];
            block(row, currIndex, &stop);
        }
        currOffset += self.rowHeight;
    }
}

-(void) refreshVisibleRows{
    NSInteger totalRowCount = [self.dataSource numberOfRowsFor:self];

    // remove invisible rows
    for(UIView* row in self.subviews){
        if(!row.hidden && (![self rowIndexIsVisible:row.tag] || row.tag >= totalRowCount)){
            if([self.dataSource prepareRowForReuse:row forScrollView:self]){
                row.hidden = YES;
                [currentRowAtIndex removeObjectForKey:[NSNumber numberWithInt:row.tag]];
                [bufferOfUnusedRows addObject:row];
            }
        }
    }
    
    // loop through visible rowss
    // and make sure row is at the right place
    CGFloat currOffset = self.contentOffset.y;
    while([self rowIndexIsVisible:[self rowIndexForY:currOffset]]){
        NSInteger currIndex = [self rowIndexForY:currOffset];
        if(currIndex < totalRowCount){
            UIView* row = nil;
            // load the row
            row = [self rowAtIndex:currIndex];
        }
        currOffset += self.rowHeight;
    }
    
    CGFloat contentHeight = 2*topBottomMargin + self.rowHeight * totalRowCount;
    self.contentSize = CGSizeMake(self.bounds.size.width, contentHeight);
}


#pragma mark - UIScrollViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)_scrollView{
    [self refreshVisibleRows];
}


@end
