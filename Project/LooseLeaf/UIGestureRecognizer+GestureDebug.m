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

@implementation UIGestureRecognizer (GestureDebug)

-(void) swizzle_setState:(UIGestureRecognizerState)state{
    if(state == UIGestureRecognizerStateBegan){
        NSLog(@"%@ began", [self class]);
    }else if(state == UIGestureRecognizerStateCancelled){
        NSLog(@"%@ cancelled", [self class]);
    }else if(state == UIGestureRecognizerStateEnded){
        NSLog(@"%@ ended", [self class]);
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
//    NSError *error = nil;
//	[UIGestureRecognizer jr_swizzleMethod:@selector(setState:)
//                        withMethod:@selector(swizzle_setState:)
//                             error:&error];
}


@end
