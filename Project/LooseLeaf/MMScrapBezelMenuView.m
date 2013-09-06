//
//  MMScrapBezelMenuView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/5/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapBezelMenuView.h"

@implementation MMScrapBezelMenuView{
    UIScrollView* scrollView;
}



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

        scrollView = [[UIScrollView alloc] initWithFrame:CGRectInset(background.bounds, -15, -15)];
        scrollView.opaque = NO;
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = YES;
        
        scrollView.contentSize = CGSizeMake(self.bounds.size.width, 500);
        scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(24, 0, 24, 24);
        [self addSubview:scrollView];
    }
    return self;
}

-(void) setAlpha:(CGFloat)alpha{
    [super setAlpha:alpha];
    [scrollView flashScrollIndicators];
}

@end
