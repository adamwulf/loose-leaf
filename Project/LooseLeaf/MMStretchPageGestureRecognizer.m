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
#import "MMDebugQuadrilateralView.h"

@implementation MMStretchPageGestureRecognizer{
    NSMutableOrderedSet* additionalTouches;
    
    CGPoint adjust;
    Quadrilateral firstQ;
    Quadrilateral secondQ;
    CATransform3D skewTransform;
    
    UIView* stretchedPage;
    
    MMDebugQuadrilateralView* debugView1;
    MMDebugQuadrilateralView* debugView2;
    
    // initial scroll offset of our view vs the window
    CGPoint initialOffset;
}

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
    stretchedPage.layer.borderColor = [[UIColor redColor] CGColor];
    stretchedPage.layer.borderWidth = 2;
    
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
    
    [self.view addSubview:debugView1];
    [self.view addSubview:debugView2];
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(!debugView1){
        debugView1 = [[MMDebugQuadrilateralView alloc] initWithFrame:self.view.bounds];
        debugView2 = [[MMDebugQuadrilateralView alloc] initWithFrame:self.view.bounds];
    }
    
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

            [debugView1 setQuadrilateral:firstQ];
            [debugView2 setQuadrilateral:secondQ];
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
        [debugView1 removeFromSuperview];
        [debugView2 removeFromSuperview];
        pinchedPage.alpha = 1;
        [stretchedPage removeFromSuperview];
        stretchedPage = nil;
    }
}

#pragma mark - UIGestureRecognizerSubclass

-(CGPoint) locationInView:(UIView *)view{
    CGPoint p = CGPointZero;
    for (UITouch* touch in validTouches) {
        CGPoint loc = [touch locationInView:view];
        p.x += loc.x;
        p.y += loc.y;
    }
    if([validTouches count]){
        p.x /= [validTouches count];
        p.y /= [validTouches count];
    }
    return p;
}

@end
