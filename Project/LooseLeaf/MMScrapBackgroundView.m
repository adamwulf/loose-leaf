//
//  MMScrapBackgroundView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/23/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapBackgroundView.h"

@implementation MMScrapBackgroundView{
    UIImageView* backingContentView;
}

@synthesize backingContentView;
@synthesize backgroundRotation;

-(id) init{
    if(self = [super initWithFrame:CGRectZero]){
        backingContentView = [[UIImageView alloc] initWithFrame:CGRectZero];
        backingContentView.contentMode = UIViewContentModeScaleAspectFit;
        backingContentView.clipsToBounds = YES;
        [self addSubview:backingContentView];
    }
    return self;
}

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    if(!backingContentView.image){
        // if the backingContentView has an image, then
        // it's frame is already set for its image size
        backingContentView.frame = self.bounds;
    }
}

@end
