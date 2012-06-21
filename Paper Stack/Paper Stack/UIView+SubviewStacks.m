//
//  UIView+SubviewStacks.m
//  Paper Stack
//
//  Created by Adam Wulf on 6/20/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "UIView+SubviewStacks.h"

@implementation UIView (SubviewStacks)

- (BOOL) containsSubview:(SLPaperView*)obj{
    return [self.subviews containsObject:obj];
}

- (SLPaperView*) peekSubview{
    return [[[self.subviews lastObject] retain] autorelease];
}

- (SLPaperView*)popSubview{
    // nil if [self count] == 0
    SLPaperView* lastObject = [[[self.subviews lastObject] retain] autorelease];
    if (lastObject){
        [lastObject removeFromSuperview];
    }
    return lastObject;
}

- (void)pushSubview:(SLPaperView*)obj{
    if(obj.superview){
        obj.frame = [self convertRect:obj.frame fromView:obj.superview];
    }
    [self addSubview:obj];
}

- (void) addSubviewToBottomOfStack:(SLPaperView*)obj{
    if(obj.superview){
        obj.frame = [self convertRect:obj.frame fromView:obj.superview];
    }
    [self insertSubview:obj atIndex:0];
}

@end
