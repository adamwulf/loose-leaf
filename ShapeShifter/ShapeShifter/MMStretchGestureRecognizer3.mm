//
//  MMStretchGestureRecognizer.m
//  ShapeShifter
//
//  Created by Adam Wulf on 2/21/14.
//  Copyright (c) 2014 Adam Wulf. All rights reserved.
//

#import "MMStretchGestureRecognizer3.h"
#import "Constants.h"
#import "NSMutableSet+Extras.h"
#import "MMVector.h"

@implementation MMStretchGestureRecognizer3{
    MMVector* startHVector;
    MMVector* startVVector;
}


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

-(NSArray*)touches{
    return [validTouches array];
}

-(Quadrilateral) getRawQuad{
    __block Quadrilateral output;
    [[self touches] enumerateObjectsUsingBlock:^(UITouch* touch, NSUInteger idx, BOOL* stop){
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


-(Quadrilateral) getQuad{
    return [self generateAverageQuadWithRotationFor:[self getRawQuad]];
}

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

-(Quadrilateral) generateAverageQuadWithRotationFor:(Quadrilateral)q{
    Quadrilateral currQuad = [self generateAverageQuadFor:q];
    
    MMVector* currHVector = [self vectorHForQuad:q];
    MMVector* currVVector = [self vectorVForQuad:q];
    
    CGFloat angleHRotation = [startHVector angleBetween:currHVector];
    CGFloat angleVRotation = [startVVector angleBetween:currVVector];
    CGFloat angleAvg = (angleHRotation + angleVRotation) / 2;
    
    // chose the angle with the most change
    //    angleAvg = ABS(angleHRotation) > ABS(angleVRotation) ? angleHRotation : angleVRotation;
    //    NSLog(@"angle rotation: %f  and %f  avg: %f", angleHRotation, angleVRotation, angle);
    //    NSLog(@"ah:  %f  av: %f", angleHRotation, angleVRotation);
    //    NSLog(@"cos: %f  and %f", cosf(angleHRotation), cosf(angleVRotation));
    //    NSLog(@"sin: %f  and %f", sinf(angleHRotation), sinf(angleVRotation));
    //    NSLog(@"%f + %f = %f     cos: %f  sin: %f", angleHRotation, angleVRotation, angleAvg, cosf(angleAvg), sinf(angleAvg));
    
    
    
    Quadrilateral ret;
    if(sinf(angleAvg) > 0){
        ret.upperLeft = [self mixPoints:currQuad.upperLeft with:currQuad.upperRight for:angleAvg];
        ret.upperRight = [self mixPoints:currQuad.upperRight with:currQuad.lowerRight for:angleAvg];
        ret.lowerLeft = [self mixPoints:currQuad.lowerLeft with:currQuad.upperLeft for:angleAvg];
        ret.lowerRight = [self mixPoints:currQuad.lowerRight with:currQuad.lowerLeft for:angleAvg];
    }else{
        // rotate opposite direction
        ret.upperLeft = [self mixPoints:currQuad.upperLeft with:currQuad.lowerLeft for:angleAvg];
        ret.upperRight = [self mixPoints:currQuad.upperRight with:currQuad.upperLeft for:angleAvg];
        ret.lowerLeft = [self mixPoints:currQuad.lowerLeft with:currQuad.lowerRight for:angleAvg];
        ret.lowerRight = [self mixPoints:currQuad.lowerRight with:currQuad.upperRight for:angleAvg];
    }
    
    return ret;
}



- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

- (void)reset{
    [super reset];
    [validTouches removeAllObjects];
    [ignoredTouches removeAllObjects];
    [possibleTouches removeAllObjects];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [touches enumerateObjectsUsingBlock:^(id touch, BOOL* stop){
        [possibleTouches addObject:touch];
    }];
    [self checkStatus];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self checkStatus];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [touches enumerateObjectsUsingBlock:^(id touch, BOOL* stop){
        [possibleTouches removeObject:touch];
        [validTouches removeObject:touch];
        [ignoredTouches removeObject:touch];
    }];
    [self checkStatus];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [touches enumerateObjectsUsingBlock:^(id touch, BOOL* stop){
        [possibleTouches removeObject:touch];
        [validTouches removeObject:touch];
        [ignoredTouches removeObject:touch];
    }];
    [self checkStatus];
}


-(void) checkStatus{
    if([possibleTouches count] == 4){
        [validTouches addObjectsInOrderedSet:possibleTouches];
        [possibleTouches removeAllObjects];
        [self sortValidTouches];
    }else if([validTouches count] < 4){
        if(self.state != UIGestureRecognizerStatePossible){
            self.state = UIGestureRecognizerStateEnded;
        }
    }else{
        if(self.state == UIGestureRecognizerStatePossible){
            self.state = UIGestureRecognizerStateBegan;
        }else{
            self.state = UIGestureRecognizerStateChanged;
        }
    }
    
    if(self.state == UIGestureRecognizerStateBegan){
        Quadrilateral currQuad = [self getRawQuad];
        startHVector = [self vectorHForQuad:currQuad];
        startVVector = [self vectorVForQuad:currQuad];
    }
}

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
}

-(CGPoint) mixPoints:(CGPoint)p1 with:(CGPoint)p2 for:(CGFloat)a1{
    CGPoint retP = CGPointMake(p1.x * cosf(a1) + p2.x * (1-cosf(a1)),
                               p1.y * cosf(a1) + p2.y * (1-cosf(a1)));
    //    NSLog(@"mixed %f with %f using %f and %f got %f", p1.x, p2.x, cosf(a1), (1-cosf(a1)), retP.x);
    return retP;
}


-(MMVector*) vectorHForQuad:(Quadrilateral)q{
    CGPoint midLeft = CGPointMake((q.upperLeft.x + q.lowerLeft.x)/2, (q.upperLeft.y + q.lowerLeft.y)/2);
    CGPoint midRight = CGPointMake((q.upperRight.x + q.lowerRight.x)/2, (q.upperRight.y + q.lowerRight.y)/2);
    return [MMVector vectorWithPoint:midLeft andPoint:midRight];
}

-(MMVector*) vectorVForQuad:(Quadrilateral)q{
    CGPoint midTop = CGPointMake((q.upperLeft.x + q.upperRight.x)/2, (q.upperLeft.y + q.upperRight.y)/2);
    CGPoint midLow = CGPointMake((q.lowerLeft.x + q.lowerRight.x)/2, (q.lowerLeft.y + q.lowerRight.y)/2);
    return [MMVector vectorWithPoint:midTop andPoint:midLow];
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
