//
//  SLPanFromListViewGestureRecognizer.m
//  scratchpaper
//
//  Created by Adam Wulf on 8/31/12.
//
//

#import "SLPanAndPinchFromListViewGestureRecognizer.h"

@implementation SLPanAndPinchFromListViewGestureRecognizer

@synthesize scale;
@synthesize pinchDelegate;


-(id) init{
    self = [super init];
    if(self){
        validTouches = [[NSMutableSet alloc] init];
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    if(self){
        validTouches = [[NSMutableSet alloc] init];
    }
    return self;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    debug_NSLog(@"touchesBegan");
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
        UITouch* touch = obj;
        SLPaperView* page = [pinchDelegate pageForPointInList:[touch locationInView:self.view]];
        if(page && (!pinchedPage || pinchedPage == page)){
            if(!pinchedPage){
                pinchedPage = page;
            }
            if([validTouches count] < 2){
                [validTouches addObject:touch];
            }
            if([validTouches count] == 2 && self.state == UIGestureRecognizerStatePossible){
                self.state = UIGestureRecognizerStateBegan;
            }
        }else{
            [self ignoreTouch:touch forEvent:event];
        }
    }];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if([validTouches count] == 2 && self.state != UIGestureRecognizerStateBegan){
        debug_NSLog(@"touchesMoved");
        self.state = UIGestureRecognizerStateChanged;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if([validTouches count] == 2){
        debug_NSLog(@"touchesEnded");
        [validTouches removeObjectsInSet:touches];
        self.state = UIGestureRecognizerStateEnded;
    }else{
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    debug_NSLog(@"touchesCancelled");
    [validTouches removeObjectsInSet:touches];
    self.state = UIGestureRecognizerStateCancelled;
}

- (void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event{
    debug_NSLog(@"ignoreTouch");
    [super ignoreTouch:touch forEvent:event];
}

-(void) reset{
    debug_NSLog(@"reset");
    [validTouches removeAllObjects];
    pinchedPage = nil;
}

-(void) cancel{
    self.enabled = NO;
    self.enabled = YES;
}

@end
