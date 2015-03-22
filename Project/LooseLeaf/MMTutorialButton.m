//
//  MMTutorialButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/21/15.
//  Copyright (c) 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMTutorialButton.h"
#import "AVHexColor.h"

@implementation MMTutorialButton

@synthesize finished;

-(void) setFinished:(BOOL)_finished{
    finished = _finished;
    [self setNeedsDisplay];
}

-(id) initWithFrame:(CGRect)_frame forStepNumber:(NSInteger)stepNumber{
    if(self = [super initWithFrame:_frame andFont:[UIFont systemFontOfSize:12] andLetter:[NSString stringWithFormat:@"%d", (int)stepNumber]
                        andXOffset:0 andYOffset:0]){
        self.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    }
    return self;
}

-(UIColor*) borderColor{
    return [UIColor colorWithRed: 0.16 green: 0.16 blue: 0.16 alpha: 0.45];
}

-(void) drawRect:(CGRect)rect{
    if(!self.isFinished){
        [super drawRect:rect];
    }else{
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

        //// Color Declarations
        UIColor* darkerGreyBorder = [self borderColor];
        UIColor* halfGreyFill = [self backgroundColor];
        
        
        //// Oval
        UIBezierPath* ovalPath = [self ovalPath];
//        [halfGreyFill setFill];
//        
//        [ovalPath fill];
//        [[[AVHexColor colorWithHexString:@"3C7BFF"] colorWithAlphaComponent:.4] setFill];
//        [ovalPath fill];
        
        
        
        
        
        UIColor* lightBlue = [AVHexColor colorWithHexString:@"0E94FB"];
        UIColor* lighterBlue = [AVHexColor colorWithHexString:@"84C7fA"];
        lightBlue = [UIColor colorWithWhite:1.0 alpha:.8];
        lighterBlue = [UIColor colorWithWhite:1.0 alpha:.5];
        
        
        //// Gradient Declarations
        NSArray* blueGradientColors = [NSArray arrayWithObjects:
                                       (id)lightBlue.CGColor,
                                       (id)lighterBlue.CGColor, nil];
        CGFloat blueGradientLocations[] = {0, 1};
        CGGradientRef blueGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)blueGradientColors, blueGradientLocations);
        
        // fill face with gradient
        CGContextSaveGState(context);
        [ovalPath addClip];
        CGRect ovalBounds = CGPathGetPathBoundingBox(ovalPath.CGPath);
        CGContextDrawLinearGradient(context, blueGradient,
                                    CGPointMake(CGRectGetMidX(ovalBounds), CGRectGetMinY(ovalBounds)),
                                    CGPointMake(CGRectGetMidX(ovalBounds), CGRectGetMaxY(ovalBounds)),
                                    0);
        CGContextRestoreGState(context);


        // Star
        CGRect frame = [self drawableFrame];
        //// Star Drawing
        frame.origin.x += frame.size.width * .2;
        frame.origin.y += frame.size.height * .2;
        frame.size.width -= frame.size.width * .4;
        frame.size.height -= frame.size.height * .4;
        UIBezierPath* starPath = UIBezierPath.bezierPath;
        [starPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.02500 * CGRectGetHeight(frame))];
        [starPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.66164 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30252 * CGRectGetHeight(frame))];
        [starPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97553 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37049 * CGRectGetHeight(frame))];
        [starPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.76154 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60998 * CGRectGetHeight(frame))];
        [starPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79389 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92951 * CGRectGetHeight(frame))];
        [starPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.80000 * CGRectGetHeight(frame))];
        [starPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20611 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92951 * CGRectGetHeight(frame))];
        [starPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.23846 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.60998 * CGRectGetHeight(frame))];
        [starPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02447 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.37049 * CGRectGetHeight(frame))];
        [starPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.33836 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30252 * CGRectGetHeight(frame))];
        [starPath closePath];
        starPath.lineWidth = 1;
        
        
        [[AVHexColor colorWithHexString:@"FFE230"] setFill];
        [darkerGreyBorder setFill];
        [starPath fill];
        
        [self drawDropshadowIfSelected];
        

        //
        // clear the check
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor whiteColor] setStroke];
        [starPath stroke];
        [ovalPath stroke];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        // draw teh check
        [darkerGreyBorder setStroke];
        [starPath stroke];
        
        
        // outer border
        
        [darkerGreyBorder setStroke];
        ovalPath.lineWidth = 1;
        [ovalPath stroke];
    }
}

@end
