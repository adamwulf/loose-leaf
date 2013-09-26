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
}

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.opaque = NO;
    }
    return self;
}

-(UIColor*) borderColor{
    return [UIColor colorWithRed: 0.26 green: 0.26 blue: 0.26 alpha: 0.35];
}

-(void) setBezierPath:(UIBezierPath*)path{
    bezierPath = [path copy];
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[self borderColor] setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
}


@end
