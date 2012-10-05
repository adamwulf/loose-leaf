///**********************************************************************************************************************************
///  UIBezierPath+GPC.h
///  DrawKit �2005-2008 Apptree.net
///
///  Created by graham on 31/10/2006.
///
///	 This software is released subject to licensing conditions as detailed in DRAWKIT-LICENSING.TXT, which must accompany this source file. 
///
///**********************************************************************************************************************************

#ifdef qUseGPC

#import "gpc.h"
#import <QuartzCore/QuartzCore.h>


// path simplifying constants - auto will not simplify when both source paths consist only of line segments

typedef enum
{
	kDKPathUnflattenNever	= 0,
	kDKPathUnflattenAlways	= 1,
	kDKPathUnflattenAuto	= 2
}
DKPathUnflatteningPolicy;


@interface UIBezierPath (GPC)

+(void) setDefaultFlatness:(CGFloat)_flatness;
+(CGFloat) defaultFlatness;

+ (UIBezierPath*)		bezierPathWithGPCPolygon:(gpc_polygon*) poly;
+ (void)				setPathUnflatteningPolicy:(DKPathUnflatteningPolicy) sp;
+ (DKPathUnflatteningPolicy) pathUnflatteningPolicy;

- (gpc_polygon*)		gpcPolygon;
- (gpc_polygon*)		gpcPolygonWithFlatness:(CGFloat) flatness;

- (NSInteger)			subPathCountStartingAtElement:(NSInteger) se;

- (BOOL)				intersectsPath:(UIBezierPath*) path;
- (UIBezierPath*)		pathFromPath:(UIBezierPath*) otherPath usingBooleanOperation:(gpc_op) op;
- (UIBezierPath*)		pathFromPath:(UIBezierPath*) otherPath usingBooleanOperation:(gpc_op) op unflattenResult:(BOOL) uf;


// boolean ops on bezier paths yay!

- (UIBezierPath*)		pathFromUnionWithPath:(UIBezierPath*) otherPath;
- (UIBezierPath*)		pathFromIntersectionWithPath:(UIBezierPath*) otherPath;
- (UIBezierPath*)		pathFromDifferenceWithPath:(UIBezierPath*) otherPath;
- (UIBezierPath*)		pathFromExclusiveOrWithPath:(UIBezierPath*) otherPath;

// unflatten a poly-based path using curve fitting

- (UIBezierPath*)		bezierPathByUnflatteningPath;


@end

NSUInteger	checksumPoly( gpc_polygon* poly );
CGRect		boundsOfPoly( gpc_polygon* poly );
BOOL		equalPolys( gpc_polygon* polyA, gpc_polygon* polyB );
BOOL		intersectingPolys( gpc_polygon* polyA, gpc_polygon* polyB );

#define		kDKCurveFittingErrorValue		1E-4

extern NSString* kDKCurveFittingPolicyDefaultsKey;

/*

This category on UIBezierPath converts to and from the gpc_polygon data structure used by
the wonderful gpc (general polygon clipping) lib. This lib is used to perform boolean ops on paths.

Note that at present paths are flattened into polygons and so curve control points, etc are not preserved.

The curve-fitting is accomplished using 3rd party code from Lib2Geom, which is in turn a C++ implementation
of the classic Graphics Gems code. Curve-fitting is controlled by the "simplifying policy" that you set. By
default it's set to 'auto', meaning that if either of the original paths contains curves, curve fitting will
be done on the result, but if both source paths only have line segments, it won't be. This preserves sharp-cornered
shapes such as rects, etc.

For simplifying a path at any other time, you must pass a flattened path. Simplifying really means "unflattening".

*/

#endif /* defined (qUseGPC) */
