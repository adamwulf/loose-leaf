//
//  MMLongPressGestureRecognizer.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/8/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMLongPressFromListViewGestureRecognizer.h"

@implementation MMLongPressFromListViewGestureRecognizer

@synthesize pinchDelegate;
@synthesize pinchedPage;
@synthesize normalizedLocationOfScale;

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //    debug_NSLog(@"touchesBegan");
    [super touchesBegan:touches withEvent:event];
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
        UITouch* touch = obj;
        MMPaperView* page = [pinchDelegate pageForPointInList:[touch locationInView:self.view]];
        if(page && !pinchedPage){
            pinchedPage = page;
            CGPoint lastLocationInPage = [self locationInView:pinchedPage];
            if([pinchedPage isKindOfClass:[MMShadowedView class]]){
                // the location needs to take into account the shadow
                lastLocationInPage.x -= [MMShadowedView shadowWidth];
                lastLocationInPage.y -= [MMShadowedView shadowWidth];
            }
            normalizedLocationOfScale = CGPointMake(lastLocationInPage.x / pinchedPage.frame.size.width,
                                                    lastLocationInPage.y / pinchedPage.frame.size.height);
        }else{
            [self ignoreTouch:touch forEvent:event];
        }
    }];
}

-(void) reset{
    pinchedPage = nil;
    [super reset];
}

-(void) cancel{
    self.enabled = NO;
    self.enabled = YES;
}





@end
