//
//  MMScrapBezelMenuView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/5/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapBezelMenuView.h"

@implementation MMScrapBezelMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIView* background = [[UIView alloc] initWithFrame:self.bounds];
        background.opaque = NO;
        background.clipsToBounds = YES;
        background.layer.cornerRadius = 10;
        background.backgroundColor = [UIColor blackColor];
        background.alpha = .7;
        [self addSubview:background];
        self.clipsToBounds = YES;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


@end
