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
    NSInteger indexOfPage = [self.superview.subviews indexOfObject:self];
    NSInteger rowOfPage = floor(indexOfPage / 3);
    return rowOfPage;
}

-(NSInteger) columnInListView{
    NSInteger indexOfPage = [self.superview.subviews indexOfObject:self];
    NSInteger columnOfPage = indexOfPage % 3;
    return columnOfPage;
}

-(CGRect) frameForListViewGivenRowHeight:(CGFloat)columnHeight andColumnWidth:(CGFloat)columnWidth{
    CGFloat bufferWidth = kListPageZoom * columnWidth;
    CGFloat finalX = bufferWidth + bufferWidth * self.columnInListView + columnWidth * self.columnInListView;
    CGFloat finalY = bufferWidth + bufferWidth * self.rowInListView + columnHeight * self.rowInListView;
    CGFloat finalWidth = columnWidth;
    CGFloat finalHeight = columnHeight;
    
    //
    // ok, set the new frame that we'll return
    CGRect newFrame = CGRectZero;
    newFrame.origin.x = finalX;
    newFrame.origin.y = finalY;
    newFrame.size.width = finalWidth;
    newFrame.size.height = finalHeight;

    return newFrame;
}

@end
