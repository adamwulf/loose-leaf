//
//  UIBezierPath+PathElement.m
//  LooseLeaf
//
//  Created by Adam Wulf on 1/3/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "UIBezierPath+PathElement.h"
#import <JotUI/UIColor+JotHelper.h>
#import "Mixpanel.h"
#import "Constants.h"
#import <PerformanceBezier/PerformanceBezier.h>


@implementation UIBezierPath (PathElement)


- (void)scaleAndPreserveCenter:(CGFloat)scale {
    // ok, we have a rotation that'll give us a smaller square pixels
    // for the scrap's backing texture. make sure to rotate the
    // scrap around its center.
    CGPoint pathCenter = self.center;
    // first, translate to the center,
    CGAffineTransform scaleAroundCenterTransform = CGAffineTransformMakeTranslation(-pathCenter.x, -pathCenter.y);
    // then scale,
    scaleAroundCenterTransform = CGAffineTransformConcat(scaleAroundCenterTransform, CGAffineTransformMakeScale(scale, scale));
    // then translate back to its position
    scaleAroundCenterTransform = CGAffineTransformConcat(scaleAroundCenterTransform, CGAffineTransformMakeTranslation(pathCenter.x, pathCenter.y));
    [self applyTransform:scaleAroundCenterTransform];
}


- (void)rotateAndAlignCenter:(CGFloat)rotation {
    // ok, we have a rotation that'll give us a smaller square pixels
    // for the scrap's backing texture. make sure to rotate the
    // scrap around its center.
    CGPoint pathCenter = self.center;
    CGPoint initialFirstPoint = self.firstPoint;
    // first, translate to the center,
    CGAffineTransform rotateAroundCenterTransform = CGAffineTransformMakeTranslation(-pathCenter.x, -pathCenter.y);
    // then rotate,
    rotateAroundCenterTransform = CGAffineTransformConcat(rotateAroundCenterTransform, CGAffineTransformMakeRotation(rotation));
    // then translate back to its position
    rotateAroundCenterTransform = CGAffineTransformConcat(rotateAroundCenterTransform, CGAffineTransformMakeTranslation(pathCenter.x, pathCenter.y));
    [self applyTransform:rotateAroundCenterTransform];

    // the next bit is to calculate how much to move the
    // scrap so that it's new center will align the path
    // to it's old position.
    //
    // rotate the path back around its new center (as it will rotate in its scrap form)
    // this path now needs to be re-aligned with its old center'd path.
    // so look at how far the firstPoint moved in each path, and adjust the rotated
    // smaller bounded path by that much, so that the rotated scrap will appear
    // on top of the original unrotated input path
    UIBezierPath* adjustmentCalculationPath = [self copy];
    CGPoint adjustmentPathCenter = adjustmentCalculationPath.center;
    [adjustmentCalculationPath applyTransform:CGAffineTransformMakeTranslation(-adjustmentPathCenter.x, -adjustmentPathCenter.y)];
    [adjustmentCalculationPath applyTransform:CGAffineTransformMakeRotation(-rotation)];
    [adjustmentCalculationPath applyTransform:CGAffineTransformMakeTranslation(adjustmentPathCenter.x, adjustmentPathCenter.y)];
    CGPoint afterFirstPoint = adjustmentCalculationPath.firstPoint;
    CGPoint adjustment = CGPointMake(initialFirstPoint.x - afterFirstPoint.x, initialFirstPoint.y - afterFirstPoint.y);

    // this adjustment will account for the fact that the scrap
    // has a different center point than the input path
    // to this method.
    //
    // the scrap rotates around adjustmentPathCenter. so we need to
    // move the scrap so that an rotated scrap with the new path
    // would line up with the original unrotated scrap
    [self applyTransform:CGAffineTransformMakeTranslation(adjustment.x, adjustment.y)];
}


/**
 * will interpolate between the from and two values between
 * any moveTo elements and its next element.
 * all other elements will recieve the to values
 */
- (NSArray*)convertToPathElementsFromTValue:(CGFloat)fromTValue
                                   toTValue:(CGFloat)toTValue
                                  fromColor:(UIColor*)fromColor
                                    toColor:(UIColor*)toColor
                                  fromWidth:(CGFloat)fromWidth
                                    toWidth:(CGFloat)toWidth
                              withTransform:(CGAffineTransform)transform
                                   andScale:(CGFloat)scale
                               andStepWidth:(CGFloat)stepWidth
                                andRotation:(CGFloat)rotation {
    NSMutableArray* convertedElements = [NSMutableArray array];
    UIBezierPath* pathSegment = self;
    @try {
        if (!CGAffineTransformIsIdentity(transform)) {
            // only spend resources copying if we have to
            pathSegment = [pathSegment copy];
            [pathSegment applyTransform:transform];
        }
        __block CGPoint previousEndpoint = self.firstPoint;

        CGFloat widthDiff = toWidth - fromWidth;
        GLfloat prevColor[4], elementColor[4];
        GLfloat _colorDiff[4];
        __block GLfloat* prevColorPtr = (GLfloat*)prevColor;
        __block CGFloat* colorDiff = (CGFloat*)_colorDiff;
        [fromColor getRGBAComponents:prevColor];
        [toColor getRGBAComponents:elementColor];
        colorDiff[0] = elementColor[0] - prevColor[0];
        colorDiff[1] = elementColor[1] - prevColor[1];
        colorDiff[2] = elementColor[2] - prevColor[2];
        colorDiff[3] = elementColor[3] - prevColor[3];

        [pathSegment iteratePathWithBlock:^(CGPathElement pathEle, NSUInteger idx) {
            CGFloat tValueAtEndPoint;
            AbstractBezierPathElement* newElement = nil;
            if (pathEle.type == kCGPathElementAddCurveToPoint) {
                // curve
                newElement = [CurveToPathElement elementWithStart:previousEndpoint
                                                       andCurveTo:pathEle.points[2]
                                                      andControl1:pathEle.points[0]
                                                      andControl2:pathEle.points[1]];
                previousEndpoint = pathEle.points[2];
                tValueAtEndPoint = toTValue;
            } else if (pathEle.type == kCGPathElementAddLineToPoint) {
                newElement = [CurveToPathElement elementWithStart:previousEndpoint andLineTo:pathEle.points[0]];
                previousEndpoint = pathEle.points[0];
                tValueAtEndPoint = toTValue;
            } else if (pathEle.type == kCGPathElementMoveToPoint) {
                newElement = [MoveToPathElement elementWithMoveTo:pathEle.points[0]];
                previousEndpoint = pathEle.points[0];
                tValueAtEndPoint = fromTValue;
            }
            if (newElement) {
                // be sure to set color/width/etc
                if (toColor) {
                    CGFloat red = prevColorPtr[0] + colorDiff[0] * tValueAtEndPoint;
                    CGFloat green = prevColorPtr[1] + colorDiff[1] * tValueAtEndPoint;
                    CGFloat blue = prevColorPtr[2] + colorDiff[2] * tValueAtEndPoint;
                    CGFloat alpha = prevColorPtr[3] + colorDiff[3] * tValueAtEndPoint;
                    newElement.color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
                } else {
                    newElement.color = nil;
                }
                newElement.width = fromWidth + widthDiff * tValueAtEndPoint;
                newElement.width /= scale;
                newElement.stepWidth = stepWidth;
                newElement.rotation = rotation;

                if ([convertedElements count]) {
                    [newElement validateDataGivenPreviousElement:[convertedElements lastObject]];
                } else {
                    [newElement setPreviousColor:fromColor];
                    [newElement setPreviousWidth:fromWidth];
                    [newElement setPreviousRotation:newElement.rotation];
                    [newElement setPreviousExtraLengthWithoutDot:0];
                    [newElement setBakedPreviousElementProps:YES];
                }

                [convertedElements addObject:newElement];
            }
        }];
    } @catch (NSException* e) {
        NSString* pathCannotBeIterated = [pathSegment description];
        [[Mixpanel sharedInstance] track:kMPPathIterationException properties:@{ @"Path": pathCannotBeIterated }];
        [NSThread sleepForTimeInterval:5];
        @throw e;
    }

    return convertedElements;
}

@end
