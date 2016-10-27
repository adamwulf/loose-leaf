//
//  MMPolaroidsView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 10/6/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMPolaroidsView.h"
#import "MMPolaroidView.h"


@implementation MMPolaroidsView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    MMPolaroidView* polaroid = [[MMPolaroidView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    UIBezierPath* pathOfOuterRect = [polaroid boundingRectForFrame:polaroid.bounds withInset:-1];

    CGFloat centerX = (self.bounds.size.width - polaroid.bounds.size.width) / 2;

    CGContextSaveGState(context);

    // first rotate the context around the photo's center
    CGContextTranslateCTM(context, centerX + polaroid.bounds.size.width * 3.5 / 5, 8);
    CGContextTranslateCTM(context, 60, 60);
    CGContextRotateCTM(context, -3.0 * M_PI / 180.0);
    CGContextTranslateCTM(context, -60, -60);
    [polaroid.layer renderInContext:context];
    CGContextRestoreGState(context);
    CGContextSaveGState(context);


    // first rotate the context around the photo's center
    CGContextTranslateCTM(context, centerX, 12);
    CGContextTranslateCTM(context, 60, 60);
    CGContextRotateCTM(context, 3.0 * M_PI / 180.0);
    CGContextTranslateCTM(context, -60, -60);

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [pathOfOuterRect fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [polaroid.layer renderInContext:context];
    CGContextRestoreGState(context);
    CGContextSaveGState(context);

    // first rotate the context around the photo's center
    CGContextTranslateCTM(context, centerX - polaroid.bounds.size.width * 3.5 / 5, 10);
    CGContextTranslateCTM(context, 60, 60);
    CGContextRotateCTM(context, -8.0 * M_PI / 180.0);
    CGContextTranslateCTM(context, -60, -60);

    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [pathOfOuterRect fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    [polaroid.layer renderInContext:context];


    CGContextRestoreGState(context);
}

@end
