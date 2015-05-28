//
//  MMCheckButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/22/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMCheckButton.h"

@implementation MMCheckButton

-(id) initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    }
    return self;
}

-(UIColor*) borderColor{
    return [UIColor colorWithRed: 0.16 green: 0.16 blue: 0.16 alpha: 0.45];
}

-(UIColor*) backgroundColor{
    return [[UIColor whiteColor] colorWithAlphaComponent:.7];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    CGRect frame = [self drawableFrame];
    
    //// Oval
    UIBezierPath* ovalPath = [self ovalPath];
    [halfGreyFill setFill];
    [ovalPath fill];
    
    
    CGFloat sizeOfCheck = frame.size.width * 3 / 7;
    
    // check
    CGPoint start = CGPointMake(frame.origin.x + (frame.size.width - sizeOfCheck) / 2, frame.origin.y + (frame.size.height)/2);
    CGPoint corner = CGPointMake(start.x + sizeOfCheck/3, start.y + sizeOfCheck / 3);
    CGPoint end = CGPointMake(corner.x + sizeOfCheck * 2 / 3, corner.y - sizeOfCheck * 2 / 3);
    UIBezierPath* checkPath = [UIBezierPath bezierPath];
    [checkPath moveToPoint:start];
    [checkPath addLineToPoint:corner];
    [checkPath addLineToPoint:end];
    checkPath.lineWidth = 4;

    
    //
    // clear the check
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setStroke];
    [checkPath stroke];
    CGContextSetBlendMode(context, kCGBlendModeNormal);

    // draw teh check
    [darkerGreyBorder setStroke];
    [checkPath stroke];

    [self drawDropshadowIfSelected];

    
    // outer border
    
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];

    [super drawRect:rect];
}

@end
