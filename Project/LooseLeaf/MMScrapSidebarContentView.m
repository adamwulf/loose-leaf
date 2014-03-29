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


#define kColumnSideMargin 10.0
#define kColumnTopMargin 10.0

@implementation MMScrapSidebarContentView{
    UIScrollView* scrollView;
    NSInteger columnCount;
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
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.contentSize = CGSizeMake(self.bounds.size.width, 500);
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(6, 0, 6, 0);
        scrollView.alwaysBounceVertical = YES;
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



// TODO: add caching / optimize
-(void) prepareContentView{
    // very basic for now. just remove all old scraps
    for (UIView* subview in [[scrollView subviews] copy]) {
        if([subview isKindOfClass:[MMScrapSidebarButton class]]){
            [subview removeFromSuperview];
        }
    }
    
    // determine the variables that will affect
    // our layout
    NSArray* allScraps = [self.delegate scraps];
    int rowCount = ceilf([allScraps count] / columnCount);
    CGFloat sizeOfScrap = (self.bounds.size.width - kColumnSideMargin) / columnCount;
    
    
    // then add a new uiimage for every scrap
    CGFloat contentHeight = 5*kColumnTopMargin;
    for(int row = 0; row<rowCount; row++){
        // determine the index and scrap objects
        CGFloat maxHeightOfScrapsInRow = 0;
        NSMutableArray* currRow = [NSMutableArray array];
        for(int index = row * columnCount; index < row * columnCount + columnCount; index++){
            if(index < [allScraps count]){
                MMScrapView* currentScrap = [allScraps objectAtIndex:index];
                // place the left scrap. it should have 10 px left margin
                // (left margin already accounted for with our bounds)
                // and 10px in the middle between it at the right
                CGFloat x = (index - row * columnCount) * (sizeOfScrap + kColumnSideMargin);
                MMScrapSidebarButton* leftScrapButton = [[MMScrapSidebarButton alloc] initWithFrame:CGRectMake(x, contentHeight, sizeOfScrap, sizeOfScrap)];
                [leftScrapButton addTarget:self action:@selector(tappedOnScrapButton:) forControlEvents:UIControlEventTouchUpInside];
                leftScrapButton.scrap = currentScrap;
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
        contentHeight += maxHeightOfScrapsInRow;
    }
    // only adding 4, b/c the row in the for loop
    // above added 1 buffer at the end of the row
    contentHeight += 4*kColumnTopMargin;
    
    // set our content offset and make sure it's still valid
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, contentHeight);
    if(scrollView.contentOffset.y + scrollView.bounds.size.height > contentHeight){
        CGFloat newOffset = contentHeight - scrollView.bounds.size.height;
        if(newOffset < 0) newOffset = 0;
        scrollView.contentOffset = CGPointMake(0, newOffset);
    }
}

-(void) flashScrollIndicators{
    [scrollView flashScrollIndicators];
}

#pragma mark - UIButton

-(void) tappedOnScrapButton:(MMScrapSidebarButton*) button{
    [self.delegate didTapOnScrapFromMenu:button.scrap];
}

@end
