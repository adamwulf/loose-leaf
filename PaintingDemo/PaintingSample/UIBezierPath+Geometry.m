///**********************************************************************************************************************************
///  UIBezierPath-Geometry.m
///  DrawKit ¬¨¬®¬¨¬Æ¬¨¬®¬¨¬©2005-2008 Apptree.net
///
///  Created by graham on 22/10/2006.
///
///	 This software is released subject to licensing conditions as detailed in DRAWKIT-LICENSING.TXT, which must accompany this source file. 
///
///**********************************************************************************************************************************

#import "UIBezierPath+Geometry.h"
#import "DKDrawKitMacros.h"
#import "DKGeometryUtilities.h"
#import "UIBezierPath+Editing.h"
#import "UIBezierPath+GPC.h"
#import "UIBezierPath+NSOSX.h"

// define this to use Omni methods for finding points on paths, etc. Note - I have discovered that these methods, though probably faster, are quite innaccurate
// and the innaccuracy worsens with longer paths (accumulative rounding error). So if your paths are likely to exceed 1000 points in length, it's better to use
// the DK methods.

#define USE_OMNI_METHODS 0

#if USE_OMNI_METHODS
#import "UIBezierPath-OAExtensions.h"
#endif

#pragma mark Static Functions
static void				ConvertPathApplierFunction ( void *info, const CGPathElement *element );
static CGFloat			lengthOfBezier(const  CGPoint bez[4], CGFloat acceptableError);
static inline CGFloat		distanceBetween(CGPoint a, CGPoint b);

static void				InterpolatePoints( const CGPoint* pointsIn, CGPoint* cp1, CGPoint* cp2, const CGFloat smooth_value );
static CGPoint			CornerPoint( const CGPoint* pointsIn, CGFloat offset, CGFloat miterLimit );
static BOOL				CornerArc( const CGPoint* pointsIn, CGFloat offset, UIBezierPath* newPath );
static BOOL				CornerBevel( const CGPoint* pointsIn, CGFloat offset, UIBezierPath* newPath );

@interface UIBezierPath (Geometry_Private)
- (UIBezierPath*)		paralleloidPathWithOffset3:(CGFloat) delta lineJoinStyle:(CGLineJoin) js;

@end

#pragma mark -
@implementation UIBezierPath (Geometry)
#pragma mark As an UIBezierPath

- (UIBezierPath*)		scaledPath:(CGFloat) scale
{
	// returns a copy of the receiver scaled by <scale>, with the path's origin assumed to be at the centre of its bounds rect.

	CGPoint	cp = [self centreOfBounds];
	return [self scaledPath:scale aboutPoint:cp];
}


- (UIBezierPath*)		scaledPath:(CGFloat) scale aboutPoint:(CGPoint) cp
{
	// This is like an inset or an outset operation. If scale is 1.0, self is returned.
	
	if( scale == 1.0 )
		return self;
	else
	{
		UIBezierPath* copy = [self copy];
		
		NSAffineTransform*	xfm = [NSAffineTransform transform];
		[xfm translateXBy:cp.x yBy:cp.y];
		[xfm scaleXBy:scale yBy:scale];
		[xfm translateXBy:-cp.x yBy:-cp.y];
		
		[copy transformUsingAffineTransform:xfm];
	
		return [copy autorelease];
	}
}


- (UIBezierPath*)		rotatedPath:(CGFloat) angle
{
	// return a rotated copy of the receiver. The origin is taken as the centre of the path bounds.
	// angle is a value in radians
	
	return [self rotatedPath:angle aboutPoint:[self centreOfBounds]];
}


- (UIBezierPath*)		rotatedPath:(CGFloat) angle aboutPoint:(CGPoint) cp
{
	// return a rotated copy of the receiver. The origin is taken as point <cp> relative to the original path.
	// angle is a value in radians
	
	if( angle == 0.0 )
		return self;
	else
	{
		UIBezierPath* copy = [self copy];
	
		NSAffineTransform*	xfm = RotationTransform( angle, cp );
		[copy transformUsingAffineTransform:xfm];
		
		return [copy autorelease];
	}
}


- (UIBezierPath*)		insetPathBy:(CGFloat) amount
{
	// returns a scaled copy of the receiver, calculating the scale by adding <amount> to all edges of the bounds.
	// since this can scale differently in x and y directions, this doesn't call the scale function but works
	// very similarly.
	
	// note that due to the mathematics of bezier curves, this may not produce exactly perfect results for some
	// curves.
	
	// +ve values of <amount> inset (shrink) the path, -ve values outset (grow) the shape.
	
	if( amount == 0.0 )
		return self;
	else
	{
		CGRect	r = CGRectInset([self bounds], amount, amount );
		CGFloat	xs, ys;
		
		xs = r.size.width / [self bounds].size.width;
		ys = r.size.height / [self bounds].size.height;
		
		UIBezierPath* copy = [self copy];
		CGPoint		cp = [copy centreOfBounds];
		
		NSAffineTransform*	xfm = [NSAffineTransform transform];
		[xfm translateXBy:cp.x yBy:cp.y];
		[xfm scaleXBy:xs yBy:ys];
		[xfm translateXBy:-cp.x yBy:-cp.y];
		
		[copy transformUsingAffineTransform:xfm];
		
		return [copy autorelease];
	}
}


- (UIBezierPath*)		horizontallyFlippedPathAboutPoint:(CGPoint) cp
{
	UIBezierPath* copy = [self copy];
	
	NSAffineTransform*	xfm = [NSAffineTransform transform];
	[xfm translateXBy:cp.x yBy:cp.y];
	[xfm scaleXBy:-1.0 yBy:1.0];
	[xfm translateXBy:-cp.x yBy:-cp.y];
	
	[copy transformUsingAffineTransform:xfm];
	
	return [copy autorelease];
}


- (UIBezierPath*)		verticallyFlippedPathAboutPoint:(CGPoint) cp
{
	UIBezierPath* copy = [self copy];
	
	NSAffineTransform*	xfm = [NSAffineTransform transform];
	[xfm translateXBy:cp.x yBy:cp.y];
	[xfm scaleXBy:1.0 yBy:-1.0];
	[xfm translateXBy:-cp.x yBy:-cp.y];
	
	[copy transformUsingAffineTransform:xfm];
	
	return [copy autorelease];
}


- (UIBezierPath*)		horizontallyFlippedPath
{
	return [self horizontallyFlippedPathAboutPoint:[self centreOfBounds]];
}


- (UIBezierPath*)		verticallyFlippedPath
{
	return [self verticallyFlippedPathAboutPoint:[self centreOfBounds]];
}


#pragma mark -
- (CGPoint)				centreOfBounds
{
	return CGPointMake( NSMidX([self bounds]), NSMidY([self bounds]));
}


- (CGFloat)				minimumCornerAngle
{
	// returns the smallest angle subtended by any segment join in the path. The largest value this can be is pi (180 degrees), the smallest is 0. The
	// resultis in radians. Can be used to determine the necessary bounding rect of the path for a given stroke width and miter limit. For curve
	// elements, the curvature is ignored and the element treated as a line segment.
	
	CGFloat				v, a = M_PI;
	NSInteger					i, m = [self elementCount] - 1;
	CGPathElement	element, nextElement;
	CGPoint				fp, cp, pp, xp, ap[3], np[3];
	
	fp = cp = pp = xp = CGPointZero;
	
	for( i = 0; i < m; ++i )
	{
		element = [self elementAtIndex:i associatedPoints:ap];
		nextElement = [self elementAtIndex:i + 1 associatedPoints:np];
		
		switch( element.type )
		{
			case kCGPathElementMoveToPoint:
				fp = pp = ap[0];
				continue;
				
			case kCGPathElementAddLineToPoint:
				cp = ap[0];
				break;
				
			case kCGPathElementAddCurveToPoint:
				cp = ap[2];
				break;
				
			case kCGPathElementCloseSubpath:
				cp = fp;
				break;
				
			default:
				break;
		}
		
		switch( nextElement.type )
		{
			case kCGPathElementMoveToPoint:
				continue;
				
			case kCGPathElementAddLineToPoint:
				xp = np[0];
				break;
				
			case kCGPathElementAddCurveToPoint:
				xp = np[2];
				break;
				
			case kCGPathElementCloseSubpath:
				xp = fp;
				break;
				
			default:
				break;
		}
		
		v = fabs( AngleBetween( pp, cp, xp ));
		
		if ( v < a )
			a = v;
			
		pp = cp;
	}
	
	return a;
}


- (UIBezierPath*)		bezierPathByIteratingWithDelegate:(id) delegate contextInfo:(void*) contextInfo
{
	// this method allows a delegate to use the info from the receiver to build a new path element by element. This is a generic method that is intended to
	// avoid the need to write these loops over and over. The delegate is passed the points of each element in an order that is easier to work with than
	// the native list and also always includes the last point in a subpath.
	
	NSAssert( delegate != nil, @"cannot operate with a nil delegate");
	
	if(![delegate respondsToSelector:@selector(path:elementIndex:type:points:subPathIndex:subPathClosed:contextInfo:)])
		return nil;
		
	if([self isEmpty])
		return nil;
		
	UIBezierPath* newPath = [UIBezierPath bezierPath];	
	
	NSInteger					i, m, spi = -1;
	CGPoint				ap[3];
	CGPoint				rp[4];
	BOOL				spc = NO;
	CGPathElement	element;
	
	m = [self elementCount];
	
	for( i = 0; i < m; ++i )
	{
		element = [self elementAtIndex:i associatedPoints:ap];
		
		if( element.type == kCGPathElementMoveToPoint )
		{
			// get info about the end of this subpath
			
			++spi;
			
			// is it closed?
			
			spc = [self subpathContainingElementIsClosed:i];
			
			// what is its end point?
			
			NSInteger			spe = [self subpathEndingElementForElement:i];
			CGPoint		ep[3];
			
			if ( spc )
				--spe;	// ignore closePath element
				
			CGPathElement	ee = [self elementAtIndex:spe associatedPoints:ep];
			
			if ( ee.type == kCGPathElementAddCurveToPoint )
				rp[3] = ep[2];
			else
				rp[3] = ep[0];
		}
		
		// set up the list of points (reordered from ap). The list passed to the delegate is always ordered thus:
		//[0] = the next on-path point
		//[1] = cp1 for a curve element
		//[2] = cp2 for a curve element
		//[3] = the end point of the current subpath
		
		if( element.type == kCGPathElementAddCurveToPoint )
		{
			rp[0] = ap[2];
			rp[1] = ap[0];
			rp[2] = ap[1];
		}
		else
			rp[0] = rp[1] = rp[2] = ap[0];
	
		// let the delegate do its thing with the info:
		
		[delegate path:newPath elementIndex:i type:element points:rp subPathIndex:spi subPathClosed:spc contextInfo:contextInfo];
	}
	
	return newPath;
}


#pragma mark -
- (UIBezierPath*)		paralleloidPathWithOffset:(CGFloat) delta
{
	// returns a copy of the receiver modified by offsetting all of its control points by <delta> in the direction of the
	// normal of the path at the location of the on-path control point. This will create a parallel-ish offset path that works
	// for most non-pathological paths. Given that there is no known mathematically correct way to do this (for bezier curves), this works well enough in
	// many practical situations. Positive delta moves the path below or to the right, -ve is up and left.
	
	UIBezierPath* newPath = [UIBezierPath bezierPath];
	
	if( ![self isEmpty])
	{
		NSInteger				i, count = [self elementCount];
		CGPoint					ap[3], np[3], p0, p1;
		CGPathElement		kind, nextKind;
		CGFloat					slope, dx, dy, pdx, pdy;
		
		pdx = pdy = 0;
		
		for( i = 0; i < count; ++i )
		{
			kind = [self elementAtIndex:i associatedPoints:ap];
			
			if ( i < count - 1 )
			{
				[self elementAtIndex:i + 1 associatedPoints:np];
				
				// calculate the slope of the on-path point
				
				if ( kind.type != kCGPathElementAddCurveToPoint )
				{
					p0 = ap[0];
					p1 = np[0];
				}
				else
				{
					p0 = ap[2];
					p1 = np[0];
				}
			}
			else
			{
				if ( kind.type == kCGPathElementAddCurveToPoint )
				{
					p1 = ap[2];
					p0 = ap[1];
				}
				else
				{
					p1 = ap[0];
					
					nextKind = [self elementAtIndex:i - 1 associatedPoints:np];
				
					if ( nextKind.type != kCGPathElementAddCurveToPoint )
						p0 = np[0];
					else
						p0 = np[2];
				}
			}
			
			slope = atan2f( p1.y - p0.y, p1.x - p0.x ) + ( M_PI * 0.5 );
			
			// calculate the position of the modified point
			
			dx = delta * cosf( slope );
			dy = delta * sinf( slope );
			
			switch( kind.type )
			{
				case kCGPathElementMoveToPoint:
					ap[0].x += dx;
					ap[0].y += dy;
					[newPath moveToPoint:ap[0]];
					break;
					
				case kCGPathElementAddLineToPoint:
					ap[0].x += dx;
					ap[0].y += dy;
					[newPath addLineToPoint:ap[0]];
					break;
					
				case kCGPathElementAddCurveToPoint:
					ap[0].x += pdx;
					ap[0].y += pdy;
					ap[1].x += dx;
					ap[1].y += dy;
					ap[2].x += dx;
					ap[2].y += dy;
					[newPath addCurveToPoint:ap[2] controlPoint1:ap[0] controlPoint2:ap[1]];
					break;
					
				case kCGPathElementCloseSubpath:
					[newPath closePath];
					break;
					
				default:
					break;
			}
			
			pdx = dx;
			pdy = dy;
		}
	}

	return newPath;
}


static CGPoint	CornerPoint( const CGPoint* pointsIn, CGFloat offset, CGFloat miterLimit )
{
	// given 3 points in pointsIn, this returns the point that bisects the angle between the vertices, and is extended to intercept the <offset>
	// parallel up to <miterLimit>. This is used to compute the correct location of a vertex for a parallel offset path.	
	// for zero offset, result is simply second point.
	// The three points are three consecutive vertices from the original path.
	
	if( offset == 0.0 )
		return pointsIn[1];
	
	CGPoint rp;
	CGFloat	relAngle, r, s1, s2, angle;
	
	s1 = Slope( pointsIn[0], pointsIn[1]);
	s2 = Slope( pointsIn[1], pointsIn[2]);
	
	relAngle = ( s2 - s1 ) * 0.5f;
	r = offset / cosf( relAngle );
	angle = s1 + relAngle + NINETY_DEGREES;
	
	CGFloat maxR = fabs( miterLimit * offset );
	
	if( r > maxR )
		r = maxR;
	
	if( r < -maxR )
		r = -maxR;
	
	rp.x = pointsIn[1].x + r * cosf( angle );
	rp.y = pointsIn[1].y + r * sinf( angle );
	
	return rp;
}


static BOOL		CornerArc( const CGPoint* pointsIn, CGFloat offset, UIBezierPath* newPath )
{
	// returns an arc segment that is centred at the middle vertex having a radius of <offset> and a start point and end point such that the offset normals to the original
	// edges are joined by the arc. If the vertex is an inside bend, returns nil in which case the CornerPoint should be used.
	
	if( offset == 0.0 )
		return NO;
	
	CGFloat	s1, s2, ra;
	
	s1 = Slope( pointsIn[0], pointsIn[1]);
	s2 = Slope( pointsIn[2], pointsIn[1]);
	
	// only the arc that goes around the "outside" of the bend is required, so we need a way to detect which side of the line we are offsetting to
	// and only append an arc for the outside case.
	
	ra = s2 - s1;
	
	if( ra > M_PI )
		ra = M_PI - ra;
	
	if( ra < -M_PI )
		ra = -M_PI - ra;
	
	//NSLog(@"ra = %f, offset = %f", ra, offset );
	
	if(( ra < 0 && offset > 0 ) || ( ra > 0 && offset < 0 ))
		return NO;
	
	s2 = Slope( pointsIn[1], pointsIn[2]);
	
    [newPath addArcWithCenter:pointsIn[1] radius:offset startAngle:RADIANS_TO_DEGREES(s1 + NINETY_DEGREES) endAngle:RADIANS_TO_DEGREES(s2 + NINETY_DEGREES) clockwise:offset > 0 ];
	
	return YES;
}


static BOOL		CornerBevel( const CGPoint* pointsIn, CGFloat offset, UIBezierPath* newPath )
{
	// appends a bevel segment that is centred at the middle vertex having a radius of <offset> and a start point and end point such that the offset normals to the original
	// edges are joined by the arc. If the vertex is an inside bend, returns nil in which case the CornerPoint should be used.
	
	if( offset == 0.0 )
		return NO;
	
	CGFloat	s1, s2, ra;
	
	s1 = Slope( pointsIn[0], pointsIn[1]);
	s2 = Slope( pointsIn[2], pointsIn[1]);
	
	// only the arc that goes around the "outside" of the bend is required, so we need a way to detect which side of the line we are offsetting to
	// and only append an arc for the outside case.
	
	ra = s2 - s1;
	
	if( ra > M_PI )
		ra = M_PI - ra;
	
	if( ra < -M_PI )
		ra = -M_PI - ra;
	
	//NSLog(@"ra = %f, offset = %f", ra, offset );
	
	if(( ra < 0 && offset > 0 ) || ( ra > 0 && offset < 0 ))
		return NO;
	
	CGPoint pa, pb;
	
	pa.x = pointsIn[1].x + offset * cosf( s1 + NINETY_DEGREES );
	pa.y = pointsIn[1].y + offset * sinf( s1 + NINETY_DEGREES );
	pb.x = pointsIn[1].x + offset * cosf( s2 - NINETY_DEGREES );
	pb.y = pointsIn[1].y + offset * sinf( s2 - NINETY_DEGREES );
	
	[newPath addLineToPoint:pa];
	[newPath addLineToPoint:pb];
	
	return YES;
}



- (UIBezierPath*)		paralleloidPathWithOffset2:(CGFloat) delta
{
	// returns a path offset by <delta>, using the paralleloidPathWithOffset method above on a flattened version of the path. If the caller sets the
	// default flatness prior to calling this they can control the fineness of the offset path. The offset joins are set to match the current line join style.
	
	if( delta == 0.0 )
		return self;
	
	UIBezierPath* temp;
	temp = [self bezierPathByFlatteningPath];
	temp = [temp paralleloidPathWithOffset:delta];

	return temp;
}


- (UIBezierPath*)		paralleloidPathWithOffset22:(CGFloat) delta
{
	// returns a path offset by <delta>, using the paralleloidPathWithOffset3 method below on a flattened version of the path. If the caller sets the
	// default flatness prior to calling this they can control the fineness of the offset path. The offset joins are set to match the current line join style.
	
	if( delta == 0.0 )
		return self;
	
	UIBezierPath* temp;
	temp = [self bezierPathByFlatteningPath];
	temp = [temp paralleloidPathWithOffset3:delta lineJoinStyle:[self lineJoinStyle]];
	
	return temp;
}



- (UIBezierPath*)		paralleloidPathWithOffset3:(CGFloat) delta lineJoinStyle:(CGLineJoin) js
{
	// requires flattened path, calculates correct points at the corners
	
	UIBezierPath*		newPath = [UIBezierPath bezierPath];
	NSInteger			i, m = [self elementCount], spc = 0, spStartIndex = 0;
	CGPathElement element;
	CGPoint				ap[3];
	CGPoint				v[3];
	CGPoint				fp, op, sop;
	CGFloat				slope;
	
	v[0] = v[1] = v[2] = sop = op = fp = CGPointZero;
	
	for( i = 0; i < m; ++i )
	{
		element = [self elementAtIndex:i associatedPoints:ap];
		
		switch( element.type )
		{
			case kCGPathElementMoveToPoint:
				// starting a new subpath - don't start the new path yet as we need the next point to know the slope
				
				fp = v[0] = ap[0];
				spc = 0;
				break;
				
			case kCGPathElementAddLineToPoint:
				if( spc == 0 )
				{
					// recently started a new subpath, so set 2nd vertex
					v[1] = ap[0];
					spc++;
					
					// ok, we have enough to work out the slope and start the new path
					
					slope = Slope( v[0], v[1] ) + M_PI * 0.5f;
					op.x = v[0].x + delta * cosf( slope );
					op.y = v[0].y + delta * sinf( slope );
					[newPath moveToPoint:op];
					spStartIndex = [newPath elementCount] - 1;
				}
				else
				{
					v[2] = ap[0];
					
					// we have three vertices, so we can calculate the required corner point
					
					op = CornerPoint( v, delta, [self miterLimit] );
					if( js == kCGLineJoinMiter )
						[newPath addLineToPoint:op];
					else if( js == kCGLineJoinBevel )
					{
						if( !CornerBevel( v, delta, newPath ))
							[newPath addLineToPoint:op];
					}
					else
					{
						if( !CornerArc( v, delta, newPath ))
							[newPath addLineToPoint:op];
					}
					
					if( spc == 1 )
						sop = op;
					
					// shift vertex array
					
					v[0] = v[1];
					v[1] = v[2];
					spc++;
				}
				break;
				
			case kCGPathElementAddCurveToPoint:
				NSAssert( NO, @"paralleloidPathWithOffset3 requires a flattened path");
				break;
				
			case kCGPathElementCloseSubpath:
				// close the path by curving back to the first point
				v[2] = fp;
				
				op = CornerPoint( v, delta, [self miterLimit] );
				if( js == kCGLineJoinMiter )
					[newPath addLineToPoint:op];
				else if( js == kCGLineJoinBevel )
				{
					if( !CornerBevel( v, delta, newPath ))
						[newPath addLineToPoint:op];
				}
				else
				{
					if( !CornerArc( v, delta, newPath ))
						[newPath addLineToPoint:op];
				}
				v[0] = v[1];
				v[1] = v[2];
				v[2] = sop;
				
				op = CornerPoint( v, delta, [self miterLimit]);
				if( js == kCGLineJoinMiter )
				{
					[newPath addLineToPoint:op];
					[newPath setAssociatedPoints:&op atIndex:spStartIndex];
				}
				else if( js == kCGLineJoinBevel )
				{
					if( !CornerBevel( v, delta, newPath ))
					{
						[newPath addLineToPoint:op];
						[newPath setAssociatedPoints:&op atIndex:spStartIndex];
					}
				}
				else
				{
					if( !CornerArc( v, delta, newPath ))
					{
						[newPath addLineToPoint:op];
						[newPath setAssociatedPoints:&op atIndex:spStartIndex];
					}
				}
				spc = 0;
				
				[newPath closePath];
				break;
				
			default:
				break;
		}
	}
	
	if( spc > 0 )
	{
		// open-ended path, place last offset point
		
		slope = Slope( v[0], v[1] ) + M_PI * 0.5f;
		op.x = v[1].x + delta * cosf( slope );
		op.y = v[1].y + delta * sinf( slope );
		[newPath addLineToPoint:op];
	}
	
	return newPath;
}


- (UIBezierPath*)		offsetPathWithStartingOffset:(CGFloat) delta1 endingOffset:(CGFloat) delta2
{
	// similar to making a paralleloid path, but instead of a constant offset, each point has a different offset
	// applied as a linear function of the difference between delta1 and delta2. So the result has a similar curvature
	// to the original path, but also an additional ramp.
	
	UIBezierPath* newPath = [UIBezierPath bezierPath];
	
	if( ![self isEmpty])
	{
		NSInteger				i, count = [self elementCount];
		CGPoint					ap[3], np[3], p0, p1;
		CGPathElement		kind, nextKind;
		CGFloat					del, slope, dx, dy, pdx, pdy;
		
		pdx = pdy = 0;
		
		for( i = 0; i < count; ++i )
		{
			del = ((( delta2 - delta1 ) * i ) / ( count - 1 )) + delta1;
			
		//	LogEvent_(kInfoEvent, @"segment %d, del = %f", i, del );
			
			kind = [self elementAtIndex:i associatedPoints:ap];
			
			if ( i < count - 1 )
			{
				[self elementAtIndex:i + 1 associatedPoints:np];
				
				// calculate the slope of the on-path point
				
				if ( kind.type != kCGPathElementAddCurveToPoint )
				{
					p0 = ap[0];
					p1 = np[0];
				}
				else
				{
					p0 = ap[2];
					p1 = np[0];
				}
			}
			else
			{
				if ( kind.type == kCGPathElementAddCurveToPoint )
				{
					p1 = ap[2];
					p0 = ap[1];
				}
				else
				{
					p1 = ap[0];
					
					nextKind = [self elementAtIndex:i - 1 associatedPoints:np];
				
					if ( nextKind.type != kCGPathElementAddCurveToPoint )
						p0 = np[0];
					else
						p0 = np[2];
				}
			}
			
			slope = atan2f( p1.y - p0.y, p1.x - p0.x ) + ( M_PI * 0.5 );
			
			// calculate the position of the modified point
			
			dx = del * cosf( slope );
			dy = del * sinf( slope );
			
			switch( kind.type )
			{
				case kCGPathElementMoveToPoint:
					ap[0].x += dx;
					ap[0].y += dy;
					[newPath moveToPoint:ap[0]];
					break;
					
				case kCGPathElementAddLineToPoint:
					ap[0].x += dx;
					ap[0].y += dy;
					[newPath addLineToPoint:ap[0]];
					break;
					
				case kCGPathElementAddCurveToPoint:
				{
					ap[0].x += pdx;
					ap[0].y += pdy;
					ap[1].x += dx;
					ap[1].y += dy;
					ap[2].x += dx;
					ap[2].y += dy;
					[newPath addCurveToPoint:ap[2] controlPoint1:ap[0] controlPoint2:ap[1]];
				}
				break;
					
				case kCGPathElementCloseSubpath:
					[newPath closePath];
					break;
					
				default:
					break;
			}
			
			pdx = dx;
			pdy = dy;
		}
	}

	return newPath;
}


- (UIBezierPath*)		offsetPathWithStartingOffset2:(CGFloat) delta1 endingOffset:(CGFloat) delta2
{
	// When GPC is disabled, works exactly as above.
	UIBezierPath* temp = self;
#ifndef qUseGPC
 #pragma unused (delta1, delta2)
#else
	temp = [temp bezierPathByFlatteningPath];
#endif
	temp = [temp offsetPathWithStartingOffset:delta1 endingOffset:delta2];
#ifdef qUseGPC
	temp = [temp bezierPathByUnflatteningPath];
#endif
	return temp;
}


- (UIBezierPath*)		bezierPathByInterpolatingPath:(CGFloat) amount
{
	// smooths a vector (line segment) path by interpolation into curve segments. This algorithm from http://antigrain.com/research/bezier_interpolation/index.html#PAGE_BEZIER_INTERPOLATION
	// existing curve segments are reinterpolated as if a straight line joined the start and end points. Note this doesn't simplify a curve - it merely smooths it using the same number
	// of curve segments. <amount> is a value from 0..1 that yields the amount of smoothing, 0 = none.
	
	amount = LIMIT( amount, 0, 1 );
	
	if( amount == 0.0 || [self isEmpty])
		return self;	// nothing to do
	
	UIBezierPath*		newPath = [UIBezierPath bezierPath];
	NSInteger					i, m = [self elementCount], spc = 0;
	CGPathElement element;
	CGPoint				ap[3];
	CGPoint				v[3];
	CGPoint				fp, cp1, cp2, pcp;
	
	fp = cp1 = cp2 = CGPointZero;
	v[0] = v[1] = v[2] = CGPointZero;
	
	for( i = 0; i < m; ++i )
	{
		element = [self elementAtIndex:i associatedPoints:ap];
		
		switch( element.type )
		{
			case kCGPathElementMoveToPoint:
				// starting a new subpath
				
				[newPath moveToPoint:ap[0]];
				fp = v[0] = ap[0];
				spc = 0;
				break;
				
			case kCGPathElementAddLineToPoint:
				if( spc == 0 )
				{
					// recently started a new subpath, so set 2nd vertex
					v[1] = ap[0];
					spc++;
				}
				else
				{
					v[2] = ap[0];
					
					// we have three vertices, so we can interpolate
					
					InterpolatePoints( v, &cp1, &cp2, amount );
					
					// cp2 completes the  curve segment v0..v1 so we can add that to the new path. If it was the first
					// segment, cp1 == cp2
					
					if( spc == 1 )
						pcp = cp2;
					
					[newPath addCurveToPoint:v[1] controlPoint1:pcp controlPoint2:cp2];
					
					// shift vertex array
					
					v[0] = v[1];
					v[1] = v[2];
					pcp = cp1;
					spc++;
				}
				break;
				
			case kCGPathElementAddCurveToPoint:
				if( spc == 0 )
				{
					// recently started a new subpath, so set 2nd vertex
					v[1] = ap[2];
					spc++;
				}
				else
				{
					v[2] = ap[2];
					
					// we have three vertices, so we can interpolate
					
					InterpolatePoints( v, &cp1, &cp2, amount );
					
					// cp2 completes the  curve segment v0..v1 so we can add that to the new path. If it was the first
					// segment, cp1 == cp2
					
					if( spc == 1 )
						pcp = cp2;
					
					[newPath addCurveToPoint:v[1] controlPoint1:pcp controlPoint2:cp2];
					
					// shift vertex array
					
					v[0] = v[1];
					v[1] = v[2];
					pcp = cp1;
					spc++;
				}
				break;
				
			case kCGPathElementCloseSubpath:
				// close the path by curving back to the first point
				v[2] = fp;
				
				InterpolatePoints( v, &cp1, &cp2, amount );
				
				// cp2 completes the  curve segment v0..v1 so we can add that to the new path. If it was the first
				// segment, cp1 == cp2
				
				if( spc == 1 )
					pcp = cp2;
				
				[newPath addCurveToPoint:v[1] controlPoint1:pcp controlPoint2:cp2];
				
				// final segment closes the path
				
				[newPath addCurveToPoint:fp controlPoint1:cp1 controlPoint2:cp1];
				[newPath closePath];
				spc = 0;
				break;
				
			default:
				break;
		}
	}
	
	if( spc > 1 )
	{
		// path ended without a closepath, so add in the final curve segment to the end
		
		[newPath addCurveToPoint:v[1] controlPoint1:pcp controlPoint2:pcp];
	}
	
	//NSLog(@"new path = %@", newPath);
	
	return newPath;
}


static void				InterpolatePoints( const CGPoint* v, CGPoint* cp1, CGPoint* cp2, const CGFloat smooth_value )
{
	// given the vertices of the path v0..v2, this calculates cp1 and cp2 being the control points for the curve segments v0..v1 and v1..v2. i.e. this
	// calculates only half of the control points, but does so for two segments. The caller needs to accumulate cp1 until it has cp2 for the same segment
	// before it can add the curve segment.
	
	// calculate the midpoints of the two edges
	
	CGFloat xc1 = ( v[0].x + v[1].x ) * 0.5f;	//(x0 + x1) / 2.0;
    CGFloat yc1 =	( v[0].y + v[1].y ) * 0.5f;	//(y0 + y1) / 2.0;
    CGFloat xc2 =	( v[1].x + v[2].x ) * 0.5f;	//(x1 + x2) / 2.0;
    CGFloat yc2 =	( v[1].y + v[2].y ) * 0.5f;	//(y1 + y2) / 2.0;
	
	// calculate the ratio of the two lengths

    CGFloat len1 = hypotf( v[1].x - v[0].x, v[1].y - v[0].y );	//sqrt((x1-x0) * (x1-x0) + (y1-y0) * (y1-y0));
    CGFloat len2 = hypotf( v[2].x - v[1].x, v[2].y - v[1].y );	//sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1));
    CGFloat k1;
	
	if(( len1 + len2 ) > 0.0 )
		k1 = len1 / (len1 + len2);
    else
		k1 = 0.0;
	
	// calculate the pivot point of the control point "arms" xm1, ym1
	
    CGFloat xm1 =	xc1 + (xc2 - xc1) * k1;
    CGFloat ym1 = yc1 + (yc2 - yc1) * k1;

	CGPoint ctrl1, ctrl2;
	
	// ctrl1 is CP1 for the segment v1..v2
	// ctrl2 is CP2 for the segment v0..v1
	
    ctrl1.x = ( xm1 + (xc2 - xm1) * smooth_value ) + v[1].x - xm1;
    ctrl1.y = ( ym1 + (yc2 - ym1) * smooth_value ) + v[1].y - ym1;
	
	ctrl2.x = ( xm1 - (xm1 - xc1) * smooth_value ) + v[1].x - xm1;
	ctrl2.y = ( ym1 - (ym1 - yc1) * smooth_value ) + v[1].y - ym1;

	if( cp1 )
		*cp1 = ctrl1;
		
	if( cp2 )
		*cp2 = ctrl2;
}


- (UIBezierPath*)		filletPathForVertex:(CGPoint[]) vp filletSize:(CGFloat) fs
{
	// given three points vp[0]..vp[2], this calculates a curve that will form a fillet. <fs> is the size of the fillet, expressed as the distance from the
	// apex ap[1] along each side of the vertex. The returned path consists of a single element curve segment.
	
	CGPoint fa, fb;
	CGFloat	ra, rb;
	
	ra = fs / LineLength(vp[0], vp[1]);
	rb = fs / LineLength(vp[1], vp[2]);
	
	fa = Interpolate(vp[1], vp[0], ra);
	fb = Interpolate(vp[1], vp[2], rb);
	
	UIBezierPath* path = [UIBezierPath bezierPath];
	[path moveToPoint:fa];
	[path addCurveToPoint:fb controlPoint1:vp[1] controlPoint2:vp[1]];
	
	return path;
}


#pragma mark -


- (UIBezierPath*)		bezierPathWithRoughenedStrokeOutline:(CGFloat) amount
{
	// given the path, this returns the outline of the path stroke roughened by the given amount. Roughening works by first taking the stroke outline at the
	// current stroke width, inserting a large number of redundant points and then randomly offsetting each one by a small amount. The result is a path that, when
	// FILLED, will emulate a stroke drawn using a randomly varying width pen. This can be used to give a very naturalistic effect that precise strokes lack. 
	
	UIBezierPath* newPath = [self strokedPath];
	
	if ( newPath != nil && amount > 0.0 )
	{
		// work out the desired flatness by getting the average length of the elements and dividing that down:

		CGFloat flatness = 4.0 / ([newPath length] / [newPath elementCount]);
		
		//NSLog(@"flatness = %f", flatness);
		
		// break up existing line segments into short lengths:
		
		newPath = [newPath bezierPathWithFragmentedLineSegments:[self lineWidth] / 2.0 ];
		
		// flatten the path - this breaks up curve segments into short straight segments
		
		CGFloat savedFlatness = [[self class] defaultFlatness];
		[[self class] setDefaultFlatness:flatness];
		newPath = [newPath bezierPathByFlatteningPath];
		[[self class] setDefaultFlatness:savedFlatness];
		
		// randomise the positions of the points
		
		newPath = [newPath bezierPathByRandomisingPoints:amount];
	}
	
	return newPath; //[newPath bezierPathByUnflatteningPath];
}


- (UIBezierPath*)		bezierPathWithFragmentedLineSegments:(CGFloat) flatness
{
	// this is only really useful as a step in the roughened stroke processing. It takes a path and for any line elements in the path, it breaks them up into
	// much shorter lengths by interpolation.
	
	UIBezierPath*			newPath = [UIBezierPath bezierPath];
	NSInteger				i, m, k, j;
	CGPathElement		element;
	CGPoint					ap[3];
	CGPoint					fp, pp;
	CGFloat					len, t;
	
	fp = pp = CGPointZero;	// shut up, stupid warning
	
	m = [self elementCount];
	
	for( i = 0; i < m; ++ i )
	{
		element = [self elementAtIndex:i associatedPoints:ap];
		
		switch( element.type )
		{
			case kCGPathElementMoveToPoint:
				fp = pp = ap[0];
				[newPath moveToPoint:fp];
				break;
				
			case kCGPathElementAddLineToPoint:
				len = LineLength( pp, ap[0] );
				k = ceil( len / flatness );
				
				if( k <= 0.0 )
					continue;
				
				//NSLog(@"inserting %d fragments", k );
				
				for( j = 0; j < k; ++j )
				{
					t = (( j + 1 ) * flatness ) / len;
					CGPoint np = Interpolate( pp, ap[0], t );
					[newPath addLineToPoint:np];
				}
				pp = ap[0];
				break;
				
			case kCGPathElementAddCurveToPoint:
				[newPath addCurveToPoint:ap[2] controlPoint1:ap[0] controlPoint2:ap[1]];
				pp = ap[2];
				break;
				
			case kCGPathElementCloseSubpath:
				[newPath closePath];
				pp = fp;
				break;
				
			default:
				break;
		}
	}

	return newPath;
}



#pragma mark -
#pragma mark - zig-zags and waves
- (UIBezierPath*)		bezierPathWithZig:(CGFloat) zig zag:(CGFloat) zag
{
	// returns a zigzag based on the original path. The "zig" is the length along the path between each point, and the "zag" is the distance offset
	// normal to the path. By joining up the series of points so generated, an accurate zig-zag path is formed. Note that the returned path follows the
	// curvature of the original but it contains no curved segments itself.
	
	NSAssert( zig > 0, @"zig must be > 0");
	
	// no amplitude, return the original path
	
	if( zag <= 0 )
		return self;
	
	CGFloat			len, t = 0.0, slope;
	CGPoint			zp, np;
	UIBezierPath*	newPath;
	BOOL			side = 0;		// are we zigging or zagging?
	BOOL			doneFirst = NO;
	
	len = [self length];
	newPath = [UIBezierPath bezierPath];
	[newPath moveToPoint:[self firstPoint]];
    [newPath setUsesEvenOddFillRule:self.usesEvenOddFillRule];
	
	while( t < len )
	{
		if (( t + zig ) > len )
		{
			if ([self isPathClosed])
				zp = [self pointOnPathAtLength:0.0 slope:&slope];
			else
				zp = [self pointOnPathAtLength:len slope:&slope];
		}
		else
			zp = [self pointOnPathAtLength:t slope:&slope];
	
		// calculate position of corner offset from the path
		
		if ( side )
			slope += ( M_PI / 2.0 );
		else
			slope -= ( M_PI / 2.0 );
	
		side = !side;
		
		np.x = zp.x + ( cosf( slope ) * zag );
		np.y = zp.y + ( sinf( slope ) * zag );
		
		if ( doneFirst )
			[newPath addLineToPoint:np];
		else
		{
			[newPath moveToPoint:np];
			doneFirst = YES;
		}
		
		t += zig;
	}
	
	if ([self isPathClosed])
		[newPath closePath];
		
	return newPath;
}


- (UIBezierPath*)		bezierPathWithWavelength:(CGFloat) lambda amplitude:(CGFloat) amp spread:(CGFloat) spread
{
	// similar effect to a zig-zag, but creates curved segments which smoothly oscillate about the master path. Wavelength is the distance between each peak
	// (note - this is half the actual "wavelength" in the strict sense) and amplitude is the distance from the path. Spread is a value indicating the
	// "roundness" of the peak, and is a value between 0 and 1. 0 is equivalent to a sharp zig-zag as above.
	
	NSAssert( lambda > 0, @"wavelength cannot be 0 or negative");
	
	// if amplitude is zero, there is no zig-zag - just return the original path
	
	if( amp <= 0 )
		return self;
	
	// if no spread, return a triangle zig-zag with no curve elements
	
	if ( spread <= 0.0 )
		return [self bezierPathWithZig:lambda zag:amp];
	else
	{
		CGFloat			len, t = 0.0, slope, rad, lastSlope;
		CGPoint			zp, np, cp1, cp2;
		UIBezierPath*	newPath;
		BOOL			side = 0;		// are we zigging or zagging?
		BOOL			doneFirst = NO;
		
		len = [self length];
		newPath = [UIBezierPath bezierPath];
		[newPath moveToPoint:[self firstPoint]];
        [newPath setUsesEvenOddFillRule:self.usesEvenOddFillRule];

		rad = amp * spread;
		
		//NSLog(@"rad = %f", rad);
		
		lastSlope = [self slopeStartingPath];
		
		while( t <= len )
		{
			if (( t + lambda ) > len )
			{
				if ([self isPathClosed])
				{
					// if we are not in the same phase as the start of the path, need to insert an extra curve segment
					
					if ( side == 1 )
					{
						t = (t + len) / 2.0;
						zp = [self pointOnPathAtLength:t slope:&slope];
						lambda = MAX( 1, len - t );
					}
					else
						zp = [self pointOnPathAtLength:0.0 slope:&slope];
				}
				else
					zp = [self pointOnPathAtLength:len slope:&slope];
			}
			else
				zp = [self pointOnPathAtLength:t slope:&slope];
		
			// calculate position of peak offset from the path
			
			CGFloat slp = slope;
			
			if ( side )
				slp += ( M_PI / 2.0 );
			else
				slp -= ( M_PI / 2.0 );
		
			side = !side;
			
			np.x = zp.x + ( cosf( slp ) * amp );
			np.y = zp.y + ( sinf( slp ) * amp );
			
			// calculate the control points
			
			cp1 = [newPath currentPoint];
			cp1.x += cosf( lastSlope ) * rad;
			cp1.y += sinf( lastSlope ) * rad;
			
			cp2 = np;
			cp2.x += cosf( slope - M_PI ) * rad;
			cp2.y += sinf( slope - M_PI ) * rad;
			
			if ( doneFirst )
				[newPath addCurveToPoint:np controlPoint1:cp1 controlPoint2:cp2];
			else
			{
				[newPath moveToPoint:np];
				doneFirst = YES;
			}
			
			lastSlope = slope;
			t += lambda;
		}
		
		if ([self isPathClosed])
		{
			[newPath closePath];
		}
		return newPath;
	}
}


#pragma mark -
#pragma mark - getting the outline of a stroked path
- (UIBezierPath*)		strokedPath
{
	// returns a path representing the stroked edge of the receiver, taking into account its current width and other
	// stroke settings. This works by converting to a quartz path and using the similar system function there.
	
	// this creates an offscreen graphics context to support the CG function used, but the context itself does not
	// need to actually draw anything, therefore a simple 1x1 bitmap is used and reused for this context.
	
	UIBezierPath*				path = nil;
	CGContextRef			ctx = nil;

	int	bitmapBytesPerRow;
    int bitsPerComponent;
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
    bitsPerComponent = 8;
	bitmapBytesPerRow = 4;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

	ctx = CGBitmapContextCreate (NULL, 1, 1, bitsPerComponent, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst);

	NSAssert( ctx != nil, @"no context for -strokedPath");
	
    CGContextSaveGState(ctx);
    
    [self setQuartzPathInContext:ctx isNewPath:YES];
	
	path = self;
	
	if ( ctx )
	{
		CGContextReplacePathWithStrokedPath( ctx );
		path = [UIBezierPath bezierPathWithPathFromContext:ctx];
	}
	
    CGContextRestoreGState(ctx);

	return path;
}


- (UIBezierPath*)		strokedPathWithStrokeWidth:(CGFloat) width
{
	CGFloat savedLineWidth = [self lineWidth];
	
	[self setLineWidth:width];
	UIBezierPath* newPath = [self strokedPath];
	[self setLineWidth:savedLineWidth];
	
	return newPath;
}


#pragma mark -
#pragma mark - breaking a path apart

- (NSArray*)			subPaths
{
	// returns an array of bezier paths, each derived from this path's subpaths.
	// first see if we can take a shortcut - if there's only one subpath, just return self in the array
	
	if([self countSubPaths] < 2)
		return [NSArray arrayWithObject:self];
	
	// more than 1 subpath, break it down:
	
	NSMutableArray*		sp = [[NSMutableArray alloc] init];
    NSInteger					i, numElements;
	UIBezierPath*		temp = nil;
	BOOL				added = NO;
 
    numElements = [self elementCount];
	CGPoint	points[3];

	for (i = 0; i < numElements; i++)
	{
		switch ([self elementAtIndex:i associatedPoints:points].type)
		{
			case kCGPathElementMoveToPoint:
				temp = [UIBezierPath bezierPath];
				[temp moveToPoint:points[0]];
				added = NO;
				break;

			case kCGPathElementAddLineToPoint:
				[temp addLineToPoint:points[0]];
				break;

			case kCGPathElementAddCurveToPoint:
				[temp addCurveToPoint:points[2] controlPoint1:points[0] controlPoint2:points[1]];
				break;

			case kCGPathElementCloseSubpath:
				[temp closePath];
				break;
				
			default:
				break;
		}
		
		// object is added only if it has more than just the moveTo element
		
		if ( !added && [temp elementCount] > 1 )
		{
			[sp addObject:temp];
			added = YES;
		}
	}
	return [sp autorelease];
}


- (NSInteger)					countSubPaths
{
	// returns the number of moveTo ops in the path, though doesn't count a final moveTo as following a closepath
	
	NSInteger m, i, spc = 0;
	
    m = [self elementCount] - 1;

	for (i = 0; i < m; ++i)
	{
		if([self elementAtIndex:i].type == kCGPathElementMoveToPoint)
			++spc;
	}
	
	return spc;
}



#pragma mark -
#pragma mark - converting to and from Core Graphics paths

- (CGPathRef)			newQuartzPath
{
	CGMutablePathRef mpath = [self newMutableQuartzPath];
	CGPathRef		 path = CGPathCreateCopy(mpath);
    CGPathRelease(mpath);
	
	// the caller is responsible for releasing the returned value when done
	
	return path;
}


- (CGMutablePathRef)	newMutableQuartzPath
{
    NSInteger i, numElements;
 
    // If there are elements to draw, create a CGMutablePathRef and draw.

    numElements = [self elementCount];
    if (numElements > 0)
    {
        CGMutablePathRef    path = CGPathCreateMutable();
        CGPoint             points[3];
 
        for (i = 0; i < numElements; i++)
        {
            switch ([self elementAtIndex:i associatedPoints:points].type)
            {
                case kCGPathElementMoveToPoint:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
 
                case kCGPathElementAddLineToPoint:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    break;
 
                case kCGPathElementAddCurveToPoint:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                                points[1].x, points[1].y,
                                                points[2].x, points[2].y);
                    break;
 
                case kCGPathElementCloseSubpath:
                    CGPathCloseSubpath(path);
                    break;
					
				default:
					break;
            }
        }
		
		// the caller is responsible for releasing this ref when done
		
		return path;
    }
 
    return nil;
}


- (CGContextRef)		setQuartzPath
{
	// converts the path to a CGPath and adds it as the current context's path. It also copies the current line width
	// and join and cap styles, etc. to the context.
	
	CGContextRef	context = UIGraphicsGetCurrentContext();
	
	NSAssert( context != nil, @"no context for setQuartzPath");
	
	if ( context )
		[self setQuartzPathInContext:context isNewPath:YES];
	
	return context;
}


- (void)				setQuartzPathInContext:(CGContextRef) context isNewPath:(BOOL) np
{
	NSAssert( context != nil, @"no context for [UIBezierPath setQuartzPathInContext:isNewPath:]");
	
	CGPathRef		cp = [self newQuartzPath];
	
	if ( np )
		CGContextBeginPath( context );
		
	CGContextAddPath( context, cp );
	CGPathRelease( cp );
	
	CGContextSetLineWidth( context, [self lineWidth]);
	CGContextSetLineCap( context, (CGLineCap)[self lineCapStyle]);
	CGContextSetLineJoin( context, (CGLineJoin)[self lineJoinStyle]);
	CGContextSetMiterLimit( context, [self miterLimit]);
	
	CGFloat	lengths[16];
	CGFloat	phase;
	NSInteger		count;
	
	[self getLineDash:lengths count:&count phase:&phase];
	CGContextSetLineDash( context, phase, lengths, count );
}


#pragma mark -
+ (UIBezierPath*)		bezierPathWithCGPathCustom:(CGPathRef) path
{
	// given a CGPath, this converts it to the equivalent UIBezierPath by using a custom apply function
	
	NSAssert( path != nil, @"CG path was nil in bezierPathWithCGPath");
	
	UIBezierPath* newPath = [self bezierPath];
	CGPathApply( path, newPath, ConvertPathApplierFunction );
	return newPath;
}


+ (UIBezierPath*)		bezierPathWithPathFromContext:(CGContextRef) context
{
	// given a context, this converts its current path to an UIBezierPath. It is the inverse to the -setQuartzPath method.
	
	NSAssert( context != nil, @"no context for bezierPathWithPathFromContext");
	
	// WARNING: this uses an undocumented function in CG (CGContextCopyPath)
	// UPDATE 12/09: This function was made public from 10.6, so this is safe. Not yet documented though.
	
	CGPathRef cp = CGContextCopyPath( context );
	UIBezierPath* bp = [self bezierPathWithCGPathCustom:cp];
	CGPathRelease( cp );
	
	return bp;
}


#pragma mark -
- (CGPoint)				pointOnPathAtLength:(CGFloat) length slope:(CGFloat*) slope
{
	// Given a length in terms of the distance from the path start, this returns the point and slope
	// of the path at that position. This works for any path made up of line or curve segments or combinations of them. This should be used with
	// paths that have no subpaths. If the path has less than two elements, the result is CGPointZero.
	
	CGPoint					p = CGPointZero;
	CGPoint					ap[3], lp[3];
	CGPathElement		pre, elem;
	
	if ([self elementCount] < 2 )
		return p;
	
	if ( length <= 0.0 )
	{
		[self elementAtIndex:0 associatedPoints:ap];
		p = ap[0];
		
		[self elementAtIndex:1 associatedPoints:lp];
		
		if ( slope )
			*slope = Slope( ap[0], lp[0] );
	}
	else
	{
		UIBezierPath* temp = [self bezierPathByTrimmingToLength:length];
		
		// given the trimmed path, the desired point is at the end of the path.
		
		NSInteger			ec = [temp elementCount];
		CGFloat		slp = 1;
		
		if ( ec > 1 )
		{
			elem = [temp elementAtIndex:ec - 1 associatedPoints:ap];
			pre = [temp elementAtIndex:ec - 2 associatedPoints:lp];
			
			if ( pre.type == kCGPathElementAddCurveToPoint )
				lp[0] = lp[2];
			
			if ( elem.type == kCGPathElementAddCurveToPoint )
			{
				slp = Slope( ap[1], ap[2] );
				p = ap[2];
			}
			else
			{
				slp = Slope( lp[0], ap[0] );
				p = ap[0];
			}
		}

		if ( slope )
			*slope = slp;
	}
	return p;
}


- (CGFloat)				slopeStartingPath
{
	// returns the slope starting the path
	
	if ([self elementCount] > 1)
	{
		CGPoint	ap[3], lp[3];

		[self elementAtIndex:0 associatedPoints:ap];
		[self elementAtIndex:1 associatedPoints:lp];
		
		return Slope( ap[0], lp[0] );
	}
	else
		return 0;
}


- (CGFloat)				distanceFromStartOfPathAtPoint:(CGPoint) p tolerance:(CGFloat) tol
{
#if USE_OMNI_METHODS
	NSInteger seg;
	CGFloat t;
	
	seg = [self _segmentHitByPoint:p position:&t padding:tol];
	
	if ( seg > 0 )
	{
		//NSLog(@"seg = %d, t = %f", seg, t );
		
		return [self lengthToSegment:seg parameter:t totalLength:NULL];
	}
	else
		return -1.0;

#else
	// find the distance along the path where the point <p> is
	CGPoint	np;
	CGFloat	t;
	NSInteger		elem = [self elementHitByPoint:p tolerance:tol tValue:&t nearestPoint:&np];
	
	//NSLog(@"elem = %d, t = %f, nearest = %@", elem, t, NSStringFromPoint( np ));
	
	if( elem < 1 )
		return -1.0;	// not close enough
	else
	{
		// get length up to the split element
		
		CGFloat distance = [self lengthOfPathFromElement:0 toElement:elem - 1];
		
		// now split the final element and add its length
		
		CGPoint				ap[4];
		CGPathElement et = [self elementAtIndex:elem associatedPoints:&ap[1]];
		
		CGPoint				pp[3];
		CGPathElement pt = [self elementAtIndex:elem - 1 associatedPoints:pp];
		
		if ( pt.type == kCGPathElementAddCurveToPoint )
			ap[0] = pp[2];
		else
			ap[0] = pp[0];
			
		if( et.type == kCGPathElementAddCurveToPoint )
		{
			CGPoint left[4], right[4];
			subdivideBezierAtT( ap, left, right, t );
			
			CGFloat bd = lengthOfBezier( left, 0.1 );
			distance += bd;
		}
		else if ( et.type == kCGPathElementAddLineToPoint )
		{
			CGPoint ip = Interpolate( ap[0], ap[1],  t );
			distance += distanceBetween( ip, ap[0] );
		}
		
		return distance;
	}
#endif
}


- (NSInteger)					pointWithinPathRegion:(CGPoint) p
{
	// given a point p, returns 0, -1 or + 1 to indicate whether the point lies within a region defined by the path. For closed paths, this returns 0 for a point inside, -1 for a point
	// outside the path. If open, the path is treated as a straight line between its end points, and the point tested to see if it lies in the line segment.
	
	if([self isPathClosed])
		return [self containsPoint:p]? 0 : -1;
	else
	{
		CGPoint a, b;
		
		a = [self firstPoint];
		b = [self lastPoint];
		
		return PointInLineSegment( p, a, b );
	}
}

#pragma mark -
#pragma mark - clipping utilities
- (void)				addInverseClip
{
	// this is similar to -addClip, except that it excludes the area bounded by the path instead of includes it. It works by combining this path
	// with the existing clip area using the E/O winding rule, then setting the result as the clip area. This should be called between
	// calls to save and restore the gstate, as for addClip.
	
	CGContextRef	context = UIGraphicsGetCurrentContext();
	CGRect cbbox = CGContextGetClipBoundingBox( context );
	
	UIBezierPath*	cp = [UIBezierPath bezierPathWithRect:*(CGRect*)&cbbox];
	[cp appendPath:self];
    [cp setUsesEvenOddFillRule:NO];
	[cp addClip];
}


#pragma mark -

static void ConvertPathApplierFunction ( void* info, const CGPathElement* element )
{
	UIBezierPath* np = (UIBezierPath*) info;
	
	switch( element->type )
	{
		case kCGPathElementMoveToPoint:
			[np moveToPoint:*(CGPoint*) element->points];
			break;
		
		case kCGPathElementAddLineToPoint:
			[np addLineToPoint:*(CGPoint*) element->points];
			break;
		
		case kCGPathElementAddQuadCurveToPoint:
            [np addCurveToPoint:*(CGPoint*) &element->points[1] controlPoint1:*(CGPoint*) &element->points[0] controlPoint2:*(CGPoint*) &element->points[0]];
			break;
		
		case kCGPathElementAddCurveToPoint:
			[np addCurveToPoint:*(CGPoint*) &element->points[2] controlPoint1:*(CGPoint*) &element->points[0] controlPoint2:*(CGPoint*) &element->points[1]];
			break;
			
		case kCGPathElementCloseSubpath:
			[np closePath];
			break;
			
		default:
			break;
	}
}


#pragma mark -


inline static void subdivideBezier(const CGPoint bez[4], CGPoint bez1[4], CGPoint bez2[4])
{
  CGPoint q;
  
  bez1[0].x = bez[0].x;
  bez1[0].y = bez[0].y;
  bez2[3].x = bez[3].x;
  bez2[3].y = bez[3].y;
  
  q.x = (bez[1].x + bez[2].x) / 2.0;
  q.y = (bez[1].y + bez[2].y) / 2.0;
  bez1[1].x = (bez[0].x + bez[1].x) / 2.0;
  bez1[1].y = (bez[0].y + bez[1].y) / 2.0;
  bez2[2].x = (bez[2].x + bez[3].x) / 2.0;
  bez2[2].y = (bez[2].y + bez[3].y) / 2.0;
  
  bez1[2].x = (bez1[1].x + q.x) / 2.0;
  bez1[2].y = (bez1[1].y + q.y) / 2.0;
  bez2[1].x = (q.x + bez2[2].x) / 2.0;
  bez2[1].y = (q.y + bez2[2].y) / 2.0;
  
  bez1[3].x = bez2[0].x = (bez1[2].x + bez2[1].x) / 2.0;
  bez1[3].y = bez2[0].y = (bez1[2].y + bez2[1].y) / 2.0;
}

inline void subdivideBezierAtT(const CGPoint bez[4], CGPoint bez1[4], CGPoint bez2[4], CGFloat t)
{
  CGPoint q;
  CGFloat mt = 1 - t;
  
  bez1[0].x = bez[0].x;
  bez1[0].y = bez[0].y;
  bez2[3].x = bez[3].x;
  bez2[3].y = bez[3].y;
  
  q.x = mt * bez[1].x + t * bez[2].x;
  q.y = mt * bez[1].y + t * bez[2].y;
  bez1[1].x = mt * bez[0].x + t * bez[1].x;
  bez1[1].y = mt * bez[0].y + t * bez[1].y;
  bez2[2].x = mt * bez[2].x + t * bez[3].x;
  bez2[2].y = mt * bez[2].y + t * bez[3].y;
  
  bez1[2].x = mt * bez1[1].x + t * q.x;
  bez1[2].y = mt * bez1[1].y + t * q.y;
  bez2[1].x = mt * q.x + t * bez2[2].x;
  bez2[1].y = mt * q.y + t * bez2[2].y;
  
  bez1[3].x = bez2[0].x = mt * bez1[2].x + t * bez2[1].x;
  bez1[3].y = bez2[0].y = mt * bez1[2].y + t * bez2[1].y;
}

// Distance between two points
static inline CGFloat distanceBetween(CGPoint a, CGPoint b)
{
   return hypotf( a.x - b.x, a.y - b.y );
}

// Length of a curve
static CGFloat lengthOfBezier(const  CGPoint bez[4],
			     CGFloat acceptableError)
{
  CGFloat   polyLen = 0.0;
  CGFloat   chordLen = distanceBetween (bez[0], bez[3]);
  CGFloat   retLen, errLen;
  NSUInteger n;
  
  for (n = 0; n < 3; ++n)
    polyLen += distanceBetween (bez[n], bez[n + 1]);
  
  errLen = polyLen - chordLen;
  
  if (errLen > acceptableError) {
    CGPoint left[4], right[4];
    subdivideBezier (bez, left, right);
    retLen = (lengthOfBezier (left, acceptableError) 
	      + lengthOfBezier (right, acceptableError));
  } else {
    retLen = 0.5 * (polyLen + chordLen);
  }
  
  return retLen;
}

// Split a curve at a specific length
static CGFloat subdivideBezierAtLength (const CGPoint bez[4],
				       CGPoint bez1[4],
				       CGPoint bez2[4],
				       CGFloat length,
				       CGFloat acceptableError)
{
  CGFloat top = 1.0, bottom = 0.0;
  CGFloat t, prevT;
  
  prevT = t = 0.5;
  for (;;) {
    CGFloat len1;
    
    subdivideBezierAtT (bez, bez1, bez2, t);
    
    len1 = lengthOfBezier (bez1, 0.5 * acceptableError);
    
    if (fabs (length - len1) < acceptableError)
      return len1;
    
    if (length > len1) {
      bottom = t;
      t = 0.5 * (t + top);
    } else if (length < len1) {
      top = t;
      t = 0.5 * (bottom + t);
    }
    
    if (t == prevT)
      return len1;
    
    prevT = t;
  }
}

#pragma mark -
#pragma mark Path trimming utilities

// Find the first point in the path

- (CGPoint)			firstPoint
{
	CGPoint points[3];
	
	if ([self elementCount] > 0 )
	{
		CGPathElement element = [self elementAtIndex:0 associatedPoints:points];

		if (element.type == kCGPathElementAddCurveToPoint)
			return points[2];
		else
			return points[0];
	}
	else
		return CGPointZero;
}

- (CGPoint)			lastPoint
{
	CGPoint points[3];
	if ([self elementCount] > 0 )
	{
		CGPathElement element = [self elementAtIndex:[self elementCount] - 1 associatedPoints:points];

		if ( element.type == kCGPathElementAddCurveToPoint )
			return points[2];
		else
			return points[0];
	}
	else
		return CGPointZero;
}


- (CGFloat)				lengthOfElement:(NSInteger) i
{
	if ( i < 0 || i >= [self elementCount])
		return -1.0;
		
	if( i == 0 )
		return 0.0;
	else
	{
		CGPoint				ap[4];
		CGPathElement element = [self elementAtIndex:i associatedPoints:&ap[1]];
	
		CGPoint				pp[3];
		CGPathElement prev = [self elementAtIndex:i - 1 associatedPoints:pp];
	
		if( prev.type == kCGPathElementAddCurveToPoint )
			ap[0] = pp[2];
		else
			ap[0] = pp[0];
			
		if ( element.type == kCGPathElementAddCurveToPoint )
			return lengthOfBezier( ap, 0.1 );
		else if ( element.type == kCGPathElementAddLineToPoint )
			return distanceBetween( ap[1], ap[0] );
		else if ( element.type == kCGPathElementCloseSubpath )
		{
			[self elementAtIndex:0 associatedPoints:pp];
			return distanceBetween( pp[0], ap[0]);
		}
		else
			return 0.0;
	}
}


- (CGFloat)				lengthOfPathFromElement:(NSInteger) startElement toElement:(NSInteger) endElement
{
	NSInteger			i;
	CGFloat		d = 0.0;
	
	if( startElement < 0 )
		startElement = 0;
	
	if( endElement >= [self elementCount])
		endElement = [self elementCount] - 1;
	
	for( i = startElement; i <= endElement; ++i )
		d += [self lengthOfElement:i];
		
	return d;
}



#pragma mark -

#define DEFAULT_TRIM_EPSILON		0.1

// Convenience method

- (UIBezierPath *)	bezierPathByTrimmingToLength:(CGFloat)trimLength
{
	return [self bezierPathByTrimmingToLength:trimLength withMaximumError:DEFAULT_TRIM_EPSILON];
}


/* Return an UIBezierPath corresponding to the first trimLength units
   of this UIBezierPath. */
- (UIBezierPath *)	bezierPathByTrimmingToLength:(CGFloat)trimLength withMaximumError:(CGFloat) maxError
{
	if( trimLength >= [self length])
		return self;
	
	UIBezierPath *newPath = [UIBezierPath bezierPath];
	NSInteger	       elements = [self elementCount];
	NSInteger	       n;
	CGFloat     length = 0.0;
	CGPoint    pointForClose = CGPointMake (0.0, 0.0);
	CGPoint    lastPoint = CGPointMake (0.0, 0.0);

	for (n = 0; n < elements; ++n)
	{
		CGPoint		points[3];
		CGPathElement element = [self elementAtIndex:n associatedPoints:points];
		CGFloat		elementLength;
		CGFloat		remainingLength = trimLength - length;
    
		switch (element.type)
		{
			case kCGPathElementMoveToPoint:
				[newPath moveToPoint:points[0]];
				pointForClose = lastPoint = points[0];
				continue;
	
			case kCGPathElementAddLineToPoint:
				elementLength = distanceBetween (lastPoint, points[0]);
	
				if (length + elementLength <= trimLength)
					[newPath addLineToPoint:points[0]];
				else
				{
					CGFloat f = remainingLength / elementLength;
					[newPath addLineToPoint:CGPointMake (lastPoint.x + f * (points[0].x - lastPoint.x), lastPoint.y + f * (points[0].y - lastPoint.y))];
					return newPath;
				}
	
				length += elementLength;
				lastPoint = points[0];
				break;
	
			case kCGPathElementAddCurveToPoint:
			{
				CGPoint bezier[4] = { lastPoint, points[0], points[1], points[2] };
				elementLength = lengthOfBezier (bezier, maxError);
	
				if (length + elementLength <= trimLength)
					[newPath addCurveToPoint:points[2] controlPoint1:points[0] controlPoint2:points[1]];
				else
				{
					CGPoint bez1[4], bez2[4];
					subdivideBezierAtLength (bezier, bez1, bez2, remainingLength, maxError);
					[newPath addCurveToPoint:bez1[3] controlPoint1:bez1[1] controlPoint2:bez1[2]];
					return newPath;
				}
	
				length += elementLength;
				lastPoint = points[2];
				break;
			}
	
			case kCGPathElementCloseSubpath:
				elementLength = distanceBetween (lastPoint, pointForClose);
	
				if (length + elementLength <= trimLength)
				{
					[newPath closePath];
				}
				else
				{
					CGFloat f = remainingLength / elementLength;
					[newPath addLineToPoint:CGPointMake (lastPoint.x + f * (pointForClose.x - lastPoint.x), lastPoint.y + f * (pointForClose.y - lastPoint.y))];
					return newPath;
				}
	
				length += elementLength;
				lastPoint = pointForClose;
				break;
				
			default:
				break;
		}
	} 
	return newPath;
}



// Convenience method
- (UIBezierPath *)	bezierPathByTrimmingFromLength:(CGFloat) trimLength
{
	return [self bezierPathByTrimmingFromLength:trimLength withMaximumError:DEFAULT_TRIM_EPSILON];
}


/* Return an UIBezierPath corresponding to the part *after* the first
   trimLength units of this UIBezierPath. */
- (UIBezierPath *)	bezierPathByTrimmingFromLength:(CGFloat)trimLength withMaximumError:(CGFloat)maxError
{
	if( trimLength <= 0 )
		return self;
	
	UIBezierPath *newPath = [UIBezierPath bezierPath];
	NSInteger	       elements = [self elementCount];
	NSInteger	       n;
	CGFloat       length = 0.0;
	CGPoint      pointForClose = CGPointMake (0.0, 0.0);
	CGPoint      lastPoint = CGPointMake (0.0, 0.0);
  
	for (n = 0; n < elements; ++n)
	{
		CGPoint		points[3];
		CGPathElement element = [self elementAtIndex:n associatedPoints:points];
		CGFloat		elementLength;
		CGFloat		remainingLength = trimLength - length;
    
		switch (element)
		{
			case kCGPathElementMoveToPoint:
				if ( length > trimLength )
					[newPath moveToPoint:points[0]];
				pointForClose = lastPoint = points[0];
				continue;
	
			case kCGPathElementAddLineToPoint:
				elementLength = distanceBetween (lastPoint, points[0]);
	
				if (length > trimLength)
					[newPath addLineToPoint:points[0]];
				else if (length + elementLength > trimLength)
				{
					CGFloat f = remainingLength / elementLength;
					[newPath moveToPoint:CGPointMake (lastPoint.x + f * (points[0].x - lastPoint.x), lastPoint.y + f * (points[0].y - lastPoint.y))];
					[newPath addLineToPoint:points[0]];
				}
	  
				length += elementLength;
				lastPoint = points[0];
				break;
	
			case kCGPathElementAddCurveToPoint:
			{
				CGPoint bezier[4] = { lastPoint, points[0], points[1], points[2] };
				elementLength = lengthOfBezier (bezier, maxError);
	
				if (length > trimLength)
					[newPath addCurveToPoint:points[2] controlPoint1:points[0] controlPoint2:points[1]];
				else if (length + elementLength > trimLength)
				{
					CGPoint bez1[4], bez2[4];
					subdivideBezierAtLength (bezier, bez1, bez2, remainingLength, maxError);
					[newPath moveToPoint:bez2[0]];
					[newPath addCurveToPoint:bez2[3] controlPoint1:bez2[1] controlPoint2:bez2[2]];
				}
	
				length += elementLength;
				lastPoint = points[2];
				break;
			}
	
			case kCGPathElementCloseSubpath:
				elementLength = distanceBetween (lastPoint, pointForClose);
	
				if (length > trimLength)
				{
					[newPath addLineToPoint:pointForClose];
					[newPath closePath];
				}
				else if (length + elementLength > trimLength)
				{
					CGFloat f = remainingLength / elementLength;
					[newPath moveToPoint:CGPointMake (lastPoint.x + f * (points[0].x - lastPoint.x), lastPoint.y + f * (points[0].y - lastPoint.y))];
					[newPath addLineToPoint:points[0]];
				}
	  
				length += elementLength;
				lastPoint = pointForClose;
				break;
				
			default:
				break;
		}
	} 
	return newPath;
}



- (UIBezierPath*)		bezierPathByTrimmingFromBothEnds:(CGFloat) trimLength
{
	return [self bezierPathByTrimmingFromBothEnds:trimLength withMaximumError:DEFAULT_TRIM_EPSILON];
}


- (UIBezierPath *)		bezierPathByTrimmingFromBothEnds:(CGFloat) trimLength withMaximumError:(CGFloat) maxError
{
	// trims <trimLength> from both ends of the path, returning the shortened centre section
	
	CGFloat rlen = [self length] - (trimLength * 2.0);
	return [self bezierPathByTrimmingFromLength:trimLength toLength:rlen withMaximumError:maxError];
}


- (UIBezierPath*)		bezierPathByTrimmingFromCentre:(CGFloat) trimLength
{
	return [self bezierPathByTrimmingFromCentre:trimLength withMaximumError:DEFAULT_TRIM_EPSILON];
}


- (UIBezierPath*)		bezierPathByTrimmingFromCentre:(CGFloat) trimLength withMaximumError:(CGFloat) maxError
{
	// removes a section <trimLength> long from the centre of the path. The returned path thus consists of two
	// subpaths with a gap between them.
	
	CGFloat centre = [self length] * 0.5f;
	
	UIBezierPath* temp1 = [self bezierPathByTrimmingToLength:centre - (trimLength * 0.5f) withMaximumError:maxError];
	UIBezierPath* temp2 = [self bezierPathByTrimmingFromLength:centre + (trimLength * 0.5f) withMaximumError:maxError];
	
	[temp1 appendPath:temp2];
	
	return temp1;
}


- (UIBezierPath*)		bezierPathByTrimmingFromLength:(CGFloat) startLength toLength:(CGFloat) newLength
{
	return [self bezierPathByTrimmingFromLength:startLength toLength:newLength withMaximumError:DEFAULT_TRIM_EPSILON];
}


- (UIBezierPath*)		bezierPathByTrimmingFromLength:(CGFloat) startLength toLength:(CGFloat) newLength withMaximumError:(CGFloat) maxError
{
	// returns a new path which is <newLength> long, starting at <startLength> on the receiver's path. If <newLength> exceeds the available length, the
	// remainder of the path is returned. If <startLength> exceeds the length, returns nil.
	
	UIBezierPath* temp = [self bezierPathByTrimmingFromLength:startLength withMaximumError:maxError];
	return [temp bezierPathByTrimmingToLength:newLength withMaximumError:maxError];	
}


#pragma mark -
#pragma mark Arrow head utilities

// Create an UIBezierPath containing an arrowhead for the start of this path


- (UIBezierPath *)	bezierPathWithArrowHeadForStartOfLength:(CGFloat) length angle:(CGFloat) angle closingPath:(BOOL) closeit
{
	UIBezierPath *rightSide = [self bezierPathByTrimmingToLength:length];
	UIBezierPath *leftSide = [rightSide bezierPathByReversingPath];
	NSAffineTransform *rightTransform = [NSAffineTransform transform];
	NSAffineTransform *leftTransform = [NSAffineTransform transform];
	CGPoint firstPoint = [self firstPoint];
	//CGPoint fp2 = [self firstPoint2:length / 2.0];
	// Rotate about the point of the arrowhead
	[rightTransform translateXBy:firstPoint.x yBy:firstPoint.y];
	[rightTransform rotateByDegrees:angle];
	[rightTransform translateXBy:-firstPoint.x yBy:-firstPoint.y];
  
	[rightSide transformUsingAffineTransform:rightTransform];
  
	// Same again, but for the left hand side of the arrowhead
	[leftTransform translateXBy:firstPoint.x yBy:firstPoint.y];
	[leftTransform rotateByDegrees:-angle];
	[leftTransform translateXBy:-firstPoint.x yBy:-firstPoint.y];
  
	[leftSide transformUsingAffineTransform:leftTransform];
  
	/* Careful!  We don't want to append the -moveToPoint from the right hand
     side, because then -closePath won't do what we would want it to. */
	[leftSide appendPathRemovingInitialMoveToPoint:rightSide];
	
	if ( closeit )
		[leftSide closePath];
  
	return leftSide;
}

// Convenience function for obtaining arrow for the other end
- (UIBezierPath *)	bezierPathWithArrowHeadForEndOfLength:(CGFloat) length  angle:(CGFloat) angle closingPath:(BOOL) closeit
{
	return [[self bezierPathByReversingPath] bezierPathWithArrowHeadForStartOfLength:length angle:angle closingPath:closeit];
}


#pragma mark -
/* Append a Bezier path, but if it starts with a -moveToPoint, then remove
   it.  This is useful when manipulating trimmed path segments. */

- (void)			appendPathRemovingInitialMoveToPoint:(UIBezierPath*) path
{
	NSInteger	       elements = [path elementCount];
	NSInteger	       n;
  
	for (n = 0; n < elements; ++n)
	{
		CGPoint		points[3];
		CGPathElement element = [path elementAtIndex:n associatedPoints:points];

		switch (element.type)
		{
			case kCGPathElementMoveToPoint:
			{
				if (n != 0)
					[self moveToPoint:points[0]];
				break;
			}
	
			case kCGPathElementAddLineToPoint:
				[self addLineToPoint:points[0]];
			break;
	
			case kCGPathElementAddCurveToPoint:
				[self addCurveToPoint:points[2] controlPoint1:points[0] controlPoint2:points[1]];
			break;
	
			case kCGPathElementCloseSubpath:
				[self closePath];
				
			default:
				break;
		}
	}
}


#pragma mark -
// Convenience method

- (CGFloat)			length
{
	return [self lengthWithMaximumError:DEFAULT_TRIM_EPSILON];
}

// Estimate the total length of a bezier path

- (CGFloat)			lengthWithMaximumError:(CGFloat) maxError
{
  NSInteger     elements = [self elementCount];
  NSInteger     n;
  CGFloat  length = 0.0;
  CGPoint pointForClose = CGPointMake (0.0, 0.0);
  CGPoint lastPoint = CGPointMake (0.0, 0.0);
  
  for (n = 0; n < elements; ++n)
  {
		CGPoint		points[3];
		CGPathElement element = [self elementAtIndex:n associatedPoints:points];
    
		switch (element.type)
		{
			case kCGPathElementMoveToPoint:
				pointForClose = lastPoint = points[0];
				break;
	
			case kCGPathElementAddLineToPoint:
				length += distanceBetween (lastPoint, points[0]);
				lastPoint = points[0];
				break;
	
			case kCGPathElementAddCurveToPoint:
			{
				CGPoint bezier[4] = { lastPoint, points[0], points[1], points[2] };
				length += lengthOfBezier (bezier, maxError);
				lastPoint = points[2];
				break;
			}
	
			case kCGPathElementCloseSubpath:
				length += distanceBetween (lastPoint, pointForClose);
				lastPoint = pointForClose;
				break;
				
			default:
				break;
		}
  }
  
  return length;
}


@end


