//
//  MMBufferedImageView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMBufferedImageView.h"

@implementation MMBufferedImageView{
    UIImage* img;
}

CGFloat buffer = 2;

- (id)initWithImage:(UIImage*)_img
{
    if (self = [super initWithFrame:CGRectInset(CGRectMake(0,0, _img.size.width, _img.size.height), -buffer, -buffer)]) {
        img = _img;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

-(void) drawRect:(CGRect)rect{

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    [img drawAtPoint:CGPointMake(buffer, buffer)];
    
    CGRect r = CGRectMake(buffer, buffer, img.size.width, img.size.height);
    
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextStrokeRect(context, r);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextStrokeRect(context, CGRectInset(r, 1, 1));
}

@end
