//
//  SYUnitPreview.m
//  TouchChart
//
//  Created by Fernando Garcia Torcelly on 03/09/12.
//
//

#import "SYUnitPreview.h"

@implementation SYUnitPreview

@synthesize points;

- (void) drawRect: (CGRect)rect
{
    if (!points || [points count] == 0)
        return;
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path setLineWidth:2.0];
    
    NSDictionary *firstPointDict = [points objectAtIndex:0];
    CGPoint previousPoint = CGPointMake([[firstPointDict valueForKey:@"x"]floatValue] * 0.1, [[firstPointDict valueForKey:@"y"]floatValue] * 0.1);
    [path  moveToPoint:previousPoint];
    
    for (NSDictionary *pointDict in points) {
        CGPoint point = CGPointMake([[pointDict valueForKey:@"x"]floatValue] * 0.1, [[pointDict valueForKey:@"y"]floatValue] * 0.1);
        if (previousPoint.x != point.x || previousPoint.y != point.y) {
            [path addLineToPoint:point];
            previousPoint = point;
        }
    }
    
    [[UIColor clearColor] set];
    [path fill];
    
    [[UIColor colorWithRed:46.0/256.0 green:136.0/256.0 blue:204.0/256.0 alpha:1.0] set];
    [path stroke];
    
}// drawRect:

@end
