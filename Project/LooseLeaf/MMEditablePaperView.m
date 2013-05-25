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
    }
    return self;
}


-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    CGFloat _scale = frame.size.width / self.superview.frame.size.width;
    drawableView.transform = CGAffineTransformMakeScale(_scale, _scale);
}

#pragma mark - JotViewDelegate

-(void) willBeginStrokeWithTouch:(JotTouch*)touch{
    // noop
}

-(void) willMoveStrokeWithTouch:(JotTouch*)touch{
    // noop
}

-(void) didEndStrokeWithTouch:(JotTouch*)touch{
    // noop
}

-(void) didCancelStrokeWithTouch:(JotTouch*)touch{
    // noop
}

-(UIColor*) colorForTouch:(JotTouch *)touch{
    return [UIColor blackColor];
}

-(CGFloat) widthForTouch:(JotTouch*)touch{
    return 10;
}

-(CGFloat) smoothnessForTouch:(JotTouch *)touch{
    return .75;
}

-(CGFloat) rotationForSegment:(AbstractBezierPathElement *)segment fromPreviousSegment:(AbstractBezierPathElement *)previousSegment{
    return 0;
}


@end
