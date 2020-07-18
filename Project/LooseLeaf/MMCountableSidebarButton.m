//
//  MMCountableSidebarButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/6/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMCountableSidebarButton.h"


@implementation MMCountableSidebarButton

@synthesize view;
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

+ (CGFloat)scaleOfRowForView:(UIView<MMUUIDView>*)view forWidth:(CGFloat)width {
    CGFloat maxDim = MAX(MAX(view.frame.size.width, view.frame.size.height), 1);
    return width / maxDim;
}

+ (CGSize)sizeOfRowForView:(UIView<MMUUIDView>*)view forWidth:(CGFloat)width {
    CGFloat scale = [self scaleOfRowForView:view forWidth:width];
    CGSize s = CGSizeMake(view.frame.size.width * scale, view.frame.size.height * scale);
    if (s.width < s.height) {
        s.width = s.height;
    }
    return s;
}

- (void)setView:(UIView<MMUUIDView>*)_view {
    view = _view;

    CGRect fr = self.frame;
    fr.size = [[self class] sizeOfRowForView:view forWidth:self.bounds.size.width];
    self.frame = fr;

    // remove anything in our button
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    // reset scrap to it's normal transform
    view.scale = view.scale;

    UIView* transformView = [[UIView alloc] initWithFrame:view.bounds];
    transformView.opaque = YES;

    [transformView addSubview:view];
    view.center = transformView.center;

    [self addSubview:transformView];
    CGFloat scale = [[self class] scaleOfRowForView:view forWidth:self.bounds.size.width];
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
