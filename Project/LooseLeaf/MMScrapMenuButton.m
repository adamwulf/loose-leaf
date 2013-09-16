//
//  MMScrapMenuButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/6/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapMenuButton.h"

@implementation MMScrapMenuButton{
    MMScrapView* scrap;
}

@synthesize scrap;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) setScrap:(MMScrapView *)_scrap{
    scrap = _scrap;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation(scrap.rotation));
    CGFloat scale = (self.bounds.size.width - 10) / MAX(scrap.bounds.size.width, scrap.bounds.size.height);
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(scale, scale));
    scrap.transform = transform;
    
    [self addSubview:scrap];
    
    [self setNeedsDisplay];
}


@end
