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

@synthesize pinchDelegate;
@synthesize pinchedPage;
@synthesize normalizedLocationOfScale;

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return [preventedGestureRecognizer isKindOfClass:[MMPanAndPinchFromListViewGestureRecognizer class]];
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return [preventingGestureRecognizer isKindOfClass:[MMPanAndPinchFromListViewGestureRecognizer class]];
}

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





@end
