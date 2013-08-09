//
//  MMColorButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/9/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMColorButton.h"

@implementation MMColorButton{
    UIColor* color;
}

- (id)initWithColor:(UIColor*)_color andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        color = _color;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    
//    CGRect frame = [self drawableFrame];
    
    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    [ovalPath closePath];
    [color setFill];
    [ovalPath fill];
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    [self drawDropshadowIfSelected];
    
    [super drawRect:rect];
}


@end
