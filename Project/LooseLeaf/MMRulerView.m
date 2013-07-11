//
//  MMRulerView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/10/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMRulerView.h"
#import "Constants.h"

@implementation MMRulerView{
    CGPoint old_p1, old_p2;
    CGFloat originalDistance;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:.3];
    }
    return self;
}


/**
 * Draw our ruler
 */
- (void)drawRect:(CGRect)rect
{
    if(originalDistance > 0){
        // Drawing code
        UIBezierPath* path = [UIBezierPath bezierPath];
        [path moveToPoint:old_p1];
        [path addLineToPoint:old_p2];
        [[UIColor blueColor] setStroke];
        [path setLineWidth:2];
        [path stroke];
        
        CGFloat currentDistance = DistanceBetweenTwoPoints(old_p1, old_p2);
        
        if(currentDistance < originalDistance * 3 / 5){
            NSLog(@"squeeze");
        }else if(currentDistance < originalDistance * 7 / 8){
            NSLog(@"arc");
        }else{
            NSLog(@"straight");
        }
    }
}


#pragma mark - Public Interface

/**
 * the ruler is being moved around on the screen between the
 * two input points p1 and p2, and the user had originally
 * started the ruler between start1 and start2
 */
-(void) updateLineAt:(CGPoint)p1 to:(CGPoint)p2 startingDistance:(CGFloat)distance{
    [self updateRectForPoint:p1 andPoint:p2];
    
    old_p1 = p1;
    old_p2 = p2;
    originalDistance = distance;
}

/**
 * the ruler gesture has ended
 */
-(void) liftRuler{
    // set needs display in our current ruler
    [self updateRectForPoint:old_p1 andPoint:old_p2];
    
    // zero everything out.
    // this will cause our drawRect to
    // display nothing
    old_p1 = CGPointZero;
    old_p2 = CGPointZero;
    originalDistance = 0;
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


#pragma mark - Private Helpers

/**
 * this setNeedsDisplay in a rectangle that contains both the the
 * new ruler dimentions (input) and the old ruler dimensions
 * (old points).
 */
-(void) updateRectForPoint:(CGPoint)p1 andPoint:(CGPoint)p2{
    CGPoint minP = CGPointMake(MIN(MIN(MIN(p1.x, p2.x), old_p1.x), old_p2.x), MIN(MIN(MIN(p1.y, p2.y), old_p1.y), old_p2.y));
    CGPoint maxP = CGPointMake(MAX(MAX(MAX(p1.x, p2.x), old_p1.x), old_p2.x), MAX(MAX(MAX(p1.y, p2.y), old_p1.y), old_p2.y));
    CGRect needsDisp = CGRectMake(minP.x, minP.y, maxP.x - minP.x, maxP.y - minP.y);
    needsDisp = CGRectInset(needsDisp, -5, -5);
    [self setNeedsDisplayInRect:needsDisp];
}

@end
