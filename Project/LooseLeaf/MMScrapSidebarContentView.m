//
//  MMScrapBezelMenuView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/5/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapSidebarContentView.h"
#import "MMScrapView.h"
#import "MMScrapSidebarButton.h"
#import "MMTrashButton.h"
#import "Constants.h"

#define kColumnSideMargin 10.0
#define kColumnTopMargin 10.0

typedef struct RowOfScrapsInSidebar{
    CGFloat topY;
    CGFloat height;
} RowOfScrapsInSidebar;

@implementation MMScrapSidebarContentView{
    UIScrollView* scrollView;
    NSInteger columnCount;
    
    int countOfStoredRowData;
    RowOfScrapsInSidebar* rowData;
    
    MMTrashButton* trashButton;
}

@synthesize delegate;
@synthesize columnCount;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.opaque = NO;
        scrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.contentSize = CGSizeMake(self.bounds.size.width, 500);
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(6, 0, 6, 0);
        scrollView.alwaysBounceVertical = YES;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        
        columnCount = 2;
        
        // for clarity
        self.clipsToBounds = YES;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void) setColumnCount:(NSInteger)_columnCount{
    columnCount = _columnCount;
    if([self.delegate isVisible]){
        [self prepareContentView];
    }
}

-(void) viewDidHide{
    for (MMScrapSidebarButton* subview in [[scrollView subviews] copy]) {
        if([subview isKindOfClass:[MMScrapSidebarButton class]]){
            if([[self.delegate scrapsInSidebar] count] > kMaxScrapsInBezel){
                [subview.scrap.state unloadCachedScrapPreview];
            }
            [subview removeFromSuperview];
        }
    }
}

-(void) prepareContentView{
    CheckMainThread;
    
    // determine how many rows of scraps that we'll need
    NSArray* allScraps = [self.delegate scrapsInSidebar];
    int rowCount = ceilf((float)[allScraps count] / columnCount);
    CGFloat maxDimOfScrap = (self.bounds.size.width - kColumnSideMargin) / columnCount;
    
    // make sure we have data to store the attributes per row
    if(rowCount > countOfStoredRowData){
        if(rowData){
            free(rowData);
        }
        countOfStoredRowData = rowCount;
        rowData = malloc(countOfStoredRowData * sizeof(RowOfScrapsInSidebar));
    }
    
    // calculate the height we'll need for each
    // scrap in the sidebar as we scroll
    CGFloat currentYOffset = 5*kColumnTopMargin;
    for(int row = 0; row<rowCount; row++){
        // determine the index and scrap objects
        CGFloat maxHeightOfScrapsInRow = 0;
        for(int index = row * (int)columnCount; index < row * columnCount + columnCount; index++){
            if(index < [allScraps count]){
                MMScrapView* currentScrap = [allScraps objectAtIndex:index];
                CGSize sizeOfCellForScrap = [MMScrapSidebarButton sizeOfRowForScrap:currentScrap forWidth:maxDimOfScrap];
                CGFloat heightOfCurrScrap = sizeOfCellForScrap.height + kColumnTopMargin;
                if(heightOfCurrScrap > maxHeightOfScrapsInRow){
                    maxHeightOfScrapsInRow = heightOfCurrScrap;
                }
            }
        }
        rowData[row].height = maxHeightOfScrapsInRow;
        rowData[row].topY = currentYOffset;
        currentYOffset += maxHeightOfScrapsInRow;
    }
    
    if(!trashButton){
        trashButton = [[MMTrashButton alloc] initWithFrame:CGRectMake(0, 0, kHeightOfImportTypeButton, kHeightOfImportTypeButton)];
        [trashButton addTarget:self action:@selector(tappedOnTrashButton:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:trashButton];
    }
    
    trashButton.center = CGPointMake(CGRectGetWidth(scrollView.bounds)/2, [self contentHeight] - 50);

    // set our content offset and make sure it's still valid
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, [self contentHeight]);
    if(scrollView.contentOffset.y + scrollView.bounds.size.height > [self contentHeight]){
        CGFloat newOffset = [self contentHeight] - scrollView.bounds.size.height;
        if(newOffset < 0) newOffset = 0;
        scrollView.contentOffset = CGPointMake(0, newOffset);
    }
    [self scrollViewDidScroll:scrollView];
}

-(CGFloat) contentHeight{
    if(rowData){
        RowOfScrapsInSidebar lastRow = rowData[countOfStoredRowData-1];
        return lastRow.topY + lastRow.height + 4*kColumnTopMargin + 100; // add 100 for our trash button
    }
    return 0;
}

-(void) flashScrollIndicators{
    [scrollView flashScrollIndicators];
}

#pragma mark - UIButton

-(void) tappedOnScrapButton:(MMScrapSidebarButton*) button{
    [self.delegate didTapOnScrapFromMenu:button.scrap];
}

-(void) tappedOnTrashButton:(MMTrashButton*)button{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Delete All Scraps" message:@"Do you want to delete all scraps from the sidebar?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"trash");
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

-(int) rowForYOffset:(CGFloat)yOffset{
    if(!countOfStoredRowData) return 0;
    if(yOffset < 0) return 0;
    // first, let's take our best guess
    // at which row is showing:
    CGFloat averageRowHeight = [self contentHeight] / countOfStoredRowData;
    int probableRow = floorf(yOffset / averageRowHeight);
    
    while (rowData[probableRow].topY > yOffset) {
        probableRow--;
    }
    while(rowData[probableRow].topY + rowData[probableRow].height < yOffset){
        probableRow++;
    }
    return probableRow < 0 ? 0 : probableRow;
}

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView{
    CheckMainThread;
    // just bail if we dont have any scraps
    if(!countOfStoredRowData) return;
    
    // determine the variables that will affect
    // our layout
    NSArray* allScraps = [self.delegate scrapsInSidebar];
    CGFloat sizeOfScrap = (self.bounds.size.width - kColumnSideMargin) / columnCount;
    int row = [self rowForYOffset:scrollView.contentOffset.y];
    int maxRow = [self rowForYOffset:scrollView.contentOffset.y + scrollView.bounds.size.height] + 1;
    
    // very basic for now. just remove all old scraps
    NSInteger minVisibleRow = NSIntegerMax;
    NSInteger maxVisibleRow = NSIntegerMin;
    for (MMScrapSidebarButton* subview in [[scrollView subviews] copy]) {
        if([subview isKindOfClass:[MMScrapSidebarButton class]]){
            if(subview.rowNumber < row || subview.rowNumber > maxRow){
                [subview.scrap.state unloadCachedScrapPreview];
                [subview removeFromSuperview];
            }else if(subview.rowNumber < minVisibleRow){
                minVisibleRow = subview.rowNumber;
            }else if(subview.rowNumber > maxVisibleRow){
                maxVisibleRow = subview.rowNumber;
            }
        }
    }
    
    while(row < countOfStoredRowData && rowData[row].topY < scrollView.contentOffset.y + scrollView.bounds.size.height){
        // add views while we have some and while they're visible
        // determine the index and scrap objects
        CGFloat maxHeightOfScrapsInRow = 0;
        NSMutableArray* currRow = [NSMutableArray array];
        if(row < minVisibleRow || row > maxVisibleRow){
            for(int index = row * (int)columnCount; index < row * columnCount + columnCount; index++){
                if(index < [allScraps count]){
                    MMScrapView* currentScrap = [allScraps objectAtIndex:index];
                    // place the left scrap. it should have 10 px left margin
                    // (left margin already accounted for with our bounds)
                    // and 10px in the middle between it at the right
                    CGFloat x = (index - row * columnCount) * (sizeOfScrap + kColumnSideMargin);
                    MMScrapSidebarButton* leftScrapButton = [[MMScrapSidebarButton alloc] initWithFrame:CGRectMake(x, rowData[row].topY, sizeOfScrap, sizeOfScrap)];
                    leftScrapButton.rowNumber = row;
                    [leftScrapButton addTarget:self action:@selector(tappedOnScrapButton:) forControlEvents:UIControlEventTouchUpInside];
                    leftScrapButton.scrap = currentScrap;
                    [currentScrap.state loadCachedScrapPreview];
                    [scrollView addSubview:leftScrapButton];
                    CGFloat heightOfCurrScrap = leftScrapButton.bounds.size.height + kColumnTopMargin;
                    if(heightOfCurrScrap > maxHeightOfScrapsInRow){
                        maxHeightOfScrapsInRow = heightOfCurrScrap;
                    }
                    [currRow addObject:leftScrapButton];
                }
            }
            // center row items vertically
            for(MMScrapSidebarButton* button in currRow){
                CGRect fr = button.frame;
                fr.origin.y += (maxHeightOfScrapsInRow - fr.size.height) / 2;
                button.frame = fr;
            }
        }
        row++;
    }
}


@end
