//
//  UIBezierPath+NSOSX.h
//  PaintingSample
//
//  Created by Adam Wulf on 10/5/12.
//
//

#import <UIKit/UIKit.h>
#import "DKGeometryUtilities.h"
#import "UIBezierPath+Geometry.h"
#import "UIBezierPath+Editing.h"
#import "UIBezierPath+GPC.h"

@interface UIBezierPath (NSOSX)

-(UIBezierPath*) bezierPathByFlatteningPath;

- (NSInteger)elementCount;

- (CGPathElement)elementAtIndex:(NSInteger)index associatedPoints:(CGPoint[])points;

- (CGPathElement)elementAtIndex:(NSInteger)index;

- (void)setAssociatedPoints:(CGPoint[])points atIndex:(NSInteger)index;

-(CGRect) controlPointBounds;

+(NSInteger) numberOfPointsForElement:(CGPathElement)element;

+(CGPathElement*) copyCGPathElement:(CGPathElement*)element;


@end
