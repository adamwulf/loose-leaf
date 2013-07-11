//
//  MMVector.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/11/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMVector : NSObject

+(id) vectorWithPoint:(CGPoint)p1 andPoint:(CGPoint)p2;

+(id) vectorWithX:(CGFloat)x andY:(CGFloat)y;

-(id) initWithPoint:(CGPoint)p1 andPoint:(CGPoint)p2;

-(id) initWithX:(CGFloat)x andY:(CGFloat)y;

-(MMVector*) normal;

-(MMVector*) perpendicular;

-(MMVector*) flip;

-(CGPoint) pointFromPoint:(CGPoint)point distance:(CGFloat)distance;

@end
