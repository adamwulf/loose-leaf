//
//  SLPaperView+ListView.m
//  scratchpaper
//
//  Created by Adam Wulf on 7/3/12.
//
//

#import "SLPaperView+ListView.h"


@interface SLPaperView (ListView_Private)

-(NSInteger) rowInListViewGivenIndex:(NSInteger) indexOfPage;

-(NSInteger) columnInListViewGivenIndex:(NSInteger) indexOfPage;

@end


@implementation SLPaperView (ListView)

-(NSInteger) rowInListViewGivenIndex:(NSInteger) indexOfPage{
    NSInteger rowOfPage = floor(indexOfPage / kNumberOfColumnsInListView);
    return rowOfPage;
}

-(NSInteger) columnInListViewGivenIndex:(NSInteger) indexOfPage{
    NSInteger columnOfPage = indexOfPage % kNumberOfColumnsInListView;
    return columnOfPage;
}

-(NSInteger) rowInListView{
    NSInteger indexOfPage = [self.delegate indexOfPageInCompleteStack:self];
    return [self rowInListViewGivenIndex:indexOfPage];
}

-(NSInteger) columnInListView{
    NSInteger indexOfPage = [self.delegate indexOfPageInCompleteStack:self];
    return [self columnInListViewGivenIndex:indexOfPage];
}

-(CGRect) frameForListViewGivenRowHeight:(CGFloat)rowHeight andColumnWidth:(CGFloat)columnWidth{
    CGFloat bufferWidth = kListPageZoom * columnWidth;
    
    NSInteger indexOfPage = [self.delegate indexOfPageInCompleteStack:self];
    NSInteger column = [self columnInListViewGivenIndex:indexOfPage];
    NSInteger row = [self rowInListViewGivenIndex:indexOfPage];
    CGRect newFrame = CGRectZero;
    newFrame.origin.x = bufferWidth + bufferWidth * column + columnWidth * column;
    newFrame.origin.y = bufferWidth + bufferWidth * row + rowHeight * row;
    newFrame.size.width = columnWidth;
    newFrame.size.height = rowHeight;

    return newFrame;
}

@end
