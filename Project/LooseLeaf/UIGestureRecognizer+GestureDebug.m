//
//  UIGestureRecognizer+GestureDebug.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/31/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "UIGestureRecognizer+GestureDebug.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import <ClippingBezier/JRSwizzle.h>
#import "Constants.h"
#import "MMPaperView.h"

@implementation UIGestureRecognizer (GestureDebug)

-(void) swizzle_setState:(UIGestureRecognizerState)state{
    if(state == UIGestureRecognizerStateBegan){
        DebugLog(@"%@ began", [self description]);
    }else if(state == UIGestureRecognizerStateCancelled){
        DebugLog(@"%@ cancelled", [self description]);
    }else if(state == UIGestureRecognizerStateEnded){
        DebugLog(@"%@ ended", [self description]);
    }else if(state == UIGestureRecognizerStateFailed){
        DebugLog(@"%@ failed", [self description]);
    }

    [self swizzle_setState:state];
}

-(NSString*) swizzle_description{
    return [NSString stringWithFormat:@"[%@ %p]", NSStringFromClass([self class]), self];
}

-(void) swizzle_reset{
    DebugLog(@"reset %@", [self description]);
    [self swizzle_reset];
}

//-(void) say:(NSString*)prefix ISee:(NSSet*)touches{
//    NSString* str = @"";
//    for (UITouch*t in touches) {
//        str = [str stringByAppendingFormat:@" %p", t];
//    }
////    DebugLog(@"%p %@ %@", self, prefix, str);
//}


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
