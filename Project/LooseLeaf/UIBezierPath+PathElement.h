//
//  UIBezierPath+PathElement.h
//  LooseLeaf
//
//  Created by Adam Wulf on 1/3/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DrawKit-iOS/DrawKit-iOS.h>
#import <JotUI/JotUI.h>
#import <JotUI/AbstractBezierPathElement-Protected.h>

@interface UIBezierPath (PathElement)

-(void) rotateAndAlignCenter:(CGFloat)rotation;

-(NSArray*) convertToPathElementsFromTValue:(CGFloat)fromTValue
                                   toTValue:(CGFloat)toTValue
                                  fromColor:(UIColor*)fromColor
                                   toColor:(UIColor*)toColor
                                 fromWidth:(CGFloat)fromWidth
                                   toWidth:(CGFloat)toWidth
                             withTransform:(CGAffineTransform)transform
                                  andScale:(CGFloat)scale;
@end
