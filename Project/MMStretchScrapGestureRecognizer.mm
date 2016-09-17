//
//  MMStretchGestureRecognizer.m
//  ShapeShifter
//
//  Created by Adam Wulf on 2/21/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMStretchScrapGestureRecognizer.h"
#import "Constants.h"
#import "NSMutableSet+Extras.h"
#import "MMVector.h"
#import "MMPanAndPinchScrapGestureRecognizer.h"
#import "MMPanAndPinchGestureRecognizer.h"
#import "UIGestureRecognizer+GestureDebug.h"
#import "MMStretchHelper.h"

@implementation MMStretchScrapGestureRecognizer{
    NSMutableSet* ignoredTouches;
    NSMutableOrderedSet* possibleTouches;
    NSMutableOrderedSet* validTouches;
    MMScrapView* scrap;

    // these are used to create the transform for the scrap
    CGPoint adjust;
    // the average quad at the beginning of the gesture
    Quadrilateral firstQ;
    // the normalized locations of each touch at the beginning
    // of the gesture
    Quadrilateral normalFirstQ;
    // the currently computed skew transform throughout the gesture
    CATransform3D skewTransform;
    
    // these help us determine the normalized location
    // of all of the valid touches. when handing off
    // the scrap back to a pan gesture after a failed
    // stretch, the remaining valid touches will map
    // to these, which inform which corners of the
    // normalFirstQ to use as the normalized anchor point
    UITouch* upperLeftTouch;
    UITouch* upperRightTouch;
    UITouch* lowerLeftTouch;
    UITouch* lowerRightTouch;
    
    // properties of actively stretched scrap
    NSDictionary* startingScrapProperties;
    MMUndoablePaperView* startingPageForScrap;
}

#pragma mark - Properties

@synthesize pinchScrapGesture1;
@synthesize pinchScrapGesture2;
@synthesize scrapDelegate;
@synthesize scrap = scrap;
@synthesize skewTransform = skewTransform;
@synthesize startingPageForScrap;
@synthesize startingScrapProperties;

-(NSArray*) possibleTouches{
    return [possibleTouches array];
}

-(NSArray*) ignoredTouches{
    NSMutableArray* ret = [NSMutableArray array];
    for(NSObject* obj in ignoredTouches){
        [ret addObject:obj];
    }
    return ret;
}

-(NSArray*)validTouches{
    return [validTouches array];
}

#pragma mark - Init

-(id) init{
    self = [super init];
    if(self){
        validTouches = [[NSMutableOrderedSet alloc] init];
        possibleTouches = [[NSMutableOrderedSet alloc] init];
        ignoredTouches = [[NSMutableSet alloc] init];
        self.delaysTouchesEnded = NO;
        self.cancelsTouchesInView = NO;
        self.delegate = self;
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    if(self){
        validTouches = [[NSMutableOrderedSet alloc] init];
        possibleTouches = [[NSMutableOrderedSet alloc] init];
        ignoredTouches = [[NSMutableSet alloc] init];
        self.delaysTouchesEnded = NO;
        self.cancelsTouchesInView = NO;
        self.delegate = self;
    }
    return self;
}

#pragma mark - Touch Ownership

-(void) ownershipOfTouches:(NSSet*)touches isGesture:(UIGestureRecognizer*)gesture{
    if(gesture != self){
        if(![gesture isKindOfClass:[MMPanAndPinchScrapGestureRecognizer class]] &&
           ![gesture isKindOfClass:[MMPanAndPinchGestureRecognizer class]]){
            // we're only allowed to work on scrap pinch gesture touches
            [touches enumerateObjectsUsingBlock:^(UITouch* touch, BOOL* stop){
                if([possibleTouches containsObject:touch] || [validTouches containsObject:touch]){
                    [possibleTouches removeObjectsInSet:touches];
                    [validTouches removeObjectsInSet:touches];
                }
                [ignoredTouches addObjectsInSet:touches];
            }];
            [self updateValidTouches];
        }
    }
}

-(void) blessTouches:(NSSet*)touches{
    NSMutableSet* newPossibleTouches = [NSMutableSet setWithSet:ignoredTouches];
    [newPossibleTouches intersectSet:touches];
    [possibleTouches addObjectsInSet:newPossibleTouches];
    [ignoredTouches removeObjectsInSet:newPossibleTouches];
    [self touchesBegan:newPossibleTouches];
}

#pragma mark - Helper Methods

// valid touches are updated whenever our state updates
// or we are told of touch ownership updates. this method
// ensures that we own all of our valid touches, and if for
// any reason valid touches < 4, then it reverts back to a
// non active state and keeps all known touches in either
// possible or ignored
-(void) updateValidTouches{
    if([validTouches count] == 4){
        Quadrilateral secondQ = [MMStretchHelper getQuadFrom:validTouches inView:self.view];
        Quadrilateral q1 = [MMStretchHelper adjustedQuad:firstQ by:adjust];
        Quadrilateral q2 = [MMStretchHelper adjustedQuad:secondQ by:adjust];
        // generate the actual transform between the two quads
        skewTransform = [MMStretchHelper transformQuadrilateral:q1 toQuadrilateral:q2];

        // now, determine if our stretch should pull the scrap into two pieces.
        // this should happen if either stretch is 2.0 times the other direction
        CGFloat scaleW = DistanceBetweenTwoPoints(secondQ.upperLeft, secondQ.upperRight) /
                         DistanceBetweenTwoPoints(firstQ.upperLeft, firstQ.upperRight);
        CGFloat scaleH = DistanceBetweenTwoPoints(secondQ.upperLeft, secondQ.lowerLeft) /
                         DistanceBetweenTwoPoints(firstQ.upperLeft, firstQ.lowerLeft);
        
        // normalize the scales so that they are always
        // multiples of each other. 1.0:2.0 or 2.0:1.0 means
        // we should duplicate the scrap
        if(scaleW < scaleH){
            scaleH /= scaleW;
            scaleW /= scaleW;
        }else{
            scaleW /= scaleH;
            scaleH /= scaleH;
        }

        // if we should split the scrap, pull the touches
        // into two sets based on the direction of the stretch
        NSOrderedSet* touches1 = nil;
        NSOrderedSet* touches2 = nil;
        CGPoint normalCenter1 = CGPointZero;
        CGPoint normalCenter2 = CGPointZero;
        if(scaleW > scaleH * 2){
            // scaling the quad wide
            touches1 = [NSOrderedSet orderedSetWithObjects:[validTouches objectAtIndex:0], [validTouches objectAtIndex:3], nil];
            touches2 = [NSOrderedSet orderedSetWithObjects:[validTouches objectAtIndex:1], [validTouches objectAtIndex:2], nil];
            normalCenter1 = AveragePoints(normalFirstQ.upperLeft, normalFirstQ.lowerLeft);
            normalCenter2 = AveragePoints(normalFirstQ.upperRight, normalFirstQ.lowerRight);
        }else if(scaleH > scaleW * 2){
            // scaling the quad tall
            touches1 = [NSOrderedSet orderedSetWithObjects:[validTouches objectAtIndex:0], [validTouches objectAtIndex:1], nil];
            touches2 = [NSOrderedSet orderedSetWithObjects:[validTouches objectAtIndex:2], [validTouches objectAtIndex:3], nil];
            normalCenter1 = AveragePoints(normalFirstQ.upperLeft, normalFirstQ.upperRight);
            normalCenter2 = AveragePoints(normalFirstQ.lowerRight, normalFirstQ.lowerLeft);
        }
        
        if(touches1){
            // if we have touches, then we should split the scrap.
            // tell our delegate and finish this out.
            [self.scrapDelegate endStretchBySplittingScrap:scrap toTouches:touches1 atNormalPoint:normalCenter1 andTouches:touches2 atNormalPoint:normalCenter2];
            [possibleTouches addObjectsInOrderedSet:validTouches];
            [validTouches removeAllObjects];
            startingScrapProperties = nil;
            startingPageForScrap = nil;
            scrap = nil;
        }
    }
    if([validTouches count] != 4 && scrap){
        // valid touches must be exactly 4, otherwise
        // we should stop the stretching
        [self.scrapDelegate endStretchWithoutSplittingScrap:scrap atNormalPoint:[self normalizedLocationOfValidTouches]];
        [possibleTouches addObjectsInOrderedSet:validTouches];
        [validTouches removeAllObjects];
        startingScrapProperties = nil;
        startingPageForScrap = nil;
        scrap = nil;
    }
    if([possibleTouches count] == 4){
        // if we have 4 possible touches, then we should
        // check the scrap panning gestures to see if either
        // of them hold all 4 touches. calling out to our
        // delegate lets us filter out any touches that are
        // within the bounds of the scrap but would land on some
        // other scrap that's above it in view
        NSArray* scrapsToLookAt = scrapDelegate.scrapsToPan;
        NSMutableSet* allPossibleTouches = [NSMutableSet setWithSet:[possibleTouches set]];
        for(MMScrapView* pinchedScrap in [scrapsToLookAt reverseObjectEnumerator]){
            NSMutableSet* touchesInScrap = [NSMutableSet setWithSet:[pinchedScrap allMatchingTouchesFrom:allPossibleTouches]];
            if(pinchedScrap == pinchScrapGesture1.scrap){
                // dont steal touches from other pinch gesture
                if(pinchScrapGesture1.scrap != pinchScrapGesture2.scrap){
                    [touchesInScrap removeObjectsInArray:pinchScrapGesture2.validTouches];
                }
            }else if(pinchedScrap == pinchScrapGesture2.scrap){
                // dont steal touches from other pinch gesture
                if(pinchScrapGesture1.scrap != pinchScrapGesture2.scrap){
                    [touchesInScrap removeObjectsInArray:pinchScrapGesture1.validTouches];
                }
            }
            if(pinchedScrap == pinchScrapGesture1.scrap ||
               pinchedScrap == pinchScrapGesture2.scrap){
                while([touchesInScrap count] > 4){
                    // remove some random touches so that we have exactly 4
                    [touchesInScrap removeObject:[touchesInScrap anyObject]];
                }
                if([touchesInScrap count] == 4){
                    // at this point we know that a panned scrap
                    // contains all four touches. we need to
                    // steal that scrap from the pan, and trigger
                    // the beginning of the stretch gesture
                    [validTouches addObjectsInSet:touchesInScrap];
                    [possibleTouches removeObjectsInSet:touchesInScrap];
                    // set the stretched scrap
                    scrap = pinchedScrap;
                    [scrap.layer removeAllAnimations];
                    // sort the valid touches into clockwise order
                    [self sortValidTouches];
                    // let everyone know that we own these 4 touches now
                    [self.scrapDelegate ownershipOfTouches:[validTouches set] isGesture:self];
                    // skew begins with identity. as the touches move,
                    // the average quad will be transformed and stored
                    // into skewTransform
                    skewTransform = CATransform3DIdentity;
                    // since the skew must begin from 0,0, the adjust
                    // stores the offset of the scrap's origin point
                    // inside of its container. this way, we can know
                    // where the scrap's 0,0 should be in reference
                    // to the transform we're making
                    adjust = [self.scrapDelegate beginStretchForScrap:scrap];
                    firstQ = [MMStretchHelper getQuadFrom:validTouches inView:self.view];
                    // the normalized raw quad will store the normalized
                    // points of the touches inside the scrap. this is
                    // useful after the stretch ends to ensure that
                    // any pan gesture's anchor is in the correct place
                    // for its touches
                    normalFirstQ = [self getNormalizedRawQuad];
                    
                    // now get all the properties of the gesture
                    if(pinchedScrap == pinchScrapGesture1.scrap){
                        startingScrapProperties = pinchScrapGesture1.startingScrapProperties;
                        startingPageForScrap = pinchScrapGesture1.startingPageForScrap;
                    }else{
                        startingScrapProperties = pinchScrapGesture2.startingScrapProperties;
                        startingPageForScrap = pinchScrapGesture2.startingPageForScrap;
                    }
                    break;
                }else{
                    [allPossibleTouches removeObjectsInSet:touchesInScrap];
                }
            }else{
                // don't allow touches in any scrap that's above our target scrap
                [allPossibleTouches removeObjectsInSet:touchesInScrap];
            }
        }
    }
}

// this will return the average normalized location
// of the first 2 valid touches. these are the two touches
// that will be used in the pan gesture if the stretch
// gesture fails. this normalized location will match
// the anchor point that the pan gesture should use for
// those 2 touches.
-(CGPoint) normalizedLocationOfValidTouches{
    __block CGPoint ret = CGPointZero;
    int count = MIN((int)[validTouches count], 2);
    [validTouches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL*stop){
        if(obj == upperLeftTouch){
            ret = CGPointMake(ret.x + normalFirstQ.upperLeft.x / count,
                              ret.y + normalFirstQ.upperLeft.y / count);
        }else if(obj == upperRightTouch){
            ret = CGPointMake(ret.x + normalFirstQ.upperRight.x / count,
                              ret.y + normalFirstQ.upperRight.y / count);
        }else if(obj == lowerRightTouch){
            ret = CGPointMake(ret.x + normalFirstQ.lowerRight.x / count,
                              ret.y + normalFirstQ.lowerRight.y / count);
        }else if(obj == lowerLeftTouch){
            ret = CGPointMake(ret.x + normalFirstQ.lowerLeft.x / count,
                              ret.y + normalFirstQ.lowerLeft.y / count);
        }
        if(idx == 1){
            stop[0] = YES;
            return;
        }
    }];
    return ret;
}

// this method looks at our internal state for the gesture, and updates
// the UIGestureRecognizer.state to match
-(void) updateState{
    if(self.state == UIGestureRecognizerStatePossible){
        if([ignoredTouches count] > 0 ||
           [possibleTouches count] > 0 ||
           [validTouches count] > 0){
            self.state = UIGestureRecognizerStateBegan;
        }
    }else if([possibleTouches count] == 0 &&
           [ignoredTouches count] == 0 &&
           [validTouches count] == 0){
        self.state = UIGestureRecognizerStateEnded;
    }else{
        self.state = UIGestureRecognizerStateChanged;
    }
    [self updateValidTouches];
}

// this method takes all valid touches, and sorts them in the OrderedSet
// so that their touch locations are in clockwise order
-(void) sortValidTouches{
    [MMStretchHelper sortTouchesClockwise:validTouches];
    
    upperLeftTouch = [validTouches objectAtIndex:0];
    upperRightTouch = [validTouches objectAtIndex:1];
    lowerRightTouch = [validTouches objectAtIndex:2];
    lowerLeftTouch = [validTouches objectAtIndex:3];
}

#pragma mark - UIGestureRecognizer Subclass

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

- (BOOL)shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

- (BOOL)shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

- (void)reset{
    [super reset];
    [validTouches removeAllObjects];
    [ignoredTouches removeAllObjects];
    [possibleTouches removeAllObjects];

    upperLeftTouch = nil;
    upperRightTouch = nil;
    lowerLeftTouch = nil;
    lowerRightTouch = nil;
}


-(void) removeTouchFromStoredQuadTouches:(UITouch*)t{
    if(t == upperLeftTouch){
        upperLeftTouch = nil;
    }else if(t == upperRightTouch){
        upperRightTouch = nil;
    }else if(t == lowerRightTouch){
        lowerRightTouch = nil;
    }else if(t == lowerLeftTouch){
        lowerLeftTouch = nil;
    }
}

#pragma mark - Touch Methods

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesBegan:touches];
}

-(void) touchesBegan:(NSSet *)touches{
    if([self.scrapDelegate panScrapRequiresLongPress] && ![possibleTouches intersectsSet:touches] &&
       !pinchScrapGesture1.scrap && !pinchScrapGesture2.scrap){
        // ignore touches in the possible set, b/c if they're already in there during
        // this Began method call, then that means they've been blessed. also allow
        // all touches if a scrap is already being panned
        [ignoredTouches addObjectsInSet:touches];
        return;
    }
    [touches enumerateObjectsUsingBlock:^(id touch, BOOL* stop){
        [possibleTouches addObject:touch];
    }];
    [self updateState];
//    [self say:@"sbegan" ISee:touches];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self updateState];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [touches enumerateObjectsUsingBlock:^(id touch, BOOL* stop){
        [possibleTouches removeObject:touch];
        [validTouches removeObject:touch];
        [ignoredTouches removeObject:touch];
        [self removeTouchFromStoredQuadTouches:touch];
    }];
    if(pinchScrapGesture1.paused){
        [pinchScrapGesture1 relinquishOwnershipOfTouches:touches];
        [pinchScrapGesture2 relinquishOwnershipOfTouches:touches];
    }
    [self updateState];
//    [self say:@"scancelled" ISee:touches];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [touches enumerateObjectsUsingBlock:^(id touch, BOOL* stop){
        [possibleTouches removeObject:touch];
        [validTouches removeObject:touch];
        [ignoredTouches removeObject:touch];
        [self removeTouchFromStoredQuadTouches:touch];
    }];
    if(pinchScrapGesture1.paused){
        [pinchScrapGesture1 relinquishOwnershipOfTouches:touches];
        [pinchScrapGesture2 relinquishOwnershipOfTouches:touches];
    }
    [self updateState];
//    [self say:@"sended" ISee:touches];
}


#pragma mark - Transforms for bounce

-(CATransform3D) transformForBounceAtScale:(CGFloat) scale{
    CGPoint centerOfQ = CGPointMake(firstQ.upperLeft.x / 4 + firstQ.upperRight.x / 4 + firstQ.lowerRight.x / 4 + firstQ.lowerLeft.x / 4,
                                    firstQ.upperLeft.y / 4 + firstQ.upperRight.y / 4 + firstQ.lowerRight.y / 4 + firstQ.lowerLeft.y / 4);
    
    CGAffineTransform translateFromCenter = CGAffineTransformMakeTranslation(-centerOfQ.x, -centerOfQ.y);
    CGAffineTransform translateToCenter = CGAffineTransformMakeTranslation(centerOfQ.x, centerOfQ.y);
    CGAffineTransform scaleSmall = CGAffineTransformMakeScale(scale, scale);
    
    CGAffineTransform scalePointAroundCenterTransform = CGAffineTransformConcat(CGAffineTransformConcat(translateFromCenter, scaleSmall), translateToCenter);
    
    Quadrilateral scaledQ;
    scaledQ.upperLeft = CGPointApplyAffineTransform(firstQ.upperLeft, scalePointAroundCenterTransform);
    scaledQ.upperRight = CGPointApplyAffineTransform(firstQ.upperRight, scalePointAroundCenterTransform);
    scaledQ.lowerLeft = CGPointApplyAffineTransform(firstQ.lowerLeft, scalePointAroundCenterTransform);
    scaledQ.lowerRight = CGPointApplyAffineTransform(firstQ.lowerRight, scalePointAroundCenterTransform);
    
    return [MMStretchHelper transformQuadrilateral:[MMStretchHelper adjustedQuad:firstQ by:adjust] toQuadrilateral:[MMStretchHelper adjustedQuad:scaledQ by:adjust]];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Disallow recognition of tap gestures in the segmented control.
    if ([touch.view isKindOfClass:[UIControl class]]) {
//        DebugLog(@"ignore touch in %@", NSStringFromClass([self class]));
        return NO;
    }
    return YES;
}

// this maps all of the initial 4 touch points into normalized
// touch points inside the scrap. this data becomes useful later
// when the stretch ends to help us calculate the new anchor
// point for the pan gesture
-(Quadrilateral) getNormalizedRawQuad{
    return [MMStretchHelper getNormalizedRawQuadFrom:validTouches inView:self.scrap];
}

@end
