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
#import <ClippingBezier/ClippingBezier.h>


@implementation DKUIBezierPathClippedSegment (PathElement)

- (NSArray*)convertToPathElementsFromColor:(UIColor*)fromColor
                                   toColor:(UIColor*)toColor
                                 fromWidth:(CGFloat)fromWidth
                                   toWidth:(CGFloat)toWidth
                             withTransform:(CGAffineTransform)transform
                                  andScale:(CGFloat)scale
                              andStepWidth:(CGFloat)stepWidth
                               andRotation:(CGFloat)rotation {
    return [self.pathSegment convertToPathElementsFromTValue:self.startIntersection.tValue1
                                                     toTValue:self.endIntersection.tValue1
                                                    fromColor:fromColor
                                                      toColor:toColor
                                                    fromWidth:fromWidth
                                                      toWidth:toWidth
                                                withTransform:transform
                                                     andScale:scale
                                                 andStepWidth:stepWidth
                                                  andRotation:rotation];
}

- (NSArray*)convertToPathElementsFromColor:(UIColor*)fromColor toColor:(UIColor*)toColor fromWidth:(CGFloat)fromWidth toWidth:(CGFloat)toWidth andStepWidth:(CGFloat)stepWidth andRotation:(CGFloat)rotation {
    return [self convertToPathElementsFromColor:fromColor toColor:toColor fromWidth:fromWidth toWidth:toWidth withTransform:CGAffineTransformIdentity andScale:1.0 andStepWidth:stepWidth andRotation:rotation];
}

@end
