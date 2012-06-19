//
//  SLBezelGestureRecognizer.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLBezelInGestureRecognizer.h"
#import "Constants.h"

@implementation SLBezelInGestureRecognizer
@synthesize bezelDirectionMask;

-(id) init{
    self = [super init];
    self.bezelDirectionMask = SLBezelDirectionBottomBezel | SLBezelDirectionLeftBezel | SLBezelDirectionRightBezel | SLBezelDirectionTopBezel;
    return self;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return YES;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

/**
 * the first touch of a gesture.
 * this touch may interrupt an animation on this frame, so set the frame
 * to match that of the animation.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch* touch in touches){
        CGPoint point = [touch locationInView:self.view];
        if(point.x < 10 && !((self.bezelDirectionMask & SLBezelDirectionLeftBezel) == SLBezelDirectionLeftBezel)){
            [self ignoreTouch:touch forEvent:event];
        }
        if(point.y < 10 && !((self.bezelDirectionMask & SLBezelDirectionTopBezel) == SLBezelDirectionTopBezel)){
            [self ignoreTouch:touch forEvent:event];
        }
        if(point.x > self.view.frame.size.width - 10 && !((self.bezelDirectionMask & SLBezelDirectionRightBezel) == SLBezelDirectionRightBezel)){
            [self ignoreTouch:touch forEvent:event];
        }
        if(point.y > self.view.frame.size.height - 10 && !((self.bezelDirectionMask & SLBezelDirectionBottomBezel) == SLBezelDirectionBottomBezel)){
            [self ignoreTouch:touch forEvent:event];
        }
        if(point.x > 10 && point.y > 10 && point.x < self.view.frame.size.width - 10 && point.y < self.view.frame.size.height - 10){
            // ignore touch inside main view, only accept bezel touches
            [self ignoreTouch:touch forEvent:event];
        }
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
}
- (void)reset{
    [super reset];
}
@end
