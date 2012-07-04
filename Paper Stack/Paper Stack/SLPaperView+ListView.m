//
//  SLPaperView+ListView.m
//  scratchpaper
//
//  Created by Adam Wulf on 7/3/12.
//
//

#import "SLPaperView+ListView.h"

@implementation SLPaperView (ListView)

-(NSInteger) rowInListView{
    NSInteger indexOfPage = [self.delegate indexOfPageInCompleteStack:self];
    NSInteger rowOfPage = floor(indexOfPage / kNumberOfColumnsInListView);
    return rowOfPage;
}

-(NSInteger) columnInListView{
    NSInteger indexOfPage = [self.delegate indexOfPageInCompleteStack:self];
    NSInteger columnOfPage = indexOfPage % kNumberOfColumnsInListView;
    return columnOfPage;
}

-(CGRect) frameForListViewGivenRowHeight:(CGFloat)rowHeight andColumnWidth:(CGFloat)columnWidth{
    CGFloat bufferWidth = kListPageZoom * columnWidth;
    
    CGRect newFrame = CGRectZero;
    newFrame.origin.x = bufferWidth + bufferWidth * self.columnInListView + columnWidth * self.columnInListView;
    newFrame.origin.y = bufferWidth + bufferWidth * self.rowInListView + rowHeight * self.rowInListView;
    newFrame.size.width = columnWidth;
    newFrame.size.height = rowHeight;

    return newFrame;
}

@end
