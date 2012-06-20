//
//  SLBezelOutPanPinchGestureRecognizer.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/19/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLBezelOutPanPinchGestureRecognizer.h"


@implementation SLBezelOutPanPinchGestureRecognizer

@synthesize bezelDirectionMask;
@synthesize didExitToBezel;



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    didExitToBezel = SLBezelDirectionNone;
    for(UITouch* touch in touches){
        NSInteger bezelWidth = 20;
        CGPoint point = [touch locationInView:self.view.superview];
        BOOL bezelDirHasLeft = ((self.bezelDirectionMask & SLBezelDirectionLeft) == SLBezelDirectionLeft);
        BOOL bezelDirHasRight = ((self.bezelDirectionMask & SLBezelDirectionRight) == SLBezelDirectionRight);
        BOOL bezelDirHasUp = ((self.bezelDirectionMask & SLBezelDirectionUp) == SLBezelDirectionUp);
        BOOL bezelDirHasDown = ((self.bezelDirectionMask & SLBezelDirectionDown) == SLBezelDirectionDown);
        if(point.x < bezelWidth && bezelDirHasLeft){
            didExitToBezel = didExitToBezel | SLBezelDirectionLeft;
        }else if(point.y < bezelWidth && bezelDirHasUp){
            didExitToBezel = didExitToBezel | SLBezelDirectionUp;
        }else if(point.x > self.view.frame.size.width - bezelWidth && bezelDirHasRight){
            didExitToBezel = didExitToBezel | SLBezelDirectionRight;
        }else if(point.y > self.view.frame.size.height - bezelWidth && bezelDirHasDown){
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
