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
    [panGesture setMaximumNumberOfTouches:2];
    [self addGestureRecognizer:panGesture];
    
    UIPinchGestureRecognizer* pinchGesture = [[[SLPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)] autorelease];
    [self addGestureRecognizer:pinchGesture];
}

-(void) pan:(UIPanGestureRecognizer*)panGesture{
    SLPaperView* viewToAdjust = (SLPaperView*) [visibleStack objectAtIndex:0];
    CGPoint lastLocation = [panGesture locationInView:self];
    if(panGesture.numberOfTouches == 1){
        lastNumberOfPanGestures = 1;
        return;
    }else if(lastNumberOfPanGestures == 1){
        lastNumberOfPanGestures = 2;
        firstLocationOfGesture = [panGesture locationInView:self];
        firstFrameOfViewForGesture = viewToAdjust.frame;
    }
    if(panGesture.state == UIGestureRecognizerStateBegan){
        lastNumberOfPanGestures = 2;
        firstLocationOfGesture = [panGesture locationInView:self];
        firstFrameOfViewForGesture = viewToAdjust.frame;
        return;
    }
    if(panGesture.state == UIGestureRecognizerStateCancelled ||
       panGesture.state == UIGestureRecognizerStateEnded ||
       panGesture.state == UIGestureRecognizerStateFailed){
        // exit when we're done
        return;
    }
    
    
    CGPoint diffLocation = CGPointMake(lastLocation.x - firstLocationOfGesture.x, lastLocation.y - firstLocationOfGesture.y);
    
    CGRect fr = viewToAdjust.frame;
    fr.origin = CGPointMake(firstFrameOfViewForGesture.origin.x + diffLocation.x, firstFrameOfViewForGesture.origin.y + diffLocation.y);
    viewToAdjust.frame = fr;
}

-(void) pinch:(UIPinchGestureRecognizer*)pinchGesture{
    if([visibleStack count] == 0) return;
    SLPaperView* viewToAdjust = [visibleStack objectAtIndex:0];

    //    NSLog(@"pinch %f", pinchGesture.scale);
    
    

    
    if(pinchGesture.scale < .7){
//        debug_NSLog(@"pinch all out to desk %f", pinchGesture.scale);
    }else{
//        [viewToAdjust setScale:pinchGesture.scale atLocation:[pinchGesture locationInView:viewToAdjust]];
    }
    
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
