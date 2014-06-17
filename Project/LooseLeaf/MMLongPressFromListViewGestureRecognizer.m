//
//  MMLongPressGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/8/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMLongPressFromListViewGestureRecognizer.h"
#import "MMPanAndPinchFromListViewGestureRecognizer.h"

@implementation MMLongPressFromListViewGestureRecognizer

#pragma mark - Properties

@synthesize pinchDelegate;
@synthesize pinchedPage;
@synthesize normalizedLocationOfScale;

#pragma mark - Init

-(id) init{
    if(self = [super init]){
        self.delegate = self;
    }
    return self;
}

-(id) initWithTarget:(id)target action:(SEL)action{
    if(self = [super initWithTarget:target action:action]){
        self.delegate = self;
    }
    return self;
}

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //    debug_NSLog(@"touchesBegan");
    NSMutableSet* mset = [NSMutableSet set];
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
        UITouch* touch = obj;
        MMPaperView* page = [pinchDelegate pageForPointInList:[touch locationInView:self.view]];
        if(page && !pinchedPage){
            pinchedPage = page;
            CGPoint lastLocationInPage = [touch locationInView:pinchedPage];
            if([pinchedPage isKindOfClass:[MMShadowedView class]]){
                // the location needs to take into account the shadow
                lastLocationInPage.x -= [MMShadowedView shadowWidth];
                lastLocationInPage.y -= [MMShadowedView shadowWidth];
            }
            normalizedLocationOfScale = CGPointMake(lastLocationInPage.x / pinchedPage.frame.size.width,
                                                    lastLocationInPage.y / pinchedPage.frame.size.height);
            [mset addObject:touch];
        }else{
            [self ignoreTouch:touch forEvent:event];
        }
    }];
    if([mset count]){
        [super touchesBegan:mset withEvent:event];
    }
}

#pragma mark - UIGestureRecognizer Subclass

-(void) reset{
    pinchedPage = nil;
    [super reset];
}

-(void) cancel{
    if(self.enabled){
        self.enabled = NO;
        self.enabled = YES;
    }
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return [preventedGestureRecognizer isKindOfClass:[MMPanAndPinchFromListViewGestureRecognizer class]];
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return [preventingGestureRecognizer isKindOfClass:[MMPanAndPinchFromListViewGestureRecognizer class]];
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
//        NSLog(@"ignore touch in %@", NSStringFromClass([self class]));
        return NO;
    }
    return YES;
}



@end
