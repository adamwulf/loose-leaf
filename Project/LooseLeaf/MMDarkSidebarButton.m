//
//  MMDarkSidebarButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/12/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMDarkSidebarButton.h"


@implementation MMDarkSidebarButton

+ (UIColor*)borderColor {
    return [UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:0.45];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.borderColor = [MMDarkSidebarButton borderColor];
    }
    return self;
}


@end
