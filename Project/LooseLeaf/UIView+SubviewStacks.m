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
    return [self.subviews lastObject];
}

- (SLPaperView*)popSubview{
    // nil if [self count] == 0
    SLPaperView* lastObject = [self.subviews lastObject];
    if (lastObject){
        [lastObject removeFromSuperview];
    }
    return lastObject;
}

- (void)pushSubview:(SLPaperView*)obj{
    if(![self containsSubview:obj]){
        if(obj.superview){
            obj.frame = [self convertRect:obj.frame fromView:obj.superview];
        }
        [self addSubview:obj];
    }
}

- (SLPaperView*)bottomSubview{
    if([self.subviews count]){
        return [self.subviews objectAtIndex:0];
    }
    return nil;
}

- (void) addSubviewToBottomOfStack:(SLPaperView*)obj{
    if(obj.superview){
        obj.frame = [self convertRect:obj.frame fromView:obj.superview];
    }
    [self insertSubview:obj atIndex:0];
}

/**
 * returns an array of all subviews above
 * the input view
 */
- (NSArray*) peekSubviewFromSubview:(SLPaperView*)obj{
    if(!obj){
        return [NSArray arrayWithArray:self.subviews];
    }
    if([self containsSubview:obj]){
        NSInteger index = [self.subviews indexOfObject:obj] + 1;
        NSInteger count = [self.subviews count];
        return [self.subviews subarrayWithRange:NSMakeRange(index, count - index)];
    }
    return nil;
}

-(SLPaperView*) getPageBelow:(SLPaperView*)page{
    if(!page) return page;
    NSInteger index = [self.subviews indexOfObject:page];
    if(index != 0){
        return [self.subviews objectAtIndex:index-1];
    }
    return nil;
}

-(SLPaperView*) getPageAbove:(SLPaperView*)page{
    if(!page) return page;
    NSInteger index = [self.subviews indexOfObject:page];
    if(index != [self.subviews count] - 1){
        return [self.subviews objectAtIndex:index+1];
    }
    return nil;
}

-(void) insertPage:(SLPaperView*)pageToInsert belowPage:(SLPaperView*)referencePage{
    if(!pageToInsert) return;
    if(!referencePage) return;
    [self insertSubview:pageToInsert belowSubview:referencePage];
}

-(void) insertPage:(SLPaperView*)pageToInsert abovePage:(SLPaperView*)referencePage{
    if(!pageToInsert) return;
    if(!referencePage) return;
    [self insertSubview:pageToInsert aboveSubview:referencePage];
}


@end
