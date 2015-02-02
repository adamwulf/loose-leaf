//
//  MMTouchDotView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMTouchDotView.h"
#import "MMTouchDotGestureRecognizer.h"

@implementation MMTouchDotView{
    MMTouchDotGestureRecognizer* touchGesture;
    NSMutableDictionary* dots;
    CGFloat dotWidth;
    UIColor* dotColor;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        touchGesture = [MMTouchDotGestureRecognizer sharedInstace];
        [touchGesture setTouchDelegate:self];
        dots = [NSMutableDictionary dictionary];
        dotWidth = 20;
        dotColor = [UIColor colorWithRed: 62.0/255.0 green: 151.0/255.0 blue: 0.8 alpha: 1.0];
        self.userInteractionEnabled = NO;
    }
    return self;
}

-(void) updateTouch:(UITouch*)t{
    NSMutableSet* seenKeys = [NSMutableSet set];
    CGPoint loc = [t locationInView:self];
    NSNumber* key = [NSNumber numberWithUnsignedInteger:t.hash];
    [seenKeys addObject:key];
    UIView* dot = [dots objectForKey:key];
    if(!dot){
        dot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dotWidth, dotWidth)];
        dot.backgroundColor = dotColor;
        dot.layer.cornerRadius = dotWidth/2;
        dot.tag = key.unsignedIntegerValue;
//        [self addSubview:dot];
        [dots setObject:dot forKey:key];
        
        UIView* anim = [[UIView alloc] initWithFrame:dot.frame];
        anim.opaque = NO;
        anim.backgroundColor = [UIColor clearColor];
        anim.layer.cornerRadius = dotWidth/2;
        anim.layer.borderColor = dotColor.CGColor;
        anim.layer.borderWidth = 3;
        anim.center = loc;
        anim.tag = NSUIntegerMax;
        [self addSubview:anim];
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            anim.transform = CGAffineTransformMakeScale(1.5, 1.5);
            anim.alpha = 0;
        } completion:^(BOOL finished){
            [anim removeFromSuperview];
        }];
    }
    dot.center = loc;
}

-(void) removeViewFor:(UITouch*)t{
    NSNumber* key = [NSNumber numberWithUnsignedInteger:t.hash];
    UIView* dot = [dots objectForKey:key];
    [dot removeFromSuperview];
    [dots removeObjectForKey:key];
}

-(void) didMoveToSuperview{
    [touchGesture.view removeGestureRecognizer:touchGesture];
    [self.superview addGestureRecognizer:touchGesture];
}

-(void) dotTouchesBegan:(NSSet *)touches{
    for(UITouch* t in touches){
        [self updateTouch:t];
    }
}

-(void) dotTouchesMoved:(NSSet *)touches{
    for(UITouch* t in touches){
        [self updateTouch:t];
    }
}

-(void) dotTouchesEnded:(NSSet *)touches{
    for(UITouch* t in touches){
        [self removeViewFor:t];
    }
}

-(void) dotTouchesCancelled:(NSSet *)touches{
    for(UITouch* t in touches){
        [self removeViewFor:t];
    }
}

#pragma mark - Ignore Touches

/**
 * these two methods make sure that touches on this
 * UIView always passthrough to any views underneath it
 */
-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return nil;
}

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return NO;
}



@end
