//
//  MMAlbumCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/2/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMAlbumCell.h"

@implementation MMAlbumCell

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        UILabel* lbl = [[UILabel alloc] initWithFrame:self.bounds];
        lbl.text = @"test";
        [self addSubview:lbl];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(id) init{
    if(self = [super init]){
        UILabel* lbl = [[UILabel alloc] initWithFrame:self.bounds];
        lbl.text = @"test";
        [self addSubview:lbl];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

@end
