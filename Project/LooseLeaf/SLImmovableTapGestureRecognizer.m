//
//  SLImmovableTapGestureRecognizer.m
//  Loose Leaf
//
//  Created by Adam Wulf on 10/19/12.
//
//

#import "SLImmovableTapGestureRecognizer.h"
#import "Constants.h"

@interface SLImmovableTapGestureRecognizer (Private)

@property (nonatomic, readonly) NSMutableDictionary* touchLocations;
@property (nonatomic, readonly) CGFloat allowableMovement;

@end

@implementation SLImmovableTapGestureRecognizer

-(CGFloat) allowableMovement{
    return 10;
}

-(NSMutableDictionary*)touchLocations{
    if(!touchLocations){
        touchLocations = [[NSMutableDictionary alloc] init];
    }
    return touchLocations;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    for(UITouch* touch in touches){
        [self.touchLocations setObject:[NSValue valueWithCGPoint:[touch locationInView:self.view]]
                                forKey:[NSNumber numberWithInteger:[touch hash]]];
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    BOOL didChangeState = NO;
    if(self.state == UIGestureRecognizerStatePossible){
        for(UITouch* touch in touches){
            CGPoint initialLocation = [[self.touchLocations objectForKey:[NSNumber numberWithInteger:[touch hash]]] CGPointValue];
            CGPoint currentLocation = [touch locationInView:self.view];
            CGFloat distance = DistanceBetweenTwoPoints(initialLocation, currentLocation);
            if(distance > self.allowableMovement && self.state == UIGestureRecognizerStatePossible){
                self.state = UIGestureRecognizerStateFailed;
                didChangeState = YES;
            }
        }
    }
    if(!didChangeState){
        [super touchesMoved:touches withEvent:event];
    }
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    for(UITouch* touch in touches){
        [self.touchLocations removeObjectForKey:[NSNumber numberWithInteger:[touch hash]]];
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    for(UITouch* touch in touches){
        [self.touchLocations removeObjectForKey:[NSNumber numberWithInteger:[touch hash]]];
    }
}

-(void) setState:(UIGestureRecognizerState)state{
    [super setState:state];
    if(state == UIGestureRecognizerStateEnded ||
       state == UIGestureRecognizerStateFailed ||
       state == UIGestureRecognizerStateCancelled){
        [self.touchLocations removeAllObjects];
    }
}

-(void) reset{
    [super reset];
    [self.touchLocations removeAllObjects];
}

@end