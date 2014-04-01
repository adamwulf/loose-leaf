//
//  MMPhotoRowView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/1/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPhotoRowView.h"
#import "MMBufferedImageView.h"
#import "Constants.h"

@implementation MMPhotoRowView{
    MMBufferedImageView* leftImageView;
    MMBufferedImageView* rightImageView;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        CGFloat maxDim = self.bounds.size.height;

        leftImageView = [[MMBufferedImageView alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, maxDim, maxDim), 10, 10)];
        leftImageView.transform = CGAffineTransformMakeRotation(RandomPhotoRotation);
        [self addSubview:leftImageView];

        rightImageView = [[MMBufferedImageView alloc] initWithFrame:CGRectInset(CGRectMake(self.bounds.size.width - maxDim, 0, maxDim, maxDim), 10, 10)];
        rightImageView.transform = CGAffineTransformMakeRotation(RandomPhotoRotation);
        [self addSubview:rightImageView];

        leftImageView.layer.borderColor = [UIColor orangeColor].CGColor;
        leftImageView.layer.borderWidth = 1;
        
        rightImageView.layer.borderColor = [UIColor purpleColor].CGColor;
        rightImageView.layer.borderWidth = 1;
        
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 1;
    }
    return self;
}

@end
