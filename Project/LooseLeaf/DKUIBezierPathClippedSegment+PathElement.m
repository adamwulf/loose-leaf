//
//  DKUIBezierPathClippedSegment+PathElement.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/3/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "DKUIBezierPathClippedSegment+PathElement.h"
#import <JotUI/UIColor+JotHelper.h>
#import "UIBezierPath+PathElement.h"

@implementation DKUIBezierPathClippedSegment (PathElement)

-(NSArray*) convertToPathElementsFromColor:(UIColor*)fromColor
                                   toColor:(UIColor*)toColor
                                 fromWidth:(CGFloat)fromWidth
                                   toWidth:(CGFloat)toWidth
                             withTransform:(CGAffineTransform)transform
                                  andScale:(CGFloat)scale{
    return [self.pathSegment1 convertToPathElementsFromTValue:self.startIntersection.tValue1
                                               toTValue:self.endIntersection.tValue1
                                              fromColor:fromColor
                                                toColor:toColor
                                              fromWidth:fromWidth
                                                toWidth:toWidth
                                          withTransform:transform
                                               andScale:scale];
}

-(NSArray*) convertToPathElementsFromColor:(UIColor*)fromColor toColor:(UIColor*)toColor fromWidth:(CGFloat)fromWidth toWidth:(CGFloat)toWidth{
    return [self convertToPathElementsFromColor:fromColor toColor:toColor fromWidth:fromWidth toWidth:toWidth withTransform:CGAffineTransformIdentity andScale:1.0];
}

@end
