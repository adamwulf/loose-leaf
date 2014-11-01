//
//  MMScrapBorderView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/31/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScrapBorderView.h"

/**
 * used to draw a border around a scrap in a bezel button
 */
@implementation MMScrapBorderView{
    UIBezierPath* bezierPath;
    CAShapeLayer* shapeBorderLayer;
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.opaque = NO;
        self.contentScaleFactor = 1.0;
        shapeBorderLayer = [CAShapeLayer layer];
        shapeBorderLayer.lineWidth = 1;
        shapeBorderLayer.strokeColor = [self borderColor].CGColor;
        shapeBorderLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:shapeBorderLayer];
    }
    return self;
}


-(UIColor*) borderColor{
    return [UIColor colorWithRed: 0.26 green: 0.26 blue: 0.26 alpha: 0.35];
}

-(void) setBezierPath:(UIBezierPath*)path{
    bezierPath = [path copy];
    shapeBorderLayer.path = bezierPath.CGPath;
}


@end
