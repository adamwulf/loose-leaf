//
//  SLBezelOutPanPinchGestureRecognizer.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLBezelOutPanPinchGestureRecognizer.h"
#import "Constants.h"

@implementation SLBezelOutPanPinchGestureRecognizer

@synthesize bezelDirectionMask;
@synthesize didExitToBezel;


/**
 * This will determine if the touch was near the bezel
 * when the user lifted their finger. if the touch was
 * within ~ 10 pixels, then there's a great chance that
 * the user was just swiping off screen.
 *
 * in that case, see which edge they swiped to and record
 * that in the didExitToBezel mask.
 *
 * then just pass through to the normal pan/scale gesture
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch* touch in touches){
        CGPoint point = [touch locationInView:self.view.superview];
        BOOL bezelDirHasLeft = ((self.bezelDirectionMask & SLBezelDirectionLeft) == SLBezelDirectionLeft);
        BOOL bezelDirHasRight = ((self.bezelDirectionMask & SLBezelDirectionRight) == SLBezelDirectionRight);
        BOOL bezelDirHasUp = ((self.bezelDirectionMask & SLBezelDirectionUp) == SLBezelDirectionUp);
        BOOL bezelDirHasDown = ((self.bezelDirectionMask & SLBezelDirectionDown) == SLBezelDirectionDown);
        if(point.x < kBezelInGestureWidth && bezelDirHasLeft){
            didExitToBezel = didExitToBezel | SLBezelDirectionLeft;
        }else if(point.y < kBezelInGestureWidth && bezelDirHasUp){
            didExitToBezel = didExitToBezel | SLBezelDirectionUp;
        }else if(point.x > self.view.superview.frame.size.width - kBezelInGestureWidth && bezelDirHasRight){
            didExitToBezel = didExitToBezel | SLBezelDirectionRight;
        }else if(point.y > self.view.superview.frame.size.height - kBezelInGestureWidth && bezelDirHasDown){
            didExitToBezel = didExitToBezel | SLBezelDirectionDown;
        }
    }
    [super touchesEnded:touches withEvent:event];
}

-(void) reset{
    [super reset];
    didExitToBezel = SLBezelDirectionNone;
    [setOfTouchesThatExitedTheBezel removeAllObjects];
}

@end
