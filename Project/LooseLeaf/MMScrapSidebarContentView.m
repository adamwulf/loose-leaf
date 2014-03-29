//
//  MMScrapBezelMenuView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/5/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapSidebarContentView.h"
#import "MMScrapView.h"
#import "MMScrapMenuButton.h"


#define kColumnMargin 10.0

@implementation MMScrapSidebarContentView{
    UIScrollView* scrollView;
}

@synthesize delegate;

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
        [self addSubview:scrollView];
        
        // for clarity
        self.clipsToBounds = YES;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}




// TODO: add caching / optimize
-(void) prepareContentView{

    // very basic for now. just remove all old scraps
    for (UIView* subview in [[scrollView subviews] copy]) {
        if([subview isKindOfClass:[MMScrapMenuButton class]]){
            [subview removeFromSuperview];
        }
    }
    
    // determine the variables that will affect
    // our layout
    NSArray* allScraps = [self.delegate scraps];
    int rowCount = ceilf([allScraps count] / 2.0);
    CGFloat sizeOfScrap = (self.bounds.size.width - kColumnMargin) / 2;
    CGFloat sizeOfBuffer = 10;
    
    
    // then add a new uiimage for every scrap
    CGFloat contentHeight = sizeOfBuffer;
    for(int row = 0; row<rowCount; row++){
        // determine the index and scrap objects
        int leftIndex = row * 2;
        int rightIndex = leftIndex + 1;
        MMScrapView* leftScrap = [allScraps objectAtIndex:leftIndex];
        MMScrapView* rightScrap = nil;
        if(rightIndex < [allScraps count]){
            rightScrap = [allScraps objectAtIndex:rightIndex];
        }
        
        // place the left scrap. it should have 10 px left margin
        // (left margin already accounted for with our bounds)
        // and 10px in the middle between it at the right
        MMScrapMenuButton* leftScrapButton = [[MMScrapMenuButton alloc] initWithFrame:CGRectMake(0, contentHeight, sizeOfScrap, sizeOfScrap)];
        [leftScrapButton addTarget:self action:@selector(tappedOnScrapButton:) forControlEvents:UIControlEventTouchUpInside];
        leftScrapButton.scrap = leftScrap;
        [scrollView addSubview:leftScrapButton];
        CGFloat maxHeightOfBothScraps = leftScrapButton.bounds.size.height + sizeOfBuffer;

        if(rightScrap){
            // place the right scrap. it should have 10 px left margin
            // (left margin already accounted for with our bounds)
            // and 10px in the middle between it at the right
            CGFloat x = self.bounds.size.width - sizeOfScrap;
            MMScrapMenuButton* rightScrapButton = [[MMScrapMenuButton alloc] initWithFrame:CGRectMake(x, contentHeight, sizeOfScrap, sizeOfScrap)];
            [rightScrapButton addTarget:self action:@selector(tappedOnScrapButton:) forControlEvents:UIControlEventTouchUpInside];
            rightScrapButton.scrap = rightScrap;
            [scrollView addSubview:rightScrapButton];
            CGFloat oldMaxHeight = maxHeightOfBothScraps;
            CGFloat rightHeight = rightScrapButton.bounds.size.height + sizeOfBuffer;
            if(maxHeightOfBothScraps < rightHeight){
                maxHeightOfBothScraps = rightHeight;
                // i'm taller, so move the left guy down slightly to center him
                CGFloat heightDiff = (maxHeightOfBothScraps - oldMaxHeight) / 2;
                CGRect fr = leftScrapButton.frame;
                fr.origin.y += heightDiff;
                leftScrapButton.frame = fr;
            }else{
                // left side is taller, center the right guy
                CGFloat heightDiff = (maxHeightOfBothScraps - rightHeight) / 2;
                CGRect fr = rightScrapButton.frame;
                fr.origin.y += heightDiff;
                rightScrapButton.frame = fr;
            }
        }
        contentHeight += maxHeightOfBothScraps;
    }
    
    // set our content offset and make sure it's still valid
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, contentHeight);
    if(scrollView.contentOffset.y + scrollView.bounds.size.height > contentHeight){
        CGFloat newOffset = contentHeight - scrollView.bounds.size.height;
        if(newOffset < 0) newOffset = 0;
        scrollView.contentOffset = CGPointMake(0, newOffset);
    }
}

-(void) setHidden:(BOOL)hidden{
    [super setHidden:hidden];
}

-(void) setAlpha:(CGFloat)alpha{
    [super setAlpha:alpha];
}

-(void) removeFromSuperview{
    [super removeFromSuperview];
}

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
}

-(void) flashScrollIndicators{
    [scrollView flashScrollIndicators];
}

#pragma mark - UIButton

-(void) tappedOnScrapButton:(MMScrapMenuButton*) button{
    [self.delegate didTapOnScrapFromMenu:button.scrap];
}

@end
