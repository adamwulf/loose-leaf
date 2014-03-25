//
//  MMStretchGestureRecognizer.m
//  ShapeShifter
//
//  Created by Adam Wulf on 2/21/14.
//  Copyright (c) 2014 Adam Wulf. All rights reserved.
//

#import "MMStretchScrapGestureRecognizer.h"
#import "Constants.h"
#import "NSMutableSet+Extras.h"
#import "MMVector.h"
#import "MMPanAndPinchScrapGestureRecognizer.h"
#import "MMPanAndPinchGestureRecognizer.h"

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
}

@synthesize pinchScrapGesture1;
@synthesize pinchScrapGesture2;
@synthesize scrapDelegate;
@synthesize scrap = scrap;
@synthesize skewTransform = skewTransform;

-(id) init{
    self = [super init];
    if(self){
        validTouches = [[NSMutableOrderedSet alloc] init];
        possibleTouches = [[NSMutableOrderedSet alloc] init];
        ignoredTouches = [[NSMutableSet alloc] init];
        self.delaysTouchesEnded = NO;
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
    }
    return self;
}

-(void) cancel{
    if(self.enabled){
        self.enabled = NO;
        self.enabled = YES;
    }
}

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
    [self touchesBegan:newPossibleTouches withEvent:nil];
}


#pragma mark - Quadrilateral

// this quad is used as the basis of our transform. it averages
// out all of the touch points into a parallelogram instead of
// a generic quad
-(Quadrilateral) getQuad{
    return [self generateAverageQuadFor:[self getRawQuad]];
}

// this generates a Quadrilateral struct from the clockwise touch locations.
// note. the touches are only sorted at the beginning of the gesture. so this means
// that the touches are guaranteed form a clockwise quad only at the very beginning of
// the gesture, but the user can spin, flip, and mix their fingers to create self
// intersecting quads.
-(Quadrilateral) getRawQuad{
    __block Quadrilateral output;
    [[self validTouches] enumerateObjectsUsingBlock:^(UITouch* touch, NSUInteger idx, BOOL* stop){
        CGPoint location = [touch locationInView:self.view];
        if(idx == 0){
            output.upperLeft = location;
        }else if(idx == 1){
            output.upperRight = location;
        }else if(idx == 2){
            output.lowerRight = location;
        }else if(idx == 3){
            output.lowerLeft = location;
        }
    }];
    return output;
}

// this maps all of the initial 4 touch points into normalized
// touch points inside the scrap. this data becomes useful later
// when the stretch ends to help us calculate the new anchor
// point for the pan gesture
-(Quadrilateral) getNormalizedRawQuad{
    __block Quadrilateral output;
    [[self validTouches] enumerateObjectsUsingBlock:^(UITouch* touch, NSUInteger idx, BOOL* stop){
        CGPoint location = [touch locationInView:self.scrap];
        location = NormalizePointTo(location, scrap.bounds.size);
        if(idx == 0){
            output.upperLeft = location;
        }else if(idx == 1){
            output.upperRight = location;
        }else if(idx == 2){
            output.lowerRight = location;
        }else if(idx == 3){
            output.lowerLeft = location;
        }
    }];
    return output;
}

// if we use the getRawQuad only, then the transform we create by skewing that
// raw quad will manipulate dramatically in 3d. This transform ends up to give
// terrible results if the quad is manipulated by the user to be concave.
//
// this methods helps get around these awkward transforms by created an average of the
// user's finger positions instead of exact quad transforms.
//
// 1. find the midpoints along each edge of the quad.
// 2. find the vectors beteween opposite midpoints
// 3. create new quad endpoints using these vectors
// 4. this will create an output parallelogram from the input quad
-(Quadrilateral) generateAverageQuadFor:(Quadrilateral)q{
    Quadrilateral ret;
    
    CGPoint midLeft = CGPointMake((q.upperLeft.x + q.lowerLeft.x)/2, (q.upperLeft.y + q.lowerLeft.y)/2);
    CGPoint midRight = CGPointMake((q.upperRight.x + q.lowerRight.x)/2, (q.upperRight.y + q.lowerRight.y)/2);
    
    MMVector* lengthVector = [MMVector vectorWithPoint:midLeft andPoint:midRight];
    
    CGPoint midTop = CGPointMake((q.upperLeft.x + q.upperRight.x)/2, (q.upperLeft.y + q.upperRight.y)/2);
    CGPoint midLow = CGPointMake((q.lowerLeft.x + q.lowerRight.x)/2, (q.lowerLeft.y + q.lowerRight.y)/2);
    
    
    ret.upperLeft = [lengthVector pointFromPoint:midTop distance:-0.5];
    ret.upperRight = [lengthVector pointFromPoint:midTop distance:0.5];
    ret.lowerRight = [lengthVector pointFromPoint:midLow distance:0.5];
    ret.lowerLeft = [lengthVector pointFromPoint:midLow distance:-0.5];
    
    return ret;
}

// valid touches are updated whenever our state updates
// or we are told of touch ownership updates. this method
// ensures that we own all of our valid touches, and if for
// any reason valid touches < 4, then it reverts back to a
// non active state and keeps all known touches in either
// possible or ignored
-(void) updateValidTouches{
    if([validTouches count] == 4){
        Quadrilateral secondQ = [self getQuad];
        Quadrilateral q1 = [self adjustedQuad:firstQ by:adjust];
        Quadrilateral q2 = [self adjustedQuad:secondQ by:adjust];
        // generate the actual transform between the two quads
        skewTransform = [MMStretchScrapGestureRecognizer transformQuadrilateral:q1 toQuadrilateral:q2];

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
            scrap = nil;
        }
    }
    if([validTouches count] != 4 && scrap){
        // valid touches must be exactly 4, otherwise
        // we should stop the stretching
        [self.scrapDelegate endStretchWithoutSplittingScrap:scrap atNormalPoint:[self normalizedLocationOfValidTouches]];
        [possibleTouches addObjectsInOrderedSet:validTouches];
        [validTouches removeAllObjects];
        scrap = nil;
    }
    if([possibleTouches count] == 4){
        // if we have 4 possible touches, then we should
        // check the scrap panning gestures to see if either
        // of them hold all 4 touches. calling out to our
        // delegate lets us filter out any touches that are
        // within the bounds of the scrap but would land on some
        // other scrap that's above it in view
        NSArray* scrapsToLookAt = scrapDelegate.scraps;
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
                    firstQ = [self getQuad];
                    // the normalized raw quad will store the normalized
                    // points of the touches inside the scrap. this is
                    // useful after the stretch ends to ensure that
                    // any pan gesture's anchor is in the correct place
                    // for its touches
                    normalFirstQ = [self getNormalizedRawQuad];
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
    int count = MIN([validTouches count], 2);
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
    __block CGPoint center = CGPointZero;
    [validTouches enumerateObjectsUsingBlock:^(UITouch* touch, NSUInteger idx, BOOL *stop){
        CGPoint location = [touch locationInView:self.view];
        center.x += location.x / [validTouches count];
        center.y += location.y / [validTouches count];
    }];
    [validTouches sortUsingComparator:^NSComparisonResult(UITouch* obj1, UITouch* obj2){
        CGPoint a = [obj1 locationInView:self.view];
        CGPoint b = [obj2 locationInView:self.view];
        
        // compute the cross product of vectors (center -> a) x (center -> b)
        int det = (a.x-center.x) * (b.y-center.y) - (b.x - center.x) * (a.y - center.y);
        if (det < 0)
            return NSOrderedAscending;
        if (det > 0)
            return NSOrderedDescending;
        
        // points a and b are on the same line from the center
        // check which point is closer to the center
        int d1 = (a.x-center.x) * (a.x-center.x) + (a.y-center.y) * (a.y-center.y);
        int d2 = (b.x-center.x) * (b.x-center.x) + (b.y-center.y) * (b.y-center.y);
        return d1 > d2 ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    upperLeftTouch = [validTouches objectAtIndex:0];
    upperRightTouch = [validTouches objectAtIndex:1];
    lowerRightTouch = [validTouches objectAtIndex:2];
    lowerLeftTouch = [validTouches objectAtIndex:3];
}

// move the quad by the input point amount.
// this is useful to move our quad to a meaningful
// 0,0 point when we calculate our transform
-(Quadrilateral) adjustedQuad:(Quadrilateral)a by:(CGPoint)p{
    Quadrilateral output = a;
    output.upperLeft.x -= p.x;
    output.upperLeft.y -= p.y;
    output.upperRight.x -= p.x;
    output.upperRight.y -= p.y;
    output.lowerRight.x -= p.x;
    output.lowerRight.y -= p.y;
    output.lowerLeft.x -= p.x;
    output.lowerLeft.y -= p.y;
    
    return output;
}

#pragma mark - UIGestureRecognizer

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

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
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
    
    return [MMStretchScrapGestureRecognizer transformQuadrilateral:[self adjustedQuad:firstQ by:adjust] toQuadrilateral:[self adjustedQuad:scaledQ by:adjust]];
}

#pragma mark - OpenCV Transform

// http://stackoverflow.com/questions/9470493/transforming-a-rectangle-image-into-a-quadrilateral-using-a-catransform3d

+ (CATransform3D)transformQuadrilateral:(Quadrilateral)origin toQuadrilateral:(Quadrilateral)destination {
    
    CvPoint2D32f *cvsrc = [self openCVMatrixWithQuadrilateral:origin];
    CvMat *src_mat = cvCreateMat( 4, 2, CV_32FC1 );
    cvSetData(src_mat, cvsrc, sizeof(CvPoint2D32f));
    
    CvPoint2D32f *cvdst = [self openCVMatrixWithQuadrilateral:destination];
    CvMat *dst_mat = cvCreateMat( 4, 2, CV_32FC1 );
    cvSetData(dst_mat, cvdst, sizeof(CvPoint2D32f));
    
    CvMat *H = cvCreateMat(3,3,CV_32FC1);
    cvFindHomography(src_mat, dst_mat, H);
    cvReleaseMat(&src_mat);
    cvReleaseMat(&dst_mat);
    
    CATransform3D transform = [self transform3DWithCMatrix:H->data.fl];
    cvReleaseMat(&H);
    
    return transform;
}

+ (CvPoint2D32f *)openCVMatrixWithQuadrilateral:(Quadrilateral)origin {
    
    CvPoint2D32f *cvsrc = (CvPoint2D32f *)malloc(4*sizeof(CvPoint2D32f));
    cvsrc[0].x = origin.upperLeft.x;
    cvsrc[0].y = origin.upperLeft.y;
    cvsrc[1].x = origin.upperRight.x;
    cvsrc[1].y = origin.upperRight.y;
    cvsrc[2].x = origin.lowerRight.x;
    cvsrc[2].y = origin.lowerRight.y;
    cvsrc[3].x = origin.lowerLeft.x;
    cvsrc[3].y = origin.lowerLeft.y;
    return cvsrc;
}

+ (CATransform3D)transform3DWithCMatrix:(float *)matrix {
    CATransform3D transform = CATransform3DIdentity;
    
    transform.m11 = matrix[0];
    transform.m21 = matrix[1];
    transform.m41 = matrix[2];
    
    transform.m12 = matrix[3];
    transform.m22 = matrix[4];
    transform.m42 = matrix[5];
    
    transform.m14 = matrix[6];
    transform.m24 = matrix[7];
    transform.m44 = matrix[8];
    
    return transform;
}



@end
