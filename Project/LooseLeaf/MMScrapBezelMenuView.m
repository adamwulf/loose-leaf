//
//  MMScrapBezelMenuView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/5/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapBezelMenuView.h"
#import "MMScrapView.h"
#import "MMScrapMenuButton.h"

@implementation MMScrapBezelMenuView{
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

-(void) prepareMenu{
    CGFloat sizeOfScrap = self.bounds.size.width;
    CGFloat sizeOfBuffer = 10;
    CGFloat contentHeight =  [[self.delegate scraps] count] * (sizeOfScrap + sizeOfBuffer) + sizeOfBuffer;
    scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, contentHeight);
    if(scrollView.contentOffset.y + scrollView.bounds.size.height > contentHeight){
        CGFloat newOffset = contentHeight - scrollView.bounds.size.height;
        if(newOffset < 0) newOffset = 0;
        scrollView.contentOffset = CGPointMake(0, newOffset);
    }
    
    // very basic for now. just remove all old scraps
    for (UIView* subview in [[scrollView subviews] copy]) {
        if([subview isKindOfClass:[MMScrapMenuButton class]]){
            [subview removeFromSuperview];
        }
    }
    
    // then add a new uiimage for every scrap
    // TODO: add caching / optimize
    
    NSInteger index = 0;
    CGFloat height = sizeOfBuffer;
    for (MMScrapView* scrap in [self.delegate.scraps reverseObjectEnumerator]) {
        CGFloat x = 0;
        MMScrapMenuButton* imgV = [[MMScrapMenuButton alloc] initWithFrame:CGRectMake(x, height, sizeOfScrap, sizeOfScrap)];
        [imgV addTarget:self action:@selector(tappedOnScrapButton:) forControlEvents:UIControlEventTouchUpInside];
        imgV.scrap = scrap;
        [scrollView addSubview:imgV];
        index++;
        height += imgV.bounds.size.height + sizeOfBuffer;
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
