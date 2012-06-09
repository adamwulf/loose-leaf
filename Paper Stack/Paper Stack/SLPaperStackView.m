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
    
    SLPaperView* viewToMove = (SLPaperView*) [visibleStack objectAtIndex:0];
    CGPoint p = [panGesture translationInView:self];
    p = CGPointMake(p.x - lastTranslationOfPan.x, p.y - lastTranslationOfPan.y);
    lastTranslationOfPan = [panGesture translationInView:self];
//    NSLog(@"asdfasdf %f %f", p.x, p.y);
    CGRect fr = viewToMove.frame;
    if(panGesture.state == UIGestureRecognizerStateCancelled ||
       panGesture.state == UIGestureRecognizerStateEnded ||
       panGesture.state == UIGestureRecognizerStateFailed){

    
        // TODO clean up
    
    
    }else{
        fr.origin = CGPointMake(fr.origin.x + p.x, fr.origin.y + p.y);
        viewToMove.frame = fr;
    }
}

-(void) pinch:(UIPinchGestureRecognizer*)pinchGesture{
//    return;
//    NSLog(@"pinch %f", pinchGesture.scale);
    
    if(pinchGesture.scale < .7){
//        debug_NSLog(@"pinch all out to desk %f", pinchGesture.scale);
    }else{
        SLPaperView* viewToScale = [visibleStack objectAtIndex:0];
        [viewToScale setScale:pinchGesture.scale atLocation:[pinchGesture locationInView:viewToScale]];
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
