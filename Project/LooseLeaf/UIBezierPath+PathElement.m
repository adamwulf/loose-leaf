//
//  UIBezierPath+PathElement.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/3/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "UIBezierPath+PathElement.h"
#import <JotUI/UIColor+JotHelper.h>

@implementation UIBezierPath (PathElement)


/**
 * will interpolate between the from and two values between
 * any moveTo elements and its next element.
 * all other elements will recieve the to values
 */
-(NSArray*) convertToPathElementsFromTValue:(CGFloat)fromTValue
                                   toTValue:(CGFloat)toTValue
                                  fromColor:(UIColor*)fromColor
                                   toColor:(UIColor*)toColor
                                 fromWidth:(CGFloat)fromWidth
                                   toWidth:(CGFloat)toWidth
                             withTransform:(CGAffineTransform)transform
                                  andScale:(CGFloat)scale{
    NSMutableArray* convertedElements = [NSMutableArray array];
    UIBezierPath* pathSegment = self;
    if(!CGAffineTransformIsIdentity(transform)){
        // only spend resources copying if we have to
        pathSegment = [pathSegment copy];
        [pathSegment applyTransform:transform];
    }
    __block CGPoint previousEndpoint = self.firstPoint;
    
    
    CGFloat widthDiff = toWidth - fromWidth;
    GLfloat _prevColor[4], elementColor[4];
    GLfloat _colorDiff[4];
    CGFloat* prevColor = (CGFloat*)_prevColor;
    CGFloat* colorDiff = (CGFloat*)_colorDiff;
    [fromColor getRGBAComponents:prevColor];
    [toColor getRGBAComponents:elementColor];
    colorDiff[0] = elementColor[0] - prevColor[0];
    colorDiff[1] = elementColor[1] - prevColor[1];
    colorDiff[2] = elementColor[2] - prevColor[2];
    colorDiff[3] = elementColor[3] - prevColor[3];
    [pathSegment iteratePathWithBlock:^(CGPathElement pathEle){
        CGFloat tValueAtEndPoint;
        AbstractBezierPathElement* newElement = nil;
        if(pathEle.type == kCGPathElementAddCurveToPoint){
            // curve
            newElement = [CurveToPathElement elementWithStart:previousEndpoint
                                                   andCurveTo:pathEle.points[2]
                                                  andControl1:pathEle.points[0]
                                                  andControl2:pathEle.points[1]];
            previousEndpoint = pathEle.points[2];
            tValueAtEndPoint = toTValue;
        }else if(pathEle.type == kCGPathElementAddLineToPoint){
            newElement = [CurveToPathElement elementWithStart:previousEndpoint andLineTo:pathEle.points[0]];
            previousEndpoint = pathEle.points[0];
            tValueAtEndPoint = toTValue;
        }else if(pathEle.type == kCGPathElementMoveToPoint){
            newElement = [MoveToPathElement elementWithMoveTo:pathEle.points[0]];
            previousEndpoint = pathEle.points[0];
            tValueAtEndPoint = fromTValue;
        }
        if(newElement){
            // be sure to set color/width/etc
            if(toColor){
                CGFloat red = prevColor[0] + colorDiff[0] * tValueAtEndPoint;
                CGFloat green = prevColor[1] + colorDiff[1] * tValueAtEndPoint;
                CGFloat blue = prevColor[2] + colorDiff[2] * tValueAtEndPoint;
                CGFloat alpha = prevColor[3] + colorDiff[3] * tValueAtEndPoint;
                newElement.color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            }else{
                newElement.color = nil;
            }
            newElement.width = fromWidth + widthDiff*tValueAtEndPoint;
            newElement.width /= scale;
            [convertedElements addObject:newElement];
        }
    }];
    
    return convertedElements;
}

@end
