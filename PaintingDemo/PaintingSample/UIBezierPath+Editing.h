///**********************************************************************************************************************************
///  UIBezierPath-Editing.h
///  DrawKit �2005-2008 Apptree.net
///
///  Created by graham on 08/10/2006.
///
///	 This software is released subject to licensing conditions as detailed in DRAWKIT-LICENSING.TXT, which must accompany this source file. 
///
///**********************************************************************************************************************************



@interface UIBezierPath (DKEditing)

+ (void)				setConstraintAngle:(CGFloat) radians;
+ (CGPoint)				colinearPointForPoint:(CGPoint) p centrePoint:(CGPoint) q;
+ (CGPoint)				colinearPointForPoint:(CGPoint) p centrePoint:(CGPoint) q radius:(CGFloat) r;
+ (NSInteger)			point:(CGPoint) p inCGPointArray:(CGPoint*) array count:(NSInteger) count tolerance:(CGFloat) t;
+ (NSInteger)			point:(CGPoint) p inCGPointArray:(CGPoint*) array count:(NSInteger) count tolerance:(CGFloat) t reverse:(BOOL) reverse;
+ (void)				colineariseVertex:(CGPoint[3]) inPoints cpA:(CGPoint*) outCPA cpB:(CGPoint*) outCPB;

- (UIBezierPath*)		bezierPathByRemovingTrailingElements:(NSInteger) numToRemove;
- (UIBezierPath*)		bezierPathByStrippingRedundantElements;
- (UIBezierPath*)		bezierPathByRemovingElementAtIndex:(NSInteger) indx;

- (void)				getPathMoveToCount:(NSInteger*) mtc lineToCount:(NSInteger*) ltc curveToCount:(NSInteger*) ctc closePathCount:(NSInteger*) cpc;

- (BOOL)				isPathClosed;
- (NSUInteger)			checksum;

- (BOOL)				subpathContainingElementIsClosed:(NSInteger) element;
- (NSInteger)			subpathStartingElementForElement:(NSInteger) element;
- (NSInteger)			subpathEndingElementForElement:(NSInteger) element;

- (CGPathElement)	elementTypeForPartcode:(NSInteger) pc;
- (BOOL)				isOnPathPartcode:(NSInteger) pc;

- (void)				setControlPoint:(CGPoint) p forPartcode:(NSInteger) pc;
- (CGPoint)				controlPointForPartcode:(NSInteger) pc;

- (NSInteger)			partcodeHitByPoint:(CGPoint) p tolerance:(CGFloat) t;
- (NSInteger)			partcodeHitByPoint:(CGPoint) p tolerance:(CGFloat) t prioritiseOnPathPoints:(BOOL) onpPriority;
- (NSInteger)			partcodeHitByPoint:(CGPoint) p tolerance:(CGFloat) t startingFromElement:(NSInteger) startElement;
- (NSInteger)			partcodeHitByPoint:(CGPoint) p tolerance:(CGFloat) t startingFromElement:(NSInteger) startElement prioritiseOnPathPoints:(BOOL) onpPriority;
- (NSInteger)			partcodeForLastPoint;
- (CGPoint)				referencePointForConstrainedPartcode:(NSInteger) pc;

- (void)				moveControlPointPartcode:(NSInteger) pc toPoint:(CGPoint) p colinear:(BOOL) colin coradial:(BOOL) corad constrainAngle:(BOOL) acon;

// adding and deleting points from a path:
// note that all of these methods return a new path since UIBezierPath doesn't support deletion/insertion except by reconstructing a path.

- (UIBezierPath*)		deleteControlPointForPartcode:(NSInteger) pc;
- (UIBezierPath*)		insertControlPointAtPoint:(CGPoint) p tolerance:(CGFloat) tol type:(NSInteger) controlPointType;

- (CGPoint)				nearestPointToPoint:(CGPoint) p tolerance:(CGFloat) tol;

// geometry utilities:

- (CGFloat)				tangentAtStartOfSubpath:(NSInteger) elementIndex;
- (CGFloat)				tangentAtEndOfSubpath:(NSInteger) elementIndex;

- (NSInteger)			elementHitByPoint:(CGPoint) p tolerance:(CGFloat) tol tValue:(CGFloat*) t;
- (NSInteger)			elementHitByPoint:(CGPoint) p tolerance:(CGFloat) tol tValue:(CGFloat*) t nearestPoint:(CGPoint*) npp;
- (NSInteger)			elementBoundsContaiCGPoint:(CGPoint) p tolerance:(CGFloat) tol;

// element bounding boxes - can reduce need to draw entire path when only a part is edited

- (CGRect)				boundingBoxForElement:(NSInteger) elementIndex;
- (void)				drawElementsBoundingBoxes;
- (NSSet*)				boundingBoxesForPartcode:(NSInteger) pc;
- (NSSet*)				allBoundingBoxes;


@end




NSInteger		partcodeForElement( const NSInteger element );
NSInteger		partcodeForElementControlPoint( const NSInteger element, const NSInteger controlPointIndex );

/*

This category provides some basic methods for supporting interactive editing of a UIBezierPath object. This can be more tricky
than it looks because control points are often not edited in isolation - they often crosslink to other control points (such as
when two curveto segments are joined and a colinear handle is needed).

These methods allow you to refer to any individual control point in the object using a unique partcode. These methods will
hit detect all control points, giving the partcode, and then get and set that point.

The moveControlPointPartcode:toPoint:colinear: is a high-level call that will handle most editing tasks in a simple to use way. It
optionally maintains colinearity across curve joins, and knows how to maintain closed loops properly.

*/

