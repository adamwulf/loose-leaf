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



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
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
        
        if(currentDistance < originalDistance * 2 / 3){
            NSLog(@"squeeze");
        }else if(currentDistance < originalDistance * 7 / 8){
            NSLog(@"arc");
        }else{
            NSLog(@"straight");
        }
    }
}


#pragma mark - Ignore Touches

-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return nil;
}

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return NO;
}


-(void) updateRectForPoint:(CGPoint)p1 andPoint:(CGPoint)p2{
    CGPoint minP = CGPointMake(MIN(MIN(MIN(p1.x, p2.x), old_p1.x), old_p2.x), MIN(MIN(MIN(p1.y, p2.y), old_p1.y), old_p2.y));
    CGPoint maxP = CGPointMake(MAX(MAX(MAX(p1.x, p2.x), old_p1.x), old_p2.x), MAX(MAX(MAX(p1.y, p2.y), old_p1.y), old_p2.y));
    CGRect needsDisp = CGRectMake(minP.x, minP.y, maxP.x - minP.x, maxP.y - minP.y);
    needsDisp = CGRectInset(needsDisp, -5, -5);
    [self setNeedsDisplayInRect:needsDisp];
}

-(void) updateLineAt:(CGPoint)p1 to:(CGPoint)p2 startingFrom:(CGPoint)start1 andFrom:(CGPoint)start2{
    [self updateRectForPoint:p1 andPoint:p2];
    
    old_p1 = p1;
    old_p2 = p2;
    originalDistance = DistanceBetweenTwoPoints(start1, start2);
}

-(void) liftRuler{
    [self updateRectForPoint:old_p1 andPoint:old_p2];

    old_p1 = CGPointZero;
    old_p2 = CGPointZero;
    originalDistance = 0;
}

@end
