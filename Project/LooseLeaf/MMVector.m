//
//  MMVector.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/11/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMVector.h"

// http://stackoverflow.com/questions/7854043/drawing-rectangle-between-two-points-with-arbitrary-width

@implementation MMVector{
    CGFloat x;
    CGFloat y;
}

+(id) vectorWithPoint:(CGPoint)p1 andPoint:(CGPoint)p2{
    return [[MMVector alloc] initWithPoint:p1 andPoint:p2];
}

+(id) vectorWithX:(CGFloat)x andY:(CGFloat)y{
    return [[MMVector alloc] initWithX:x andY:y];
}

-(id) initWithPoint:(CGPoint)p1 andPoint:(CGPoint)p2{
    if(self = [super init]){
        x = p2.x - p1.x;
        y = p2.y - p1.y;
    }
    return self;
}

-(id) initWithX:(CGFloat)_x andY:(CGFloat)_y{
    if(self = [super init]){
        x = _x;
        y = _y;
    }
    return self;
}

-(MMVector*) normal{
    // just divide our x and y by our length
    CGFloat length = sqrt(x * x + y * y);
    return [MMVector vectorWithX:(x / length) andY:(y / length)];
}

-(MMVector*) perpendicular{
    // perp just swaps the x and y
    return [MMVector vectorWithX:-y andY:x];
}

-(MMVector*) flip{
    // perp just swaps the x and y
    return [MMVector vectorWithX:-x andY:-y];
}

-(CGPoint) pointFromPoint:(CGPoint)point distance:(CGFloat)distance{
    return CGPointMake(point.x + x * distance,
                       point.y + y * distance);
}


@end
