//
//  MMDebugQuadrilateralView.m
//  ShapeShifter
//
//  Created by Adam Wulf on 2/28/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMDebugQuadrilateralView.h"
#import "MMVector.h"

@implementation MMDebugQuadrilateralView{
    Quadrilateral _quad;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self setOpaque:NO];
    }
    return self;
}

-(void) setQuadrilateral:(Quadrilateral)q{
    _quad = q;
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    UIBezierPath* path = [self pathforQuad:_quad];
    [[UIColor redColor] setStroke];
    [path stroke];
    
    UIBezierPath* avgQuad = [self pathforQuad:[self generateAverageQuadFor:_quad]];
    [[UIColor greenColor] setStroke];
    [avgQuad stroke];
    
}


-(UIBezierPath*) pathforQuad:(Quadrilateral)q{
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:q.upperLeft];
    [path addLineToPoint:q.upperRight];
    [path addLineToPoint:q.lowerRight];
    [path addLineToPoint:q.lowerLeft];
    [path addLineToPoint:q.upperLeft];
    path.lineWidth = 2;
    return path;
}


-(Quadrilateral) generateAverageQuadFor:(Quadrilateral)q{
  
    Quadrilateral ret;
    
    
    CGPoint midLeft = CGPointMake((q.upperLeft.x + q.lowerLeft.x)/2, (q.upperLeft.y + q.lowerLeft.y)/2);
    CGPoint midRight = CGPointMake((q.upperRight.x + q.lowerRight.x)/2, (q.upperRight.y + q.lowerRight.y)/2);
    
    MMVector* lengthVector = [MMVector vectorWithPoint:midLeft andPoint:midRight];

    CGPoint midTop = CGPointMake((q.upperLeft.x + q.upperRight.x)/2, (q.upperLeft.y + q.upperRight.y)/2);
    CGPoint midLow = CGPointMake((q.lowerLeft.x + q.lowerRight.x)/2, (q.lowerLeft.y + q.lowerRight.y)/2);
    

    ret.upperLeft = [lengthVector pointFromPoint:midTop distance:-0.5];
    ret.upperRight = [lengthVector pointFromPoint:midTop distance:0.5];
    ret.lowerRight = [lengthVector pointFromPoint:midLow distance:0.5];
    ret.lowerLeft = [lengthVector pointFromPoint:midLow distance:-0.5];
    
    
    return ret;
}


#pragma mark - Ignore Touches

/**
 * these two methods make sure that the ruler view
 * can never intercept any touch input. instead it will
 * effectively pass through this view to the views behind it
 */
-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return nil;
}

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return NO;
}


@end
