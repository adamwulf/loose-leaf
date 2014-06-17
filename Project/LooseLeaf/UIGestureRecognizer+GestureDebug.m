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
        debug_NSLog(@"%@ began", [self description]);
    }else if(state == UIGestureRecognizerStateCancelled){
        debug_NSLog(@"%@ cancelled", [self description]);
    }else if(state == UIGestureRecognizerStateEnded){
        debug_NSLog(@"%@ ended", [self description]);
    }else if(state == UIGestureRecognizerStateFailed){
        debug_NSLog(@"%@ failed", [self description]);
    }

    [self swizzle_setState:state];
}

-(NSString*) swizzle_description{
    return [NSString stringWithFormat:@"[%@ %p]", NSStringFromClass([self class]), self];
}

-(void) swizzle_reset{
    NSLog(@"reset %@", [self description]);
    [self swizzle_reset];
}

-(void) say:(NSString*)prefix ISee:(NSSet*)touches{
    NSString* str = @"";
    for (UITouch*t in touches) {
        str = [str stringByAppendingFormat:@" %p", t];
    }
//    NSLog(@"%p %@ %@", self, prefix, str);
}


//
//+(void)load{
//    NSError *error = nil;
//	[UIGestureRecognizer jr_swizzleMethod:@selector(setState:)
//                        withMethod:@selector(swizzle_setState:)
//                             error:&error];
//	[UIGestureRecognizer jr_swizzleMethod:@selector(description)
//                               withMethod:@selector(swizzle_description)
//                                    error:&error];
//	[UIGestureRecognizer jr_swizzleMethod:@selector(reset)
//                               withMethod:@selector(swizzle_reset)
//                                    error:&error];
//}


@end
