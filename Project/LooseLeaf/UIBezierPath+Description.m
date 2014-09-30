//
//  UIBezierPath+Description.m
//  LooseLeaf
//
//  Created by Adam Wulf on 12/17/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "UIBezierPath+Description.h"
#import <DrawKit-iOS/DrawKit-iOS.h>
#import <DrawKit-iOS/JRSwizzle.h>

@implementation UIBezierPath (Description)



-(NSString*) swizzle_description{
    __block NSString* str = @"path = [UIBezierPath bezierPath];\n";
    [self iteratePathWithBlock:[^(CGPathElement ele){
        if(ele.type == kCGPathElementAddCurveToPoint){
            CGPoint curveTo = ele.points[2];
            CGPoint ctrl1 = ele.points[0];
            CGPoint ctrl2 = ele.points[1];
            str = [str stringByAppendingFormat:@"[path addCurveToPoint:CGPointMake(%f, %f) controlPoint1:CGPointMake(%f, %f) controlPoint2:CGPointMake(%f, %f)];\n", curveTo.x, curveTo.y, ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y];
        }else if(ele.type == kCGPathElementAddLineToPoint){
            CGPoint lineTo = ele.points[0];
            str = [str stringByAppendingFormat:@"[path addLineToPoint:CGPointMake(%f, %f)];\n", lineTo.x, lineTo.y];
        }else if(ele.type == kCGPathElementAddQuadCurveToPoint){
            CGPoint curveTo = ele.points[2];
            CGPoint ctrl = ele.points[0];
            str = [str stringByAppendingFormat:@"[path addQuadCurveToPoint:CGPointMake(%f, %f) controlPoint:CGPointMake(%f, %f)];\n", curveTo.x, curveTo.y, ctrl.x, ctrl.y];
        }else if(ele.type == kCGPathElementCloseSubpath){
            [self closePath];
            str = [str stringByAppendingString:@"[path closePath];\n"];
        }else if(ele.type == kCGPathElementMoveToPoint){
            CGPoint moveTo = ele.points[0];
            str = [str stringByAppendingFormat:@"[path moveToPoint:CGPointMake(%f, %f)];\n", moveTo.x, moveTo.y];
        }
    } copy]];
    return str;
}


+(void)load{
    @autoreleasepool {
        NSError *error = nil;
        [UIBezierPath jr_swizzleMethod:@selector(description)
                            withMethod:@selector(swizzle_description)
                                 error:&error];
    }
}
@end
