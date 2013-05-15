//
//  UIView+SubviewStacks.m
//  Loose Leaf
//
//  Created by Adam Wulf on 6/20/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "UIView+SubviewStacks.h"

@implementation UIView (SubviewStacks)

- (BOOL) containsSubview:(MMPaperView*)obj{
    return [self.subviews containsObject:obj];
}

- (MMPaperView*) peekSubview{
    return [[[self.subviews lastObject] retain] autorelease];
}

- (MMPaperView*)popSubview{
    // nil if [self count] == 0
    MMPaperView* lastObject = [[[self.subviews lastObject] retain] autorelease];
    if (lastObject){
        [lastObject removeFromSuperview];
    }
    return lastObject;
}

- (void)pushSubview:(MMPaperView*)obj{
    if(![self containsSubview:obj]){
        if(obj.superview){
            obj.frame = [self convertRect:obj.frame fromView:obj.superview];
        }
        [self addSubview:obj];
    }
}

- (MMPaperView*)bottomSubview{
    if([self.subviews count]){
        return [self.subviews objectAtIndex:0];
    }
    return nil;
}

- (void) addSubviewToBottomOfStack:(MMPaperView*)obj{
    if(obj.superview){
        obj.frame = [self convertRect:obj.frame fromView:obj.superview];
    }
    [self insertSubview:obj atIndex:0];
}

/**
 * returns an array of all subviews above
 * the input view
 */
- (NSArray*) peekSubviewFromSubview:(MMPaperView*)obj{
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

-(MMPaperView*) getPageBelow:(MMPaperView*)page{
    if(!page) return page;
    NSInteger index = [self.subviews indexOfObject:page];
    if(index != 0){
        return [self.subviews objectAtIndex:index-1];
    }
    return nil;
}

-(MMPaperView*) getPageAbove:(MMPaperView*)page{
    if(!page) return page;
    NSInteger index = [self.subviews indexOfObject:page];
    if(index != [self.subviews count] - 1){
        return [self.subviews objectAtIndex:index+1];
    }
    return nil;
}

-(void) insertPage:(MMPaperView*)pageToInsert belowPage:(MMPaperView*)referencePage{
    if(!pageToInsert) return;
    if(!referencePage) return;
    [self insertSubview:pageToInsert belowSubview:referencePage];
}

-(void) insertPage:(MMPaperView*)pageToInsert abovePage:(MMPaperView*)referencePage{
    if(!pageToInsert) return;
    if(!referencePage) return;
    [self insertSubview:pageToInsert aboveSubview:referencePage];
}


@end
