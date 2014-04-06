//
//  MMTouchDotGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 4/5/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMTouchDotGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation MMTouchDotGestureRecognizer{
    NSMutableSet* activeTouches;
}

static MMTouchDotGestureRecognizer* _instance = nil;

@synthesize touchDelegate;

-(id) init{
    if(_instance) return _instance;
    if((self = [super init])){
        _instance = self;
        self.delaysTouchesBegan = NO;
        self.delaysTouchesEnded = NO;
        self.cancelsTouchesInView = NO;
        
        activeTouches = [NSMutableSet set];
    }
    return _instance;
}

@synthesize activeTouches;

+(MMTouchDotGestureRecognizer*) sharedInstace{
    if(!_instance){
        _instance = [[MMTouchDotGestureRecognizer alloc]init];
        _instance.delegate = _instance;
    }
    return _instance;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [activeTouches unionSet:touches];
    if(self.state == UIGestureRecognizerStatePossible){
        self.state = UIGestureRecognizerStateBegan;
    }else{
        self.state = UIGestureRecognizerStateChanged;
    }
    [touchDelegate dotTouchesBegan:touches];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    self.state = UIGestureRecognizerStateChanged;
    [touchDelegate dotTouchesMoved:touches];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [activeTouches minusSet:touches];
    if(![activeTouches count]){
        self.state = UIGestureRecognizerStateEnded;
    }
    [touchDelegate dotTouchesEnded:touches];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [activeTouches minusSet:touches];
    if(![activeTouches count]){
        self.state = UIGestureRecognizerStateEnded;
    }
    [touchDelegate dotTouchesCancelled:touches];
}

#pragma mark - UIGestureRecognizer

-(BOOL) canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

-(BOOL) shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
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


@end
