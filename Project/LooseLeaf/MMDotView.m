//
//  MMDotView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/27/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMDotView.h"


@implementation MMDotView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    UIBezierPath* oval = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, 1, 1)];

    [[UIColor blackColor] setFill];
    [oval fill];
}


@end
