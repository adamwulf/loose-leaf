//
//  UIBezierPath+NSOSX.m
//  PaintingSample
//
//  Created by Adam Wulf on 10/5/12.
//
//

#import "UIBezierPath+NSOSX.h"

@interface UIBezierPath (Private)

void countPathElement(void* info, const CGPathElement* element);

@end

@implementation UIBezierPath (NSOSX)


-(UIBezierPath*) bezierPathByFlatteningPath{
    return [[self copy] autorelease];
}

void countPathElement(void* info, const CGPathElement* element) {
    NSInteger* count = info;
    *count = *count + 1;
}

- (NSInteger)elementCount{
    NSInteger count = 0;
    CGPathApply(self.CGPath, &count, countPathElement);
    NSLog(@"count is: %d", count);
    return count;
}

-(CGRect) controlPointBounds{
    return CGPathGetBoundingBox(self.CGPath);
}


@end
