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

void getPathElementAtIndex(void* info, const CGPathElement* element);

void updatePathElementAtIndex(void* info, const CGPathElement* element);

@end

@implementation UIBezierPath (NSOSX)


-(UIBezierPath*) bezierPathByFlatteningPath{
    return [[self copy] autorelease];
}

- (NSInteger)elementCount{
    NSInteger count = 0;
    CGPathApply(self.CGPath, &count, countPathElement);
    NSLog(@"count is: %d", count);
    return count;
}
// helper function
void countPathElement(void* info, const CGPathElement* element) {
    NSInteger* count = info;
    *count = *count + 1;
}



- (CGPathElement)elementAtIndex:(NSInteger)index associatedPoints:(CGPoint[])points{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:index] forKey:@"index"];
    CGPathApply(self.CGPath, params, getPathElementAtIndex);
    NSValue* val = (NSValue*) [params objectForKey:@"element"];
    CGPathElement* element = [val pointerValue];
    if(points){
        for(int i=0;i<[UIBezierPath numberOfPointsForElement:*element];i++){
            points[i] = element->points[i];
        }
    }
    return *element;
}
// helper function
void getPathElementAtIndex(void* info, const CGPathElement* element) {
    NSMutableDictionary* params = (NSMutableDictionary*)info;
    int askingForIndex = [[params objectForKey:@"index"] intValue];
    if(![params objectForKey:@"element"]){
        int currentIndex = 0;
        if([params objectForKey:@"curr"]){
            currentIndex = [[params objectForKey:@"curr"] intValue] + 1;
        }
        if(currentIndex == askingForIndex){
            CGPathElement* returnVal = [UIBezierPath copyCGPathElement:(CGPathElement*)element];
            [params setObject:[NSValue valueWithPointer:returnVal] forKey:@"element"];
            NSLog(@"found index %d is a %d", currentIndex, (*returnVal).type);
        }
        [params setObject:[NSNumber numberWithInt:currentIndex] forKey:@"curr"];
    }
}


/**
 * returns the element at the index of the path
 */
- (CGPathElement)elementAtIndex:(NSInteger)index{
    return [self elementAtIndex:index associatedPoints:NULL];
}


/**
 * updates the point in the path with the new input points
 */
- (void)setAssociatedPoints:(CGPoint[])points atIndex:(NSInteger)index{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInteger:index] forKey:@"index"];
    [params setObject:[NSValue valueWithPointer:points]  forKey:@"points"];
    CGPathApply(self.CGPath, params, updatePathElementAtIndex);

}
// helper function
void updatePathElementAtIndex(void* info, const CGPathElement* element) {
    NSMutableDictionary* params = (NSMutableDictionary*)info;
    int currentIndex = 0;
    if([params objectForKey:@"curr"]){
        currentIndex = [[params objectForKey:@"curr"] intValue] + 1;
    }
    if(currentIndex == [[params objectForKey:@"index"] intValue]){
        CGPoint* points = [[params objectForKey:@"points"] pointerValue];
        for(int i=0;i<[UIBezierPath numberOfPointsForElement:*element];i++){
            element->points[i] = points[i];
        }
        CGPathElement* returnVal = [UIBezierPath copyCGPathElement:(CGPathElement*)element];
        [params setObject:[NSValue valueWithPointer:returnVal] forKey:@"element"];
    }
    [params setObject:[NSNumber numberWithInt:currentIndex] forKey:@"curr"];
}


-(CGRect) controlPointBounds{
    return CGPathGetBoundingBox(self.CGPath);
}




+(NSInteger) numberOfPointsForElement:(CGPathElement)element{
    NSInteger nPoints = 0;
    switch (element.type)
	{
		case kCGPathElementMoveToPoint:
			nPoints = 1;
			break;
		case kCGPathElementAddLineToPoint:
			nPoints = 1;
			break;
		case kCGPathElementAddQuadCurveToPoint:
			nPoints = 2;
			break;
		case kCGPathElementAddCurveToPoint:
			nPoints = 3;
			break;
		case kCGPathElementCloseSubpath:
			nPoints = 0;
			break;
		default:
			nPoints = 0;
	}
    return nPoints;
}



+(CGPathElement*) copyCGPathElement:(CGPathElement*)element{
    CGPathElement* ret = malloc(sizeof(CGPathElement));
    NSInteger numberOfPoints = [UIBezierPath numberOfPointsForElement:*element];
    if(numberOfPoints){
        ret->points = malloc(sizeof(CGPoint) * numberOfPoints);
    }else{
        ret->points = NULL;
    }
    ret->type = element->type;
    
    for(int i=0;i<numberOfPoints;i++){
        ret->points[i] = element->points[i];
    }
    return ret;
}


@end
