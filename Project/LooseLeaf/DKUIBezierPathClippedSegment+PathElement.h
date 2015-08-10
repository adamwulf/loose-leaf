//
//  DKUIBezierPathClippedSegment+PathElement.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/3/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <JotUI/JotUI.h>
#import <JotUI/AbstractBezierPathElement-Protected.h>
#import <ClippingBezier/ClippingBezier.h>

@interface DKUIBezierPathClippedSegment (PathElement)

-(NSArray*) convertToPathElementsFromColor:(UIColor*)fromColor
                                   toColor:(UIColor*)toColor
                                 fromWidth:(CGFloat)fromWidth
                                   toWidth:(CGFloat)toWidth
                             withTransform:(CGAffineTransform)transform
                                  andScale:(CGFloat)scale;

-(NSArray*) convertToPathElementsFromColor:(UIColor*)startColor toColor:(UIColor*)endColor fromWidth:(CGFloat)startWidth toWidth:(CGFloat)toWidth;

@end
