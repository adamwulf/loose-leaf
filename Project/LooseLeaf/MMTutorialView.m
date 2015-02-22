//
//  MMTutorialView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 2/21/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMTutorialView.h"
#import "MMVideoLoopView.h"

@implementation MMTutorialView{
    
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        // 10% buffer
        CGFloat boxSize = MIN(frame.size.width, frame.size.height) * .8;
        UIBezierPath* box = [self boxPathForWidth:boxSize];
        
        CAShapeLayer* shapeLayer = [CAShapeLayer layer];
        shapeLayer.bounds = self.bounds;
        shapeLayer.position = self.center;
        shapeLayer.path = box.CGPath;
        shapeLayer.fillRule = kCAFillRuleEvenOdd;
        shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
        shapeLayer.fillColor = [UIColor blackColor].CGColor;

        CALayer* greyBackground = [CALayer layer];
        greyBackground.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5].CGColor;
        greyBackground.bounds = self.bounds;
        greyBackground.position = self.center;
        greyBackground.mask = shapeLayer;
        [self.layer addSublayer:greyBackground];
//        [self.layer addSublayer:shapeLayer];

        
//        greyBackground.position = self.center;

        
//        NSURL* rulerMov = [[NSBundle mainBundle] URLForResource:@"ruler-circle" withExtension:@"mov"];
//        MMVideoLoopView* videoView = [[MMVideoLoopView alloc] initForVideo:rulerMov];
//        [self addSubview:videoView];
        
    }
    return self;
}






#pragma mark - Private Helpers

-(UIBezierPath*) boxPathForWidth:(CGFloat)width{
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:self.bounds];
    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake((self.bounds.size.width - width) / 2, (self.bounds.size.height - width) / 2, width, width)
                                           byRoundingCorners:UIRectCornerAllCorners
                                                 cornerRadii:CGSizeMake(width/10, width/10)]];
    path.usesEvenOddFillRule = YES;
    return path;
}

@end
