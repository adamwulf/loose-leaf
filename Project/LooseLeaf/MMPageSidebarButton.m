//
//  MMPageSidebarButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/27/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMPageSidebarButton.h"
#import "MMEditablePaperView.h"


@implementation MMPageSidebarButton {
    MMEditablePaperView* page;
}

@synthesize page;
@synthesize rowNumber;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = YES;
        self.clipsToBounds = YES;
    }
    return self;
}


+ (CGFloat)scaleOfRowForPage:(MMEditablePaperView*)page forWidth:(CGFloat)width {
    CGFloat maxDim = MAX(MAX(page.frame.size.width, page.frame.size.height), 1);
    return width / maxDim;
}

+ (CGSize)sizeOfRowForPage:(MMEditablePaperView*)page forWidth:(CGFloat)width {
    CGFloat scale = [MMPageSidebarButton scaleOfRowForPage:page forWidth:width];
    CGSize s = CGSizeMake(page.frame.size.width * scale, page.frame.size.height * scale);
    if (s.width < s.height) {
        s.width = s.height;
    }
    return s;
}

- (void)setPage:(MMEditablePaperView*)_page {
    page = _page;

    CGRect fr = self.frame;
    fr.size = [MMPageSidebarButton sizeOfRowForPage:page forWidth:self.bounds.size.width];
    self.frame = fr;

    // remove anything in our button
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    // reset scrap to it's normal transform
    page.scale = page.scale;

    UIView* transformView = [[UIView alloc] initWithFrame:page.bounds];
    transformView.opaque = YES;

    [transformView addSubview:page];
    page.center = transformView.center;

    [self addSubview:transformView];
    CGFloat scale = [MMPageSidebarButton scaleOfRowForPage:page forWidth:self.bounds.size.width];
    transformView.transform = CGAffineTransformMakeScale(scale, scale);
    transformView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);

    [self addSubview:transformView];
}


#pragma mark - Touch Ownership

/**
 * these two methods make sure that this scrap container view
 * can never intercept any touch input. instead it will
 * effectively pass through this view to the views behind it
 */
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent*)event {
    if ([super hitTest:point withEvent:event]) {
        return self;
    }
    return nil;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    return [super pointInside:point withEvent:event];
}


@end
