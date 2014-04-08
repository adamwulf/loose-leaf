//
//  MMImageViewButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/8/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMImageViewButton.h"

@implementation MMImageViewButton{
    UIImage* image;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) setImage:(UIImage*)img{
    image = img;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    CGRect frame = [self drawableFrame];
    
    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    [halfGreyFill setFill];
    [ovalPath fill];
    
    // oval clip
    UIBezierPath *circleClipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
    [circleClipPath appendPath:ovalPath];
    circleClipPath.usesEvenOddFillRule = YES;

    
    [ovalPath addClip];
    [image drawInRect:frame];
    
    
    // stroke circle
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    [self drawDropshadowIfSelected];
    
    [super drawRect:rect];

}


@end
