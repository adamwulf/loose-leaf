//
//  MMPageBubbleButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/29/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMPageBubbleButton.h"


@implementation MMPageBubbleButton

@synthesize view;
@synthesize originalViewScale;
@synthesize scale;

+ (CGFloat)idealScaleForView:(MMEditablePaperView*)page {
    return .4;
}

+ (CGAffineTransform)idealTransformForView:(MMEditablePaperView*)page {
    // aim to get the border into 36 px
    CGFloat scale = [MMPageBubbleButton idealScaleForView:page];
    return CGAffineTransformMakeScale(scale, scale);
}

- (void)setView:(MMEditablePaperView*)_view {
    view = _view;
    if (!_view) {
        //        DebugLog(@"killing scrap bubble, setting to nil scrap");
        return;
    }

    [self addSubview:view];
    view.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    view.transform = [[self class] idealTransformForView:view];

    view.center = CGRectGetMidPoint([self bounds]);
}

@end
