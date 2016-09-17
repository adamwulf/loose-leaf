//
//  MMStretchPageGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 9/16/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMStretchPageGestureRecognizer.h"
#import "MMStretchHelper.h"
#import "UIView+Animations.h"

@implementation MMStretchPageGestureRecognizer{
    NSMutableOrderedSet* additionalTouches;
    
    CGPoint adjust;
    Quadrilateral firstQ;
    Quadrilateral secondQ;
    CATransform3D skewTransform;
    // the normalized locations of each touch at the beginning
    // of the gesture
    Quadrilateral normalFirstQ;
    UIView* stretchedPage;
    
    // initial scroll offset of our view vs the window
    CGPoint initialOffset;
}

@dynamic pinchDelegate;

-(id) init{
    self = [super init];
    if(self){
        additionalTouches = [[NSMutableOrderedSet alloc] init];
        [self reset];
        self.delegate = self;
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    if(self){
        additionalTouches = [[NSMutableOrderedSet alloc] init];
        [self reset];
        self.delegate = self;
    }
    return self;
}


#pragma mark - Touch Methods

-(NSOrderedSet<UITouch*>*) allFourTouches{
    NSMutableOrderedSet* allFourTouches = [NSMutableOrderedSet orderedSetWithOrderedSet:validTouches];
    
    [allFourTouches addObjectsInOrderedSet:additionalTouches];
    [MMStretchHelper sortTouchesClockwise:allFourTouches];
    
    return allFourTouches;
}

-(void) initializeStretch{
    
    stretchedPage = [pinchedPage snapshotViewAfterScreenUpdates:NO];
    
    [[self view] addSubview:stretchedPage];
    CGRect pageFrame = [pinchedPage convertRect:[pinchedPage bounds] toView:[self view]];
    pageFrame = [MMShadowedView expandBounds:pageFrame];
    [stretchedPage setFrame:pageFrame];
    
    pinchedPage.alpha = 0;
    
    [UIView setAnchorPoint:CGPointMake(0, 0) forView:stretchedPage];
    
    stretchedPage.layer.transform = CATransform3DIdentity;
    adjust = [stretchedPage convertPoint:CGPointZero toView:nil];
    firstQ = [MMStretchHelper getQuadFrom:[self allFourTouches] inView:nil];
    initialOffset = [[self view] convertPoint:CGPointZero toView:nil];

    [MMStretchHelper logQuadrilateral:firstQ];
    
    skewTransform = CATransform3DIdentity;
    
    normalFirstQ = [MMStretchHelper getNormalizedRawQuadFrom:[self allFourTouches] inView:pinchedPage];
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITouch* touch in touches) {
        if([validTouches count] < 2){
            [super touchesBegan:[NSSet setWithObject:touch] withEvent:event];
            
            if([additionalTouches count] == 2){
                // that was the 4th touch
                [self initializeStretch];
            }
        }else if([additionalTouches count] < 2){
            CGPoint locationInPage = [touch locationInView:pinchedPage];

            if(CGRectContainsPoint([pinchedPage bounds], locationInPage)){
                [additionalTouches addObject:touch];
                
                if([additionalTouches count] == 2 && [validTouches count] == 2){
                    // that was the 4th touch
                    [self initializeStretch];
                }
            }else{
                [self ignoreTouch:touch forEvent:event];
            }
        }else{
            [self ignoreTouch:touch forEvent:event];
        }
    }
}

-(void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITouch* touch in touches) {
        if([validTouches containsObject:touch]){
            [super touchesMoved:[NSSet setWithObject:touch] withEvent:event];
        }else if([additionalTouches count] == 2 && [validTouches count] == 2){
            secondQ = [MMStretchHelper getQuadFrom:[self allFourTouches] inView:nil];

            CGPoint currentOffset = [[self view] convertPoint:CGPointZero toView:nil];
            CGPoint offsetDelta = CGPointMake(initialOffset.x - currentOffset.x, initialOffset.y - currentOffset.y);
            
            Quadrilateral q1 = [MMStretchHelper adjustedQuad:firstQ by:adjust];
            Quadrilateral q2 = [MMStretchHelper adjustedQuad:secondQ by:adjust];
            // generate the actual transform between the two quads
            skewTransform = [MMStretchHelper transformQuadrilateral:q1 toQuadrilateral:q2];
            stretchedPage.layer.transform = CATransform3DConcat(skewTransform, CATransform3DMakeTranslation(offsetDelta.x, offsetDelta.y, 0));

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
            NSOrderedSet<UITouch*>* fourTouches = [self allFourTouches];
            
            if(scaleW > scaleH * 2){
                // scaling the quad wide
                touches1 = [NSOrderedSet orderedSetWithObjects:[fourTouches objectAtIndex:0], [fourTouches objectAtIndex:3], nil];
                touches2 = [NSOrderedSet orderedSetWithObjects:[fourTouches objectAtIndex:1], [fourTouches objectAtIndex:2], nil];
                normalCenter1 = AveragePoints(normalFirstQ.upperLeft, normalFirstQ.lowerLeft);
                normalCenter2 = AveragePoints(normalFirstQ.upperRight, normalFirstQ.lowerRight);
            }else if(scaleH > scaleW * 2){
                // scaling the quad tall
                touches1 = [NSOrderedSet orderedSetWithObjects:[fourTouches objectAtIndex:0], [fourTouches objectAtIndex:1], nil];
                touches2 = [NSOrderedSet orderedSetWithObjects:[fourTouches objectAtIndex:2], [fourTouches objectAtIndex:3], nil];
                normalCenter1 = AveragePoints(normalFirstQ.upperLeft, normalFirstQ.upperRight);
                normalCenter2 = AveragePoints(normalFirstQ.lowerRight, normalFirstQ.lowerLeft);
            }

            if(touches1){
                
                CGPoint loc1 = [self averageLocationForTouches:touches1 inView:nil];
                CGPoint loc2 = [self averageLocationForTouches:touches2 inView:nil];
                CGPoint offset = CGPointMake(loc2.x - loc1.x, loc2.y - loc1.y);
                
                [[self pinchDelegate] didStretchToDuplicatePageWithGesture:self withOffset:offset];
                
                for (UITouch* touch in touches2) {
                    [self ignoreTouch:touch forEvent:event];
                }
                [validTouches removeObjectsInArray:[touches2 array]];
                [additionalTouches removeObjectsInArray:[touches2 array]];
                [validTouches addObjectsFromArray:[additionalTouches array]];
                [additionalTouches removeAllObjects];
                
                [self finalizeStretchIfNeeded];
            }
        }
    }
}

-(void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITouch* touch in touches) {
        if([validTouches containsObject:touch]){
            [super touchesEnded:[NSSet setWithObject:touch] withEvent:event];
        }else{
            [additionalTouches removeObject:touch];
        }
    }

    [self finalizeStretchIfNeeded];
}

-(void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UITouch* touch in touches) {
        if([validTouches containsObject:touch]){
            [super touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
        }else{
            [additionalTouches removeObject:touch];
        }
    }
    
    [self finalizeStretchIfNeeded];
}

-(void) finalizeStretchIfNeeded{
    if([validTouches count] + [additionalTouches count] < 4){
        skewTransform = CATransform3DIdentity;
        stretchedPage.layer.transform = skewTransform;
        [UIView setAnchorPoint:CGPointMake(.5, .5) forView:stretchedPage];
        pinchedPage.alpha = 1;
        [stretchedPage removeFromSuperview];
        stretchedPage = nil;
    }
}

#pragma mark - UIGestureRecognizerSubclass

-(CGPoint) averageLocationForTouches:(NSOrderedSet<UITouch*>*)touches inView:(UIView*)view{
    CGPoint p = CGPointZero;
    for (UITouch* touch in touches) {
        CGPoint loc = [touch locationInView:view];
        p.x += loc.x;
        p.y += loc.y;
    }
    if([touches count]){
        p.x /= [touches count];
        p.y /= [touches count];
    }
    return p;
}

-(CGPoint) locationInView:(UIView *)view{
    return [self averageLocationForTouches:validTouches inView:view];
}

@end
