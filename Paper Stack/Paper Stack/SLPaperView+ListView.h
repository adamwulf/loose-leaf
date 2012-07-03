//
//  SLPaperView+ListView.h
//  scratchpaper
//
//  Created by Adam Wulf on 7/3/12.
//
//

#import "SLPaperView.h"

@interface SLPaperView (ListView)

@property (nonatomic, readonly) NSInteger rowInListView;
@property (nonatomic, readonly) NSInteger columnInListView;
-(CGRect) frameForListViewGivenRowHeight:(CGFloat)columnHeight andColumnWidth:(CGFloat)columnWidth;

@end
