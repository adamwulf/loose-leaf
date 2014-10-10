//
//  MMEmptyCollectionViewCell.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/26/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMEmptyCollectionViewCell.h"
#import "MMPolaroidView.h"
#import "MMPolaroidsView.h"
#import "UIView+Debug.h"



@implementation MMEmptyCollectionViewCell

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        MMPolaroidsView* icon = [[MMPolaroidsView alloc] initWithFrame:CGRectMake(0, 80, frame.size.width, 140)];
        icon.backgroundColor = [UIColor clearColor];
        [self addSubview:icon];
    }
    return self;
}

@end
