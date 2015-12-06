//
//  MMButtonToolbarView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 12/6/15.
//  Copyright © 2015 Milestone Made, LLC. All rights reserved.
//

#import "MMButtonToolbarView.h"

@implementation MMButtonToolbarView

-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView* sv = [super hitTest:point withEvent:event];
    if(sv != self){
        return sv;
    }
    return nil;
}

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    for (UIView* subview in self.subviews) {
        if([subview pointInside:[subview convertPoint:point fromView:self] withEvent:event]){
            return YES;
        }
    }
    return NO;
}

@end
