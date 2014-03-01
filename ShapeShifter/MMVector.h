//
//  MMVector.h
//  LooseLeaf
//
//  Created by Adam Wulf on 7/11/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMVector : NSObject

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;

+(MMVector*) vectorWithPoint:(CGPoint)p1 andPoint:(CGPoint)p2;

+(MMVector*) vectorWithX:(CGFloat)x andY:(CGFloat)y;

+(MMVector*) vectorWithAngle:(CGFloat)angle;

-(id) initWithPoint:(CGPoint)p1 andPoint:(CGPoint)p2;

-(id) initWithX:(CGFloat)x andY:(CGFloat)y;

-(MMVector*) normal;

-(MMVector*) normalizedTo:(CGFloat)someLength;

-(MMVector*) perpendicular;

-(MMVector*) flip;

-(CGFloat) magnitude;

-(CGFloat) angle;

-(CGPoint) pointFromPoint:(CGPoint)point distance:(CGFloat)distance;

-(MMVector*) averageWith:(MMVector*)vector;

-(MMVector*) rotateBy:(CGFloat)angle;

-(MMVector*) mirrorAround:(MMVector*)normal;

-(CGPoint) mirrorPoint:(CGPoint)point aroundPoint:(CGPoint)startPoint;

-(CGFloat) angleBetween:(MMVector*)otherVector;

-(CGPoint) asCGPoint;
@end
