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
    UIView* ul;
    UIView* ur;
    UIView* br;
    UIView* bl;
    
    Quadrilateral _quad;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self setOpaque:NO];
        ul = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 10, 10)];
        ul.backgroundColor = [UIColor redColor];
        ur = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 10, 10)];
        ur.backgroundColor = [UIColor blueColor];
        br = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 10, 10)];
        br.backgroundColor = [UIColor purpleColor];
        bl = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 10, 10)];
        bl.backgroundColor = [UIColor greenColor];
        
        ul.hidden = YES;
        ur.hidden = YES;
        br.hidden = YES;
        bl.hidden = YES;
        
        [self addSubview:ul];
        [self addSubview:ur];
        [self addSubview:br];
        [self addSubview:bl];
    }
    return self;
}

-(void) setQuadrilateral:(Quadrilateral)q{
    ul.hidden = NO;
    ur.hidden = NO;
    br.hidden = NO;
    bl.hidden = NO;

    [self send:ul to:q.upperLeft];
    [self send:ur to:q.upperRight];
    [self send:br to:q.lowerRight];
    [self send:bl to:q.lowerLeft];
    
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

-(void) send:(UIView*)v to:(CGPoint)point{
    CGRect fr = v.frame;
    fr.origin = CGPointMake(point.x - v.bounds.size.width/2,
                            point.y - v.bounds.size.height/2);
    v.frame = fr;
}


@end
