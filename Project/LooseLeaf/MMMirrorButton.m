//
//  MMMirrorButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/5/18.
//  Copyright © 2018 Milestone Made, LLC. All rights reserved.
//

#import "MMMirrorButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import <PerformanceBezier/PerformanceBezier.h>

@implementation MMMirrorButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

-(void) setShowMirror:(MirrorMode)mirrorMode{
    _mirrorMode = mirrorMode;
    
    [self setNeedsDisplay];
}

-(void)cycleMirrorMode{
    switch ([self mirrorMode]) {
        case MirrorModeNone:
            [self setMirrorMode:MirrorModeVertical];
            break;
        case MirrorModeVertical:
            [self setMirrorMode:MirrorModeHorizontal];
            break;
        case MirrorModeHorizontal:
            [self setMirrorMode:MirrorModeNone];
            break;
    }
    
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Create the context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Make sure the remove the anti-alias effect from circle
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    CGRect frame = [self drawableFrame];
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    //
    // Fill Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5, floor(CGRectGetWidth(frame) - 1.0), floor(CGRectGetHeight(frame) - 1.0))];
    [halfGreyFill setFill];
    [ovalPath fill];
    
    // cut circles out
    // and stroke
    
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    if([self mirrorMode] != MirrorModeNone){
        UIBezierPath* linePath = [UIBezierPath bezierPath];

        if([self mirrorMode] == MirrorModeVertical){
            CGPoint p1 = CGPointMake(CGRectGetMidX(frame), CGRectGetMinY(frame) + 0.5);
            CGPoint p2 = CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame) - 0.5);
            
            [linePath moveToPoint:p1];
            [linePath addLineToPoint:p2];
            [linePath setLineWidth:1.5];
        }else if([self mirrorMode] == MirrorModeHorizontal){
            CGPoint p1 = CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame) + 0.5);
            CGPoint p2 = CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame) - 0.5);
            
            [linePath moveToPoint:p1];
            [linePath addLineToPoint:p2];
            [linePath setLineWidth:1.5];
        }
        
        // erase the lines
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor whiteColor] setStroke];
        [linePath stroke];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        // fill the lines
        [darkerGreyBorder setStroke];
        [linePath stroke];
    }
}

@end
