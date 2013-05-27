//
//  MMEditablePaperView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/24/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMEditablePaperView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MMEditablePaperView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        drawableView = [[JotView alloc] initWithFrame:self.bounds];
        drawableView.delegate = self;
        [self.contentView addSubview:drawableView];

        // anchor the view to the top left,
        // so that when we scale down, the drawable view
        // stays in place
        drawableView.layer.anchorPoint = CGPointMake(0,0);
        drawableView.layer.position = CGPointMake(0,0);
        
        pen = [[Pen alloc] initWithMinSize:6 andMaxSize:15 andMinAlpha:.9 andMaxAlpha:.9];
        pen.shouldUseVelocity = YES;
        
        [[JotStylusManager sharedInstance] setEnabled:YES];
        [[JotStylusManager sharedInstance] setRejectMode:NO];
        [[JotStylusManager sharedInstance] setPalmRejectorDelegate:drawableView];
    }
    return self;
}


-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    CGFloat _scale = frame.size.width / self.superview.frame.size.width;
    drawableView.transform = CGAffineTransformMakeScale(_scale, _scale);
}


#pragma mark - Gestures

-(void) panAndScale:(MMPanAndPinchGestureRecognizer*)_panGesture{
    if(panGesture.state == UIGestureRecognizerStateBegan){
        [[JotStylusManager sharedInstance] unregisterView:drawableView];
    }else if(panGesture.state == UIGestureRecognizerStateCancelled ||
             panGesture.state == UIGestureRecognizerStateEnded ||
             panGesture.state == UIGestureRecognizerStateFailed){
        [[JotStylusManager sharedInstance] registerView:drawableView];
    }
    [super panAndScale:_panGesture];
}


#pragma mark - JotViewDelegate

-(void) willBeginStrokeWithTouch:(JotTouch*)touch{
    [pen willBeginStrokeWithTouch:touch];
}

-(void) willMoveStrokeWithTouch:(JotTouch*)touch{
    [pen willMoveStrokeWithTouch:touch];
}

-(void) didEndStrokeWithTouch:(JotTouch*)touch{
    [pen didEndStrokeWithTouch:touch];
}

-(void) didCancelStrokeWithTouch:(JotTouch*)touch{
    [pen didCancelStrokeWithTouch:touch];
}

-(UIColor*) colorForTouch:(JotTouch *)touch{
    return [UIColor blackColor];
}

-(CGFloat) widthForTouch:(JotTouch*)touch{
    return [pen widthForTouch:touch];
}

-(CGFloat) smoothnessForTouch:(JotTouch *)touch{
    return [pen smoothnessForTouch:touch];
}

-(CGFloat) rotationForSegment:(AbstractBezierPathElement *)segment fromPreviousSegment:(AbstractBezierPathElement *)previousSegment{
    return [pen rotationForSegment:segment fromPreviousSegment:previousSegment];;
}


@end
