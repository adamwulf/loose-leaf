//
//  UIFont+UIBezierCurve.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/25/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>


@interface UIFont (UIBezierCurve)

- (UIBezierPath*)bezierPathForString:(NSString*)letter;

@end
