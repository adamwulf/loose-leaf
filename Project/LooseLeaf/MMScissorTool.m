//
//  MMScissorTool.m
//  LooseLeaf
//
//  Created by Adam Wulf on 11/6/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMScissorTool.h"


@implementation MMScissorTool

- (NSArray*)willAddElements:(NSArray*)elements toStroke:(JotStroke*)stroke fromPreviousElement:(AbstractBezierPathElement*)previousElement inJotView:(JotView *)jotView{
    return elements;
}

- (BOOL)supportsRotation {
    return NO;
}

@end
