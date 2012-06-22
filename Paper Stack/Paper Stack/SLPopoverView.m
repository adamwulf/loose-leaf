//
//  SLPopoverView.m
//  scratchpaper
//
//  Created by Adam Wulf on 6/22/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLPopoverView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SLPopoverView

-(CGPathRef)getTrianglePath2
{
    UIBezierPath* triangle = [UIBezierPath bezierPath];
    [triangle moveToPoint:CGPointMake(100, 100)];
    [triangle addLineToPoint:CGPointMake(100,0)];
    [triangle addLineToPoint:CGPointMake(0, 100)];
    [triangle closePath];
    return [triangle CGPath];
}
-(CGPathRef)getTrianglePath
{
    UIBezierPath* triangle = [UIBezierPath bezierPath];
    [triangle moveToPoint:CGPointZero];
    [triangle addLineToPoint:CGPointMake(100,0)];
    [triangle addLineToPoint:CGPointMake(0, 100)];
    [triangle closePath];
    return [triangle CGPath];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        UIView* testView = [[UIView alloc] initWithFrame:frame];
        testView.backgroundColor = [UIColor clearColor];
        testView.opaque = NO;
        maskLayer.lineWidth = 1;
        maskLayer.strokeColor = [UIColor darkGrayColor].CGColor;
        maskLayer.fillColor = [UIColor lightGrayColor].CGColor;
        maskLayer.path = CGPathCreateWithRect(testView.bounds, nil);
        [testView.layer addSublayer:maskLayer];
        [self addSubview:testView];
        
         CABasicAnimation *morph = [CABasicAnimation animationWithKeyPath:@"path"];
         morph.duration = .5;
         morph.fromValue = (id) [self getTrianglePath2];
         morph.toValue = (id) [self getTrianglePath];
         morph.repeatCount = 0;
         morph.removedOnCompletion = NO;
         [morph setAutoreverses:YES];
         [maskLayer addAnimation:morph forKey:@"asdfasdfasfd"];
        
        maskLayer.path = [self getTrianglePath2];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
