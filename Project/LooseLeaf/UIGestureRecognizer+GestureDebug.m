//
//  UIGestureRecognizer+GestureDebug.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/31/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "UIGestureRecognizer+GestureDebug.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <DrawKit-iOS/DrawKit-iOS.h>
#import <DrawKit-iOS/JRSwizzle.h>
#import "Constants.h"
#import "MMPaperView.h"

@implementation UIGestureRecognizer (GestureDebug)

-(void) swizzle_setState:(UIGestureRecognizerState)state{
    NSString* uuid = @"";
    if([self.view respondsToSelector:@selector(uuid)]){
        uuid = [(NSString*) self.view performSelector:@selector(uuid)];
    }
    if(state == UIGestureRecognizerStateBegan){
        debug_NSLog(@"%@ (%@) %p began", [self class], uuid, self);
    }else if(state == UIGestureRecognizerStateCancelled){
        debug_NSLog(@"%@ (%@) %p cancelled", [self class], uuid, self);
    }else if(state == UIGestureRecognizerStateEnded){
        debug_NSLog(@"%@ (%@) %p ended", [self class], uuid, self);
    }else if(state == UIGestureRecognizerStateFailed){
        debug_NSLog(@"%@ (%@) %p failed", [self class], uuid, self);
    }

    [self swizzle_setState:state];
}

-(void) say:(NSString*)prefix ISee:(NSSet*)touches{
    NSString* str = @"";
    for (UITouch*t in touches) {
        str = [str stringByAppendingFormat:@" %p", t];
    }
//    NSLog(@"%p %@ %@", self, prefix, str);
}



+(void)load{
    NSError *error = nil;
	[UIGestureRecognizer jr_swizzleMethod:@selector(setState:)
                        withMethod:@selector(swizzle_setState:)
                             error:&error];
}


@end
