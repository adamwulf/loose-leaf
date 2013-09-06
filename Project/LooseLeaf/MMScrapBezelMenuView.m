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
        UIBezierPath* trianglePath = [UIBezierPath bezierPath];
        [trianglePath moveToPoint:CGPointMake(0, 0)];
        [trianglePath addLineToPoint:CGPointMake(20, 15)];
        [trianglePath addLineToPoint:CGPointMake(0, 30)];
        [trianglePath closePath];

        
        __block UIColor* whiteColor = [[UIColor whiteColor] colorWithAlphaComponent:.9];
        __block UIColor* blackColor = [[UIColor blackColor] colorWithAlphaComponent:.7];
        
        UIView* backgroundW = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width - 20, self.bounds.size.height)];
        backgroundW.opaque = NO;
        backgroundW.clipsToBounds = YES;
        backgroundW.layer.cornerRadius = 10;
        backgroundW.backgroundColor = whiteColor;
        [self addSubview:backgroundW];

        UIView* triangleW = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 20, self.bounds.size.height/2-75, 20, 30)];
        triangleW.opaque = NO;
        triangleW.clipsToBounds = YES;
        triangleW.backgroundColor = whiteColor;
        CAShapeLayer* mask = [CAShapeLayer layer];
        mask.path = trianglePath.CGPath;
        triangleW.layer.mask = mask;
        [self addSubview:triangleW];
        
        UIView* background = [[UIView alloc] initWithFrame:backgroundW.frame];
        background.opaque = NO;
        background.clipsToBounds = YES;
        background.layer.cornerRadius = 10;
        background.backgroundColor = blackColor;
        [self addSubview:background];
        
        UIView* triangle = [[UIView alloc] initWithFrame:triangleW.frame];
        triangle.opaque = NO;
        triangle.clipsToBounds = YES;
        triangle.backgroundColor = blackColor;
        mask = [CAShapeLayer layer];
        mask.path = trianglePath.CGPath;
        triangle.layer.mask = mask;
        [self addSubview:triangle];
        
        
        self.clipsToBounds = YES;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];

        scrollView = [[UIScrollView alloc] initWithFrame:CGRectInset(background.bounds, 15, 15)];
        scrollView.opaque = NO;
        scrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = YES;
        
        scrollView.contentSize = CGSizeMake(self.bounds.size.width, 500);
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(6, 0, 6, 0);
        [self addSubview:scrollView];
    }
    return self;
}

-(void) prepareMenu{
    CGFloat sizeOfScrap = 100;
    CGFloat sizeOfBuffer = 10;
    CGFloat contentHeight =  ([[self.delegate scraps] count] - 1) / 2 * (sizeOfScrap + sizeOfBuffer) + (sizeOfScrap + sizeOfBuffer) + sizeOfBuffer;
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
    for (MMScrapView* scrap in self.delegate.scraps) {
        CGFloat step = (scrollView.bounds.size.width - 2*sizeOfScrap) / 3;
        CGFloat x = step * ((index % 2) + 1) + (index % 2) * sizeOfScrap;
        CGFloat y = index / 2 * (sizeOfScrap + sizeOfBuffer) + sizeOfBuffer;
        MMScrapMenuButton* imgV = [[MMScrapMenuButton alloc] initWithFrame:CGRectMake(x, y, sizeOfScrap, sizeOfScrap)];
        [imgV addTarget:self action:@selector(tappedOnScrapButton:) forControlEvents:UIControlEventTouchUpInside];
        imgV.scrap = scrap;
        [scrollView addSubview:imgV];
        index++;
    }
    
}

-(void) setAlpha:(CGFloat)alpha{
    [super setAlpha:alpha];
}

-(void) flashScrollIndicators{
    [scrollView flashScrollIndicators];
}

#pragma mark - UIButton

-(void) tappedOnScrapButton:(MMScrapMenuButton*) button{
    [self.delegate didTapOnScrapFromMenu:button.scrap];
}

@end
