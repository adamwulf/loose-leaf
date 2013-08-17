//
//  MMPolygonDebugView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/17/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMPolygonDebugView.h"
#import <TouchShape/TouchShape.h>

@implementation MMPolygonDebugView{
    NSMutableArray* touches;
    UIBezierPath* shapePath;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        touches = [NSMutableArray array];
    }
    return self;
}

-(void) clear{
    [touches removeAllObjects];
    shapePath = nil;
    [self setNeedsDisplay];
}

-(void) addTouchPoint:(CGPoint)point{
    [touches addObject:[NSValue valueWithCGPoint:point]];
    [self setNeedsDisplayInRect:CGRectMake(point.x - 10, point.y - 10, 20, 20)];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[UIColor redColor] setFill];
    for(NSValue* val in touches){
        CGPoint point = [val CGPointValue];
        UIBezierPath* touchPoint = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x - 3, point.y - 3, 6, 6)];
        [touchPoint fill];
    }
    
    if(shapePath){
        [[UIColor blueColor] setStroke];
        shapePath.lineWidth = 2;
        [shapePath stroke];
    }
}

-(void) complete{
    if(![touches count]) return;
    
    TCShapeController* shapeMaker = [[TCShapeController alloc] init];
    for(int i=1;i < [touches count] - 2;i++){
        CGPoint prevPoint = [[touches objectAtIndex:i-1] CGPointValue];
        CGPoint point = [[touches objectAtIndex:i] CGPointValue];
        [shapeMaker addPoint:prevPoint andPoint:point];
    }
    [shapeMaker addLastPoint:[[touches lastObject] CGPointValue]];
    SYShape* shape = [shapeMaker getFigurePaintedWithTolerance:0.0000001 andContinuity:0];
    shapePath = [shape bezierPath];
    [self setNeedsDisplayInRect:shapePath.bounds];
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
