//
//  MMPhotoRowView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/1/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPhotoRowView.h"

@implementation MMPhotoRowView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 1;
    }
    return self;
}

@end
