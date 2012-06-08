//
//  SLPaperStackView.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLPaperStackView.h"

@implementation SLPaperStackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self awakeFromNib];
    }
    return self;
}

-(void) awakeFromNib{
    visibleStack = [[NSMutableArray array] retain];
    hiddenStack = [[NSMutableArray array] retain];
    
    UIPanGestureRecognizer* panGesture = [[[SLPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)] autorelease];
    [panGesture setMinimumNumberOfTouches:2];
    [self addGestureRecognizer:panGesture];
    
    UIPinchGestureRecognizer* pinchGesture = [[[SLPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)] autorelease];
    [self addGestureRecognizer:pinchGesture];
}

-(void) pan:(UIPanGestureRecognizer*)panGesture{
    if([visibleStack count] == 0) return;
    
    UIView* viewToMove = [visibleStack objectAtIndex:0];
    CGPoint p = [panGesture translationInView:self];
    NSLog(@"asdfasdf %f %f", p.x, p.y);
    p = CGPointMake(-p.x, -p.y);
    CGRect fr = viewToMove.bounds;
    if(panGesture.state == UIGestureRecognizerStateCancelled ||
       panGesture.state == UIGestureRecognizerStateEnded ||
       panGesture.state == UIGestureRecognizerStateFailed){
        fr.origin = CGPointZero;
        viewToMove.bounds = fr;
    }else{
        fr.origin = p;
        viewToMove.bounds = fr;
    }
}

-(void) pinch:(UIPinchGestureRecognizer*)pinchGesture{
    NSLog(@"pinch");
}



/**
 * adds the page to the bottom of the stack
 * and adds to the bottom of the subviews
 */
-(void) addPaperToBottomOfStack:(SLPaperView*)page{
    if([visibleStack count]){
        [self insertSubview:page belowSubview:[visibleStack lastObject]];
    }else{
        [self addSubview:page];
    }
    [visibleStack addObject:page];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
