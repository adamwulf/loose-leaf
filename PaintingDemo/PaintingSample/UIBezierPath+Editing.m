///**********************************************************************************************************************************
///  UIBezierPath-Editing.m
///  DrawKit ©2005-2008 Apptree.net
///
///  Created by graham on 08/10/2006.
///
///	 This software is released subject to licensing conditions as detailed in DRAWKIT-LICENSING.TXT, which must accompany this source file. 
///
///**********************************************************************************************************************************

#import "UIBezierPath+Editing.h"

#import "UIBezierPath+Geometry.h"
#import "DKGeometryUtilities.h"
#import "UIBezierPath+NSOSX.h"

#define USE_OMNI_METHODS	0

#if USE_OMNI_METHODS
#import "UIBezierPath-OAExtensions.h"
#endif


#pragma mark Static Vars
static CGFloat sAngleConstraint = 0.261799387799;	// 15¡



// simple partcode cracking utils:

static inline NSInteger		arrayIndexForPartcode( const NSInteger pc );
static inline NSInteger		elementIndexForPartcode( const NSInteger pc );


#pragma mark -
@implementation UIBezierPath (DKEditing)
#pragma mark As an UIBezierPath

+ (void)				setConstraintAngle:(CGFloat) radians
{
	sAngleConstraint = radians;
}


+ (CGPoint)		colinearPointForPoint:(CGPoint) p centrePoint:(CGPoint) q
{
	// returns the point opposite p from q in a straight line. The point p has the same radius as p-q.

	CGFloat dx, dy;
	
	dx = p.x - q.x;
	dy = p.y - q.y;
	
	return CGPointMake( q.x - dx, q.y - dy );
}


+ (CGPoint)		colinearPointForPoint:(CGPoint) p centrePoint:(CGPoint) q radius:(CGFloat) r
{
	// returns the point opposite p from q at radius r in a straight line.
	
	CGFloat	a = atan2f( p.y - q.y, p.x - q.x ) + M_PI;
	return CGPointMake( q.x + ( r * cos( a )), q.y + ( r * sin( a )));
}


+ (NSInteger)			point:(CGPoint) p inCGPointArray:(CGPoint*) array count:(NSInteger) count tolerance:(CGFloat) t
{
	return [self point:p inCGPointArray:array count:count tolerance:t reverse:NO];
}


+ (NSInteger)			point:(CGPoint) p inCGPointArray:(CGPoint*) array count:(NSInteger) count tolerance:(CGFloat) t reverse:(BOOL) reverse
{
	// test the point <p> against a list of points <array>,<count> using the tolerance <t>. Returns the index of
	// the point in the array "hit" by p, or NSNotFound if not hit.
	
	NSInteger	i;
	CGRect		r;
	
	r.size = CGSizeMake( t, t );
	
	if( reverse )
	{
		for( i = count; i > 0; --i )
		{
			r.origin = array[i - 1];
			r.origin.x -= ( 0.5 * t );
			r.origin.y -= ( 0.5 * t );
			
			if ( CGRectContainsPoint(r, p) )
				return i - 1;
		}
	}
	else
	{
		for( i = 0; i < count; ++i )
		{
			r.origin = array[i];
			r.origin.x -= ( 0.5 * t );
			r.origin.y -= ( 0.5 * t );
			
			if ( CGRectContainsPoint( r, p ))
				return i;
		}
	}
	return NSNotFound;
}


+ (void)				colineariseVertex:(CGPoint[3]) inPoints cpA:(CGPoint*) outCPA cpB:(CGPoint*) outCPB
{
	// given three points passed in as an array, this modifies the two outer points to lie in a straight line through the middle
	// point. The resulting slope of this line is normal to the bisection of the angle formed by the original points. The radius
	// of the points relative to the centre remains the same
	
	CGFloat r1 = hypot( inPoints[0].x - inPoints[1].x, inPoints[0].y - inPoints[1].y );
	CGFloat r2 = hypot( inPoints[2].x - inPoints[1].x, inPoints[2].y - inPoints[1].y );

	// find angle ABC and bisect it

	CGFloat angle = ( Slope( inPoints[1], inPoints[2] ) + Slope( inPoints[0], inPoints[1] )) / 2.0f;
	
	if ( outCPA )
	{
		outCPA->x = inPoints[1].x + r1 * cos( angle + M_PI );
		outCPA->y = inPoints[1].y + r1 * sin( angle + M_PI );
	}
	
	if( outCPB )
	{
		outCPB->x = inPoints[1].x - r2 * cos( angle + M_PI );
		outCPB->y = inPoints[1].y - r2 * sin( angle + M_PI );
	}
}


#pragma mark -
- (UIBezierPath*)		bezierPathByRemovingTrailingElements:(NSInteger) numToRemove
{
	// returns a copy with the last <n> elements removed.

	UIBezierPath* newPath = [self copy];
	
	if( ![self isEmpty])
	{
		NSInteger						i, count = [self elementCount];
		CGPoint					ap[3];
		CGPathElement		kind;
		
		[newPath removeAllPoints];
		
		for( i = 0; i < ( count - numToRemove ); ++i )
		{
			kind = [self elementAtIndex:i associatedPoints:ap];
			
			switch( kind.type )
			{
				default:
				case kCGPathElementMoveToPoint:
					[newPath moveToPoint:ap[0]];
					break;
					
				case kCGPathElementAddLineToPoint:
					[newPath addLineToPoint:ap[0]];
					break;
					
				case kCGPathElementAddCurveToPoint:
                    [newPath addCurveToPoint:ap[2] controlPoint1:ap[0] controlPoint2:ap[1]];
					break;
					
				case kCGPathElementCloseSubpath:
					[newPath closePath];
					break;
			}
		}
	}
	
	return [newPath autorelease];
}


- (UIBezierPath*)		bezierPathByStrippingRedundantElements
{
	// returns a new path which is a copy of the receiver but with all redundant elements stripped out. A redundant element is
	// one that doesn't contribute to the shape's appearance - zero-length lines or curves, and isolated trailing movetos. By
	// stripping these elements, editing a path becomes much easier because all the special cases for the redundant elements can be
	// simply avoided.
	
	UIBezierPath* newPath = [self copy];
	
	if( ![self isEmpty])
	{
		NSInteger						i, count = [self elementCount];
		CGPoint					ap[3];
		CGPoint					pp;
		CGPathElement		kind;
		
		pp = CGPointMake( -1, -1 );
		
		[newPath removeAllPoints];
		
		for( i = 0; i < count; ++i )
		{
			kind = [self elementAtIndex:i associatedPoints:ap];
			
			switch( kind.type )
			{
				default:
				case kCGPathElementMoveToPoint:
					// redundant if this is the last element
					
					if ( i < ( count - 1 ))
						[newPath moveToPoint:ap[0]];
					pp = ap[0];
					break;
					
				case kCGPathElementAddLineToPoint:
					// redundant if its length is zero
					
					if ( !CGPointEqualToPoint( ap[0], pp ))
						[newPath addLineToPoint:ap[0]];
						
					pp = ap[0];
					break;
					
				case kCGPathElementAddCurveToPoint:
					// redundant if its endpoint and control points are the same as the previous point
					
					if ( !( CGPointEqualToPoint( pp, ap[0]) && CGPointEqualToPoint( pp, ap[1]) && CGPointEqualToPoint( pp, ap[2])))
						[newPath addCurveToPoint:ap[2] controlPoint1:ap[0] controlPoint2:ap[1]];
					
					pp = ap[2];
					break;
					
				case kCGPathElementCloseSubpath:
					[newPath closePath];
					break;
			}
		}
	}
	
//	LogEvent_(kReactiveEvent,  @"original path = %@", self );
//	LogEvent_(kReactiveEvent,  @"stripped path = %@", newPath );
	
	return [newPath autorelease];
}


- (UIBezierPath*)		bezierPathByRemovingElementAtIndex:(NSInteger) indx
{
	// returns a new path that is a copy of the receiver except the element at <indx> has been deleted. If the element wasn't the last
	// element, the remainder of the path is now a subpaht with a new moveTo element in place of the end point of the removed element.
	// This is the elementary method used to delete a segment from a path. If <indx> is out of range, the receiver is returned unmodified.
	
	if( indx < 0 || indx >= [self elementCount])
		return self;
	
	NSInteger			i, m;
	CGPoint				firstPoint = CGPointZero, originalFirstPoint = CGPointZero;
	CGPoint				ap[3];
	UIBezierPath*		newPath = [UIBezierPath bezierPath];
	CGPathElement	element;
	BOOL				hasDeleted = NO;
	
	m = [self elementCount];
	
	for( i = 0; i < m; ++i )
	{
		element = [self elementAtIndex:i associatedPoints:ap];
		
		if( i == indx )
		{
			// this is the one to delete, so start a new subpath at its end point
			
			if( element.type == kCGPathElementAddCurveToPoint )
				firstPoint = ap[2];
			else if( element.type == kCGPathElementCloseSubpath )
			{
				// no-op
			}
			else
				firstPoint = ap[0];
			
			[newPath moveToPoint:firstPoint];
			hasDeleted = YES;
		}
		else
		{
			switch( element.type )
			{
				case kCGPathElementMoveToPoint:
					[newPath moveToPoint:ap[0]];
					firstPoint = originalFirstPoint = ap[0];
					break;
					
				case kCGPathElementAddLineToPoint:
					[newPath addLineToPoint:ap[0]];
					break;
					
				case kCGPathElementAddCurveToPoint:
					[newPath addCurveToPoint:ap[2] controlPoint1:ap[0] controlPoint2:ap[1]];
					break;
					
				case kCGPathElementCloseSubpath:
					// because a segment might have been deleted, so changing the point for closing a path, a line to the original first point must be
					// set instead.
					
					if( hasDeleted )
						[newPath addLineToPoint:originalFirstPoint];
					else
						[newPath closePath];
					break;
					
				default:
					break;
			}
		}
	}
	
	return newPath;
}



#pragma mark -
///*********************************************************************************************************************
///
/// method:			getPathMoveToCount:lineToCount:curveToCount:closePathCount:
/// scope:			instance method
/// extends:		UIBezierPath
/// description:	counts the number of elements of each type in the path
/// 
/// parameters:		<mtc, ltc, ctc, cpc> pointers to integers that receive the counts for each element type
/// result:			none
///
/// notes:			pass NULL for any values you are not interested in
///
///********************************************************************************************************************

- (void)				getPathMoveToCount:(NSInteger*) mtc lineToCount:(NSInteger*) ltc curveToCount:(NSInteger*) ctc closePathCount:(NSInteger*) cpc
{
	NSInteger i, ec = [self elementCount];
	NSInteger m, l, c, p;
	
	CGPathElement	elem;
	
	m = l = c = p = 0;
	
	for( i = 0; i < ec; ++i )
	{
		elem = [self elementAtIndex:i];
		
		switch( elem.type )
		{
			case kCGPathElementMoveToPoint:
				++m;
				break;
				
			case kCGPathElementAddLineToPoint:
				++l;
				break;
				
			case kCGPathElementAddCurveToPoint:
				++c;
				break;
				
			case kCGPathElementCloseSubpath:
				++p;
				break;
				
			default:
				break;
		}
	}
	
	if( mtc )
		*mtc = m;
	
	if( ltc )
		*ltc = l;
	
	if( ctc )
		*ctc = c;
	
	if( cpc )
		*cpc = p;
}


- (BOOL)				isPathClosed
{
	return [self subpathContainingElementIsClosed:0];
}


- (NSUInteger)			checksum
{
	// returns a value that may be considered unique for this path. Comparing a path's checksum with a previous value can be used to determine whether the path has changed.
	// Do not rely on the actual value returned, only whether it's the same as a previous value or another path. Do not archive or persist this value. Note that two paths
	// with identical contents will return the same value, which might be a useful trait.
	
	NSUInteger			cs = 157145267; // start with arbitrary number
	NSUInteger			ec = (NSUInteger)[self elementCount];
	CGPoint				p[3];
	NSInteger					i;
	CGPathElement	element;
	
	// munge with element count
	
	cs ^= ( ec << 5 );
	
	if( ![self isEmpty])
	{
		// munge all the internal points together
		
		for( i = 0; i < [self elementCount]; ++i )
		{
			p[1] = p[2] = CGPointZero;
			element = [self elementAtIndex:i associatedPoints:p];
			ec = ((NSUInteger) element.type << 10 ) ^ lround( p[0].x ) ^ lround( p[1].x ) ^ lround( p[2].x ) ^ lround( p[0].y ) ^ lround( p[1].y ) ^ lround( p[2].y );
			cs ^= ec;
		}
	}
	
	return cs;
}


#pragma mark -
- (BOOL)				subpathContainingElementIsClosed:(NSInteger) element
{
	// determines if the subpath containing the element is a closed loop. It returns YES under the following conditions:
	// a. there is a closepath command at or higher than element, OR
	// b. the endpoint of the last element is at the same location as the previous moveto.
	
	// a - look ahead for a closepath
	
	NSInteger			i, ec = [self elementCount];
	CGPathElement	et;

	for( i = element; i < ec; ++i )
	{
		et = [self elementAtIndex:i];
		
		if ( et.type == kCGPathElementCloseSubpath )
			return YES;
	}
	
	// b - look for start and end being the same
/*
	NSInteger	ee;
	CGPoint		p[3];
	CGPoint		endPoint;
	
	ee = [self subpathEndingElementForElement:element];
	et = [self elementAtIndex:ee associatedPoints:p];

	if ( et == kCGPathElementAddCurveToPoint )
		endPoint = p[2];
	else
		endPoint = p[0];
		
	i = [self subpathStartingElementForElement:element];
		
	if ( i != -1 )
	{
		[self elementAtIndex:i associatedPoints:p];
		return NSEqualPoints( p[0], endPoint );
	}
*/
	return NO;
}


- (NSInteger)					subpathStartingElementForElement:(NSInteger) element
{
	// finds the starting element for the subpath containing <element> This will always be a moveto element.
	
	CGPathElement	et;
	NSInteger					i;
	
	for( i = element; i >= 0; --i )
	{
		et = [self elementAtIndex:i];
	
		if ( et.type == kCGPathElementMoveToPoint )
			return i;
	}
	
	return -1;
}


- (NSInteger)					subpathEndingElementForElement:(NSInteger) element
{
	// finds the ending element for the subpath containing <element> This may be any type except a moveto.
	
	CGPathElement	et;
	NSInteger					i, ec = [self elementCount];
	
	et = [self elementAtIndex:element];
	
	if ( et.type == kCGPathElementMoveToPoint )
		++element;
	
	for( i = element; i < ec; ++i )
	{
		et = [self elementAtIndex:i];
	
		if ( et.type == kCGPathElementMoveToPoint )
			return i - 1;
	}
	
	return ec - 1;
}


#pragma mark -

/*
 a "partcode" is simply a unique identifier for one control point in the path. An element may have up to three partcodes
 if it is a curveto element, just one if it is any of the others. A path editor works using partcodes rather than element
 indexes because that is what it is manipulating - individual control points.
 
 partcodes are a very simple hash of the element index and the array index for the associated points. However, don't rely
 on its format - use the utility methods here to translate back and forth between partcodes and element/array indexes.
 
 partcodes are 1-based, so that a partcode of 0 can be used to mean "no hit" when hit testing.
 
*/

- (CGPathElement)	elementTypeForPartcode:(NSInteger) pc
{
	// returns the element type given a partcode
	
	return [self elementAtIndex:elementIndexForPartcode( pc )];
}


- (BOOL)				isOnPathPartcode:(NSInteger) pc
{
	// returns YES if the given partcode is NOT a bezier control point, but is a bezier or line segment end point.
	
	if ( pc > 3 )
	{
		CGPathElement element = [self elementTypeForPartcode:pc];
		
		if ( element.type == kCGPathElementAddCurveToPoint )
		{
			NSInteger indx = arrayIndexForPartcode( pc );
			return ( indx == 2 );
		}
		return YES;
	}
	
	return NO;
}



- (void)				setControlPoint:(CGPoint) p forPartcode:(NSInteger) pc
{
	CGPoint				ap[3];
	NSInteger			elem = elementIndexForPartcode( pc );
	
	[self elementAtIndex:elem associatedPoints:ap];
	ap[arrayIndexForPartcode( pc )] = p;
	
	[self setAssociatedPoints:ap atIndex:elem]; 
}


- (CGPoint)				controlPointForPartcode:(NSInteger) pc
{
	// given a partcode, this returns the current position of the associated control point
	
	CGPoint				ap[3];
	NSInteger			elem = elementIndexForPartcode( pc );
	
	[self elementAtIndex:elem associatedPoints:ap];
	
	return ap[ arrayIndexForPartcode( pc )];
}


#pragma mark -
- (NSInteger)					partcodeHitByPoint:(CGPoint) p tolerance:(CGFloat) t
{
	return [self partcodeHitByPoint:p tolerance:t startingFromElement:0];
}


- (NSInteger)					partcodeHitByPoint:(CGPoint) p tolerance:(CGFloat) t prioritiseOnPathPoints:(BOOL) onpPriority
{
	return [self partcodeHitByPoint:p tolerance:t startingFromElement:0 prioritiseOnPathPoints:onpPriority];
}


- (NSInteger)					partcodeHitByPoint:(CGPoint) p tolerance:(CGFloat) t startingFromElement:(NSInteger) startElement
{
	return [self partcodeHitByPoint:p tolerance:t startingFromElement:startElement prioritiseOnPathPoints:NO];
}


- (NSInteger)					partcodeHitByPoint:(CGPoint) p tolerance:(CGFloat) t startingFromElement:(NSInteger) startElement prioritiseOnPathPoints:(BOOL) onpPriority;
{
	// given a point <p>, this detects whether any of the control points in the path were hit. A hit has to
	// be within <t> of the point's position. Returns the partcode of the point hit, or 0 if not hit. If <onpPriority> is YES, on-path points
	// in a bezier segment take priority over off-path points, allowing coincident points to be detected as on-path raher than off-path points.
		
	CGFloat	thalf = 0.5 * t;
	CGRect	bb = [self controlPointBounds];
	
	// if point not in control point bounds, trivially discard it
	
	if ( ! CGRectContainsPoint(CGRectInset( bb, -thalf, -thalf ), p))
		return 0;
		
	// scan through looking for hits in any control point. The test order here looks for curve control points
	// in preference to on-path points so that if they lie at the same point, the cp is detected. This makes it
	// possible for the user to drag a cp away from an underlying on-path point. This behaviour is inverted if <onpPriority> is YES
	
	CGPathElement et, pet;
	CGPoint				ap[3], lp[3];
	
	NSInteger pc, i, ec = [self elementCount];
	
	for( i = startElement + 1; i < ec; ++i )
	{
		pet = [self elementAtIndex:i-1 associatedPoints:lp];
		et = [self elementAtIndex:i associatedPoints:ap];
		
		if ( et.type == kCGPathElementAddCurveToPoint )
		{
			if( onpPriority )
			{
				if ( pet.type == kCGPathElementAddCurveToPoint )
				{
					pc = [UIBezierPath point:p inCGPointArray:&lp[2] count:1 tolerance:t];
					if ( pc != NSNotFound )
						pc = 2;
				}
				else
					pc = [UIBezierPath point:p inCGPointArray:lp count:1 tolerance:t];
				
				if ( pc != NSNotFound )
					return partcodeForElementControlPoint( i-1, pc );

				pc = [UIBezierPath point:p inCGPointArray:ap count:3 tolerance:t reverse:YES];
				
				if ( pc != NSNotFound )
					return partcodeForElementControlPoint( i, pc );
			}
			else
			{
				// test 2 control points, 3 for last segment
				
				pc = [UIBezierPath point:p inCGPointArray:ap count:(i == ( ec-1 ))? 3 : 2 tolerance:t];
				
				if ( pc != NSNotFound )
					return partcodeForElementControlPoint( i, pc );
			}		
			
			// next test on-path point of previous segment:
			
			if ( pet.type == kCGPathElementAddCurveToPoint )
			{
				pc = [UIBezierPath point:p inCGPointArray:&lp[2] count:1 tolerance:t];
				if ( pc != NSNotFound )
					pc = 2;
			}
			else
				pc = [UIBezierPath point:p inCGPointArray:lp count:1 tolerance:t];
			
			if ( pc != NSNotFound )
				return partcodeForElementControlPoint( i-1, pc );
			

			// also test last segment if necessary
			
			if ( i == ec - 1 )
			{
				pc = [UIBezierPath point:p inCGPointArray:ap count:3 tolerance:t reverse:onpPriority];
			
				if ( pc != NSNotFound )
					return partcodeForElementControlPoint( i, pc );
			}
		}
		else
		{
			// one point to test, which is the end point of the previous segment
			
			if ( pet.type == kCGPathElementAddCurveToPoint )
			{
				pc = [UIBezierPath point:p inCGPointArray:&lp[2] count:1 tolerance:t];
				if ( pc != NSNotFound )
					pc = 2;
			}
			else
				pc = [UIBezierPath point:p inCGPointArray:lp count:1 tolerance:t];
			
			if ( pc != NSNotFound )
				return partcodeForElementControlPoint( i-1, pc );

			// also test last segment if necessary
			
			if ( i == ec - 1 )
			{
				pc = [UIBezierPath point:p inCGPointArray:ap count:1 tolerance:t];
			
				if ( pc != NSNotFound )
					return partcodeForElementControlPoint( i, pc );
			}
		}
	}
	
	return 0;
}


- (NSInteger)					partcodeForLastPoint
{
	NSInteger m = [self elementCount] - 1;
	CGPathElement element = [self elementAtIndex:m];
	
	if( element.type == kCGPathElementAddCurveToPoint )
		return partcodeForElementControlPoint( m, 2 );
	else
		return partcodeForElementControlPoint( m, 0 );
}


- (CGPoint)				referencePointForConstrainedPartcode:(NSInteger) pc
{
	// returns the current point to use as the 'centre' for an angular constraint of the given partcode. This is moderately complex because
	// of the different element types and the fact that the first point needs to look ahead, not behind.
	
	NSInteger			ec = [self elementCount];
	NSInteger			element = elementIndexForPartcode( pc );
	NSInteger			indx = arrayIndexForPartcode( pc );
	CGPoint				refPt;
	CGPoint				ap[3];
	
	CGPathElement et = [self elementAtIndex:element associatedPoints:ap];
	
	if( et.type == kCGPathElementAddCurveToPoint )
		refPt = ap[2];
	else
		refPt = ap[0];
	
	if( element == 0 && indx == 0 )
	{
		// first point - look ahead
		
		if( element + 1 < ec )
		{
			et = [self elementAtIndex:element + 1 associatedPoints:ap];
			
			if( et.type == kCGPathElementAddCurveToPoint )
				refPt = ap[2];
			else
				refPt = ap[0];
		}
	}
	else
	{
		// not first point, look behind
		
		if( indx == 0 || indx == 2 )
		{
			et = [self elementAtIndex:element - 1 associatedPoints:ap];
			
			if( et.type == kCGPathElementAddCurveToPoint )
				refPt = ap[2];
			else
				refPt = ap[0];
			
		}
		else
		{
			et = [self elementAtIndex:element associatedPoints:ap];
			
			if( et.type == kCGPathElementAddCurveToPoint )
				refPt = ap[2];
		}
	}
	
	return refPt;
}


#pragma mark -
- (void)				moveControlPointPartcode:(NSInteger) pc toPoint:(CGPoint) p colinear:(BOOL) colin coradial:(BOOL) corad constrainAngle:(BOOL) acon
{
	// high-level method for editing paths. This optionally maintains colinearity of control points across curve segment joins, and
	// deals with maintaining closed loops and dealing with the dangling moveto that closePath inserts.
	
	// the flags <colin> and <corad> affect the way related points for a curve segment are moved into alignment with this one:
	
	// colin NO				- this point is moved entirely independently
	// colin YES, corad NO	- opposite point stays in linear alignment with this point, but radius remains the same
	// colin YES, corad YES	- opposite point adjusted to be both colinear and coradial
	
	// if <acon> is YES and the point being moved is a curve control point, the angle relative to the on-path point is constrained using the
	// set constraint interval for the class
						
	CGPathElement et =		[self elementTypeForPartcode:pc];
	NSInteger			ec =		[self elementCount];
	NSInteger			element =	elementIndexForPartcode( pc );
	BOOL				closedLoop =[self subpathContainingElementIsClosed:element];
	CGPoint				old =		[self controlPointForPartcode:pc];
	
	CGFloat				dx, dy;
	CGPathElementType previous = kCGPathElementMoveToPoint;
	CGPathElementType following = kCGPathElementMoveToPoint;
	CGPoint				opp, centre;
	NSInteger			prev, next;
	static NSInteger	depth = 0;
	
	++depth;
	
	prev = MAX( 0, element - 1);
	next = element + 1;
	
	if ( element < ( ec - 1 ))
		following = [self elementAtIndex:next].type;
		
	if ( element > 0 )
		previous = [self elementAtIndex:prev].type;
	
	// refPt is the point that the moved point will be referenced to when constraints are applied.
	
	CGPoint refPt = [self referencePointForConstrainedPartcode:pc];
	
	if( acon )
	{
		// angular constraint affects the end point directly
		
		CGFloat pa = atan2( p.y - refPt.y, p.x - refPt.x );
		CGFloat pd = hypot( p.x - refPt.x, p.y - refPt.y );
		CGFloat rem = fmod( pa, sAngleConstraint );
		
		if ( rem > sAngleConstraint / 2.0 )
			pa += ( sAngleConstraint - rem );
		else
			pa -= rem;
		
		p.x = refPt.x + ( pd * cos( pa ));
		p.y = refPt.y + ( pd * sin( pa ));
	}
	
	// delta from old point for the current partcode
	
	dx = p.x - old.x;
	dy = p.y - old.y;
	
	if ( et.type == kCGPathElementAddCurveToPoint )
	{
		// this is a curve element. This means we could be affecting points in the previous OR the following elements,
		// but not both.
		
		NSInteger cp = arrayIndexForPartcode( pc );	// index of control point of curve, 0 1 or 2

		switch( cp )
		{
			case 0:		// control point 1
				if ( colin )
				{
					if ( previous == kCGPathElementAddCurveToPoint )
					{
						NSInteger prevPc = partcodeForElementControlPoint( prev, 1 );
						
						centre = [self controlPointForPartcode:partcodeForElementControlPoint( prev, 2 )];
						
						if ( corad )
							opp = [UIBezierPath colinearPointForPoint:p centrePoint:centre];
						else
						{
							CGPoint curOpp = [self controlPointForPartcode:prevPc];
							CGFloat rad = hypot( curOpp.x - centre.x, curOpp.y - centre.y );
						
							opp = [UIBezierPath colinearPointForPoint:p centrePoint:centre radius:rad];
						}
						
						[self setControlPoint:opp forPartcode:prevPc];
					}
					else if ( closedLoop && ( previous == kCGPathElementMoveToPoint ))
					{
						// the point being moved is cp2 of the last element in the loop, if it's a curve
						
						NSInteger le = [self subpathEndingElementForElement:element];
						previous = [self elementAtIndex:le].type;
						
						if ( previous == kCGPathElementAddCurveToPoint )
						{
							centre = [self controlPointForPartcode:partcodeForElement( prev )];
							NSInteger prevPc = partcodeForElementControlPoint( le, 1 );
							
							if ( corad )
								opp = [UIBezierPath colinearPointForPoint:p centrePoint:centre];
							else
							{
								CGPoint curOpp = [self controlPointForPartcode:prevPc];
								CGFloat rad = hypot( curOpp.x - centre.x, curOpp.y - centre.y );
						
								opp = [UIBezierPath colinearPointForPoint:p centrePoint:centre radius:rad];
							}
							
							[self setControlPoint:opp forPartcode:prevPc];
						}
					}
				}
				break;
				
			case 1:		// control point 2
				if ( colin )
				{
					if (( element < ( ec - 1 )) && ( following == kCGPathElementAddCurveToPoint ))
					{
						centre = [self controlPointForPartcode:partcodeForElementControlPoint( element, 2 )];
						
						if ( corad )
							opp = [UIBezierPath colinearPointForPoint:p centrePoint:centre];
						else
						{
							CGPoint curOpp = [self controlPointForPartcode:partcodeForElement( next )];
							CGFloat rad = hypot( curOpp.x - centre.x, curOpp.y - centre.y );
						
							opp = [UIBezierPath colinearPointForPoint:p centrePoint:centre radius:rad];
						}
						
						[self setControlPoint:opp forPartcode:partcodeForElement( next )];
					}
					else if ( closedLoop && ( element == [self subpathEndingElementForElement:element]))
					{
						// cross-couple to second element control point if it's a curve
						
						NSInteger e2 = [self subpathStartingElementForElement:element] + 1;
						
						following = [self elementAtIndex:e2].type;
						if ( following == kCGPathElementAddCurveToPoint )
						{
							centre = [self controlPointForPartcode:partcodeForElementControlPoint( element, 2 )];
							
							if ( corad )
								opp = [UIBezierPath colinearPointForPoint:p centrePoint:centre];
							else
							{
								CGPoint curOpp = [self controlPointForPartcode:partcodeForElement( e2 )];
								CGFloat rad = hypot( curOpp.x - centre.x, curOpp.y - centre.y );
						
								opp = [UIBezierPath colinearPointForPoint:p centrePoint:centre radius:rad];
							}
							
							[self setControlPoint:opp forPartcode:partcodeForElement( e2 )];
						}
					}
				}
				break;
				
			case 2:		// end point - moves all three linked points by delta. This doesn't force the points to become colinear
			{
				if (( element < ( ec - 1 )) && ( following == kCGPathElementAddCurveToPoint ))
				{
					opp = [self controlPointForPartcode:partcodeForElement( next )];
					
					opp.x += dx;
					opp.y += dy;
					
					[self setControlPoint:opp forPartcode:partcodeForElement( next )];
				}
				opp = [self controlPointForPartcode:partcodeForElementControlPoint( element, 1 )];
				opp.x += dx;
				opp.y += dy;
				[self setControlPoint:opp forPartcode:partcodeForElementControlPoint( element, 1 )];
			}
			break;
			
			default:
				break;
		}
		
		[self setControlPoint:p forPartcode:pc];
	 }
	 else if ( et.type != kCGPathElementCloseSubpath )
	 {
		// this is a single point element of some kind but not a closepath. If the element is followed by a
		// curve, offset its first control point by the delta as well.
		
		[self setControlPoint:p forPartcode:pc];
	
		if ( following == kCGPathElementAddCurveToPoint )
		{
			NSInteger fpc = partcodeForElement( next );
			old = [self controlPointForPartcode:fpc];
	
			old.x += dx;
			old.y += dy;
		
			[self setControlPoint:old forPartcode:fpc];
		}
		
		// if a closed loop and this is the first element, adjust the subself ending point as well. Note that colin == NO
		// disables this, so the user can drag the points apart by pressing cmd.
				
		if ( depth == 1 && closedLoop && ( et.type == kCGPathElementMoveToPoint ) && colin )
		{
			NSInteger ee = [self subpathEndingElementForElement:element];
		//	LogEvent_(kReactiveEvent, @"recursing to adjust element %d", ee );
			following = [self elementAtIndex:ee].type;
			
			if ( following == kCGPathElementAddCurveToPoint )
				[self moveControlPointPartcode:partcodeForElementControlPoint( ee, 2 ) toPoint:p colinear:colin coradial:corad constrainAngle:acon];
			else
				[self moveControlPointPartcode:partcodeForElement( ee ) toPoint:p colinear:colin coradial:corad constrainAngle:acon];
		}
	}
	
	depth--;
}


#pragma mark -
- (UIBezierPath*)		deleteControlPointForPartcode:(NSInteger) pc
{
	NSInteger aidx = arrayIndexForPartcode( pc );
	NSInteger elem = elementIndexForPartcode( pc );
	CGPathElementType type = [self elementTypeForPartcode:pc].type;
	
	// if the partcode indicates an off-path point, ignore it - it only really makes sense to delete on-path points.
	
	if ( elem < 0 || ( type == kCGPathElementAddCurveToPoint && aidx != 2 ))
		return self;
	else
	{
		NSInteger						i, j, m = [self elementCount];
		CGPoint					ap[3], lp[3];
		BOOL					deletedFirstPoint = NO;
		CGPathElementType		lm;
		UIBezierPath*			newPath = [UIBezierPath bezierPath];
		
		for( i = 0; i < m; ++i )
		{
			lm = [self elementAtIndex:i associatedPoints:ap].type;
		
			if( i == elem )
			{
				// this is the one being deleted, so only need to check if it's the first point (moveto)
				
				if( i == 0 )
					deletedFirstPoint = YES;
			}
			else
			{
				if ( deletedFirstPoint && i == 1 )
				{
					if ( lm == kCGPathElementAddCurveToPoint )
						[newPath moveToPoint:ap[2]];
					else
						[newPath moveToPoint:ap[0]];
				}
				else
				{
					switch( lm )
					{
						case kCGPathElementAddCurveToPoint:
							if ( i == ( elem + 1 ))
								[newPath addCurveToPoint:ap[2] controlPoint1:lp[0] controlPoint2:ap[1]];
							else
								[newPath addCurveToPoint:ap[2] controlPoint1:ap[0] controlPoint2:ap[1]];
							break;
							
						case kCGPathElementMoveToPoint:
							[newPath moveToPoint:ap[0]];
							break;
							
						case kCGPathElementAddLineToPoint:
							[newPath addLineToPoint:ap[0]];
							break;
							
						case kCGPathElementCloseSubpath:
							[newPath closePath];
							break;
							
						default:
							break;
					}
				}
			}
			
			// keep track of the last point
			
			for( j = 0; j < 3; ++j )
				lp[j] = ap[j];
		}
		
		return newPath;
	}
}

// controlPointType is a value 0, 1 or 2 thus:
// 0 = insert whatever is appropriate for the element type hit
// 1 = insert a line segment even if a curve is hit
// 2 = insert a curve segment even if a line is hit
// 3 = insert opposite kind of element from whatever was hit
// see also: DKDrawablePath which calls this

- (UIBezierPath*)		insertControlPointAtPoint:(CGPoint) p tolerance:(CGFloat) tol type:(NSInteger) controlPointType
{
	CGFloat				t;
	NSInteger			i, j, m, inselem = [self elementHitByPoint:p tolerance:tol tValue:&t];
	CGPoint				ap[4], lp[4];	// leave room for four points to define bezier segment
	CGPoint				firstPoint = CGPointZero;
	CGPathElement	pe, pre;
	UIBezierPath*		newPath = nil;
	
	if ( inselem > 0 )
	{
		//NSLog( @"point %@ is close to line, element = %d, t = %f", NSStringFromPoint( p ), inselem, t );
		
		// got a valid insertion point, so copy the path to a new path, inserting a new point
		// at the given element, splitting the existing element at that point to do so.
		
		newPath = [UIBezierPath bezierPath];
		m = [self elementCount];
		
		for( i = 0; i < m; ++i )
		{
			pe = [self elementAtIndex:i associatedPoints:&ap[1]];
			
			if( pe.type == kCGPathElementMoveToPoint )
				firstPoint = ap[1];
			
			if ( i == inselem )
			{
				pre = [self elementAtIndex:i - 1];
				
				if ( pre.type == kCGPathElementAddCurveToPoint )
					ap[0] = lp[3];
				else
					ap[0] = lp[1];

				if ( pe.type == kCGPathElementAddCurveToPoint )
				{
					// bezier segment - split at t and append both curves
					
					CGPoint b1[4], b2[4];
					
					subdivideBezierAtT( ap, b1, b2, t );
					
					if ( controlPointType == 1 || controlPointType == 3 )
					{
						// inset a line segment even though we are splitting a curve segment. In this case
						// the curvature of the line leading to the inserted point obviously cannot be preserved.
						
						[newPath addLineToPoint:b1[3]];
						[newPath addCurveToPoint:b2[3] controlPoint1:b2[1] controlPoint2:b2[2]];
					}
					else
					{
						[newPath addCurveToPoint:b1[3] controlPoint1:b1[1] controlPoint2:b1[2]];
						[newPath addCurveToPoint:b2[3] controlPoint1:b2[1] controlPoint2:b2[2]];
					}
				}
				else
				{
					// straight line - split at t and append the two pieces.
					
					if ( pe.type == kCGPathElementCloseSubpath )
						ap[1] = firstPoint;
				
					CGPoint ip = Interpolate( ap[0], ap[1], t );
					
					if ( controlPointType == 2 || controlPointType == 3 )
					{
						// insert a pair of curve segments even though we are splitting a line segment -
						// initial control points are set so that the path doesn't change but not coincident with on-path points.
						
						CGPoint cpa, cpb, cpc, cpd;
						
						cpa = Interpolate( ip, ap[0], 0.75 );
						cpb = Interpolate( ip, ap[0], 0.25 );
						cpc = Interpolate( ap[1], ip, 0.75 );
						cpd = Interpolate( ap[1], ip, 0.25 );
						
						[newPath addCurveToPoint:ip controlPoint1:cpa controlPoint2:cpb];
						[newPath addCurveToPoint:ap[1] controlPoint1:cpc controlPoint2:cpd];
					}
					else
					{
						[newPath addLineToPoint:ip];
						[newPath addLineToPoint:ap[1]];
					}
					
					if( pe.type == kCGPathElementCloseSubpath )
						[newPath closePath];
				}
			}
			else
			{
				switch ( pe.type )
				{
					case kCGPathElementAddCurveToPoint:
						[newPath addCurveToPoint:ap[3] controlPoint1:ap[1] controlPoint2:ap[2]];
						break;
						
					case kCGPathElementMoveToPoint:
						[newPath moveToPoint:ap[1]];
						break;
						
					case kCGPathElementAddLineToPoint:
						[newPath addLineToPoint:ap[1]];
						break;
						
					case kCGPathElementCloseSubpath:
						[newPath closePath];
						break;
						
					default:
						break;
				}
			}
			
			for( j = 0; j < 4; ++j )
				lp[j] = ap[j];
		}
	}
	//else
	//	NSLog( @"point %@ missed, element = %d", NSStringFromPoint( p ), inselem );
	
	return newPath;
}


- (CGPoint)				nearestPointToPoint:(CGPoint) p tolerance:(CGFloat) tol
{
	// given a point, this determines whether it's within <tol> distance of the path. If so, the nearest point on the path is returned,
	// otherwise the original point is returned.
	
	CGPoint	np;
	CGFloat	t;
	NSInteger		elem = [self elementHitByPoint:p tolerance:tol tValue:&t nearestPoint:&np];
	
	if ( elem < 1 )
		return p;
	else
		return np;
}


#pragma mark -
- (CGFloat)				tangentAtStartOfSubpath:(NSInteger) elementIndex
{
	// given an element index, this finds the start of the subpath and returns the tangent of the endpoint. The tangent can be used to align elements on the path such as
	// arrow heads. For a curve segment, the tangent is the angle of the line drawn from cp0 to cp1. For a line segment, the tangent is the angle of the line segment.

	NSInteger				se;
	CGPoint					ap[3];
	CGPoint					bp[3];
	
	se = [self subpathStartingElementForElement:elementIndex];
	
	if(( se + 1 ) < [self elementCount])
	{
		[self elementAtIndex:se associatedPoints:ap];
		[self elementAtIndex:se + 1 associatedPoints:bp];
	
		return atan2f( bp[0].y - ap[0].y, bp[0].x - ap[0].x ) + M_PI;
	}
	else
		return 0.0;
}


- (CGFloat)				tangentAtEndOfSubpath:(NSInteger) elementIndex
{
	// given an element index, this finds the end of the subpath and returns the tangent of the endpoint. The tangent can be used to align elements on the path such as
	// arrow heads. For a curve segment, the tangent is the angle of the line drawn from cp2 to cp3. For a line segment, the tangent is the angle of the line segment.
	
	NSInteger						ee;
	CGPoint					ap[3];
	CGPoint					bp[3];
	CGPathElementType		et, pt;
	
	ee = [self subpathEndingElementForElement:elementIndex];
	et = [self elementAtIndex:ee associatedPoints:ap].type;
	
	// if last element is a curveto, we have all the information we need to compute the tangent
	
	if ( et == kCGPathElementAddCurveToPoint )
		return atan2f( ap[2].y - ap[1].y, ap[2].x - ap[1].x );
	else
	{
		// ending element is a lineto or other single point, so we need to find the last point of the previous element
		
		pt = [self elementAtIndex:ee - 1 associatedPoints:bp].type;
		
		// if it s a curveto, its end point is bp[2], otherwise it's bp[0]
		
		if ( pt == kCGPathElementAddCurveToPoint )
			return atan2f( ap[0].y - bp[2].y, ap[0].x - bp[2].x );
		else
			return atan2f( ap[0].y - bp[0].y, ap[0].x - bp[0].x );
	}
}


#pragma mark -
- (NSInteger)					elementHitByPoint:(CGPoint) p tolerance:(CGFloat) tol tValue:(CGFloat*) t
{
	return [self elementHitByPoint:p tolerance:tol tValue:t nearestPoint:NULL];
}


- (NSInteger)					elementHitByPoint:(CGPoint) p tolerance:(CGFloat) tol tValue:(CGFloat*) t nearestPoint:(CGPoint*) npp
{
	// determines which element is hit by the point, and where. This first rejects any point outside the overall bounds of the
	// path, then tests which elements bounds enclose the point. Then it really gets down to business and calculates the
	// actually position along the path. For line segments, the t value returned is the linear proportion of the length from
	// 0..1, for curves it is the bezier t parameter value. <tol> is used to determine how accurate the computation needs to be
	// to count as a hit.
	
#if (USE_OMNI_METHODS)
	CGFloat		tee;
	NSInteger			elem = [self _segmentHitByPoint:p position:&tee padding:tol];

	if ( elem > 0 )
	{
		// got a hit, so work out the point for the returned parameter t.
		
		if ( t )
			*t = tee;
		
		if ( npp )
		{
			OABezierPathPosition pos;
			
			pos.segment = elem;
			pos.parameter = tee;
			
			*npp = [self getPointForPosition:pos];
		}
		return elem;
	}
	else
		return -1;	// not found or hit

#else
	CGRect bb = CGRectInset([self bounds], -tol, -tol );
	
	if ( CGRectContainsPoint(bb, p))
	{
		NSInteger elem = [self elementBoundsContaiCGPoint:p tolerance:tol];
		
		//NSLog(@"point %@ (tol = %f) in element bbox, elem = %d", NSStringFromPoint( p ), tol, elem );
		
		if ( elem > 0 )
		{
			// point is with the bbox of the segment <elem>. If elem == 0, error
			
			CGPoint				np = CGPointZero;
			CGPoint				ap[3], lp[3];
			CGPathElement etype = [self elementAtIndex:elem associatedPoints:ap];
			CGPathElement pretype = [self elementAtIndex:elem - 1 associatedPoints:lp];
			double				tt = 0.0;
			
			// only care about the end point - put it in lp[0] where it is consistent for all types
			
			if ( pretype.type == kCGPathElementAddCurveToPoint )
				lp[0] = lp[2];
		
			if ( etype.type == kCGPathElementAddCurveToPoint )
			{
				// curve
				
				CGPoint bez[4];
				
				bez[0] = lp[0];
				bez[1] = ap[0];
				bez[2] = ap[1];
				bez[3] = ap[2];
				
				np = NearestPointOnCurve( p, bez, &tt );
			}
			else if ( etype.type != kCGPathElementMoveToPoint )
			{
				if ( etype.type == kCGPathElementCloseSubpath )
				{
					// get point for start of this subpath
					
					NSInteger ss = [self subpathStartingElementForElement:elem];
					[self elementAtIndex:ss associatedPoints:ap];
				}
				
				// line or close
				
				np = NearestPointOnLine( p, lp[0], ap[0] );
				tt = RelPoint( np, lp[0], ap[0] );
			}	
			
			// check to see if the nearest point is within tolerance:
			
			CGFloat d = hypotf(( np.x - p.x ), ( np.y - p.y ));
			
			//NSLog(@"point is %f from segment line: {%1.2f,%1.2f}..{%1.2f,%1.2f}", d, ap[0].x, ap[0].y, lp[0].x, lp[0].y );

			if ( d <= tol )
			{
				if( t )
					*t = tt;
					
				if ( npp )
					*npp = np;
						
				return elem;
			}
		}
	}
	
	return -1;	// out of tolerance, or not found
#endif
}


- (NSInteger)					elementBoundsContaiCGPoint:(CGPoint) p tolerance:(CGFloat) tol
{
	// for each element of a bezier path, this tests the point against the bounding box of the element, returning the
	// element index of the one containing the point. If none do, it returns -1. This gives you a quick way to home in
	// on the specific element to work on for further resolving the point. Note - assumes you've already tested the overall
	// bounds and got a YES result (this works either way, but if that returns NO, there's no point doing this).
	
	NSInteger		i, m = [self elementCount];
	CGRect	bb;
	
	// initially ignore <tol>, this allows us to find the right element when the point is close to another segment
	
	for( i = 1; i < m; ++i )
	{
		bb = [self boundingBoxForElement:i];
		
		if ( CGRectContainsPoint(bb, p))
			return i;
	}
	
	// if not found, widen the search to include <tol>. This allows us to find the nearest element even if the point is outside the
	// bbox. This is performed as a second step because otherwise the overlapping bboxes can give false results.

	for( i = 1; i < m; ++i )
	{
		bb = CGRectInset([self boundingBoxForElement:i], -tol, -tol);
		
		if ( CGRectContainsPoint(bb, p))
			return i;
	}
	
	// OK, we give up
	
	return -1;
}


- (CGRect)				boundingBoxForElement:(NSInteger) elementIndex
{
	// given the element index, this returns the element's bounding rect.
	
	CGRect				bb = CGRectZero;
	CGPoint				ap[4], pp[3];
	CGFloat				minx, miny, maxx, maxy;
	NSInteger					j;
	
	CGPathElementType pm = 0;
	CGPathElementType	lm = [self elementAtIndex:elementIndex associatedPoints:ap].type;
	
	if ( lm == kCGPathElementMoveToPoint )
		return CGRectZero;
	
	pm = [self elementAtIndex:elementIndex - 1 associatedPoints:pp].type;

	if ( lm == kCGPathElementAddCurveToPoint )
	{
		// curves are bounded by their control points - in fact the curve may be considerably
		// smaller than that, but it's much faster to calculate the cp bounds
		
		if ( pm == kCGPathElementAddCurveToPoint )
			ap[3] = pp[2];
		else
			ap[3] = pp[0];
		
		minx = miny = HUGE_VAL;
		maxx = maxy = -HUGE_VAL;
		
		for( j = 0; j < 4; ++j )
		{
			if ( ap[j].x < minx )
				minx = ap[j].x;
				
			if ( ap[j].y < miny )
				miny = ap[j].y;
				
			if ( ap[j].x > maxx )
				maxx = ap[j].x;
			
			if ( ap[j].y > maxy )
				maxy = ap[j].y;
		}
		
		bb.origin.x = minx;
		bb.origin.y = miny;
		bb.size.width = fabs(maxx - minx);
		bb.size.height = fabs(maxy - miny);
	}
	else if ( lm == kCGPathElementCloseSubpath )
	{
		NSInteger fe = [self subpathStartingElementForElement:elementIndex];
		[self elementAtIndex:fe associatedPoints:ap];
		
		if( pm == kCGPathElementAddCurveToPoint )
			bb = CGRectFromTwoPoints( ap[0], pp[2] );
		else
			bb = CGRectFromTwoPoints( ap[0], pp[0] );
		
	//	LogEvent_(kInfoEvent, @"fe = %d, a = %@, b = %@", fe, NSStringFromPoint( ap[0]), NSStringFromPoint( pp[0] ));
	}
	else
	{
		// lines define two opposite corners of the bbox
		
		if( pm == kCGPathElementAddCurveToPoint )
			bb = CGRectFromTwoPoints( ap[0], pp[2] );
		else
			bb = CGRectFromTwoPoints( ap[0], pp[0] );
	}
	
	return bb;
}


- (void)				drawElementsBoundingBoxes
{
	// this is a debugging method - it displays the bounding rects of the path in the current view
	
	[[UIColor redColor] set];
	
	NSInteger		i, m = [self elementCount];
	
	for( i = 0; i < m; ++i )
        [[UIBezierPath bezierPathWithRect:[self boundingBoxForElement:i]] stroke];
}


- (NSSet*)			boundingBoxesForPartcode:(NSInteger) pc
{
	// returns a set of two rectangles (as NSValues) which bound the elements either side of the partcode. The rects are not ordered as such - you
	// can use them to call for a refresh of the path for just that element which can reduce uneeded drawing (the entire path is still redrawn, but
	// other objects close to it that intersect its overall bounds but not the element bounds will not be).
	
	NSMutableSet* set = [NSMutableSet set];
	NSInteger		j, e = elementIndexForPartcode(pc);
	CGRect	r = [self boundingBoxForElement:e];
	[set addObject:[NSValue valueWithCGRect:r]];
	
	CGPathElementType lm = [self elementTypeForPartcode:pc].type;
	
	// the other rect is for the next or previous element depending on whether pc is the first control point or a later one.
	
	if( e < [self elementCount])
	{
		j = arrayIndexForPartcode(pc);
		
		if ( j == 0 && e > 0 && lm == kCGPathElementAddCurveToPoint)
		{
			r = [self boundingBoxForElement:e - 1];
			[set addObject:[NSValue valueWithCGRect:r]];
		}
		else if ( e < [self elementCount] - 1 )
		{
			r = [self boundingBoxForElement:e + 1];
			[set addObject:[NSValue valueWithCGRect:r]];
		}
	}
	
	// if the path is closed it also needs to return the box from the opposite end of the path

	if([self isPathClosed])
	{
		if ( e < 2 )
		{
			r = [self boundingBoxForElement:[self subpathEndingElementForElement:e]];
			[set addObject:[NSValue valueWithCGRect:r]];
		}
		else if ( e == ([self elementCount] - 1))
		{
			r = [self boundingBoxForElement:[self subpathStartingElementForElement:e] + 1];
			[set addObject:[NSValue valueWithCGRect:r]];
		}
	}
	
	return set;
}


- (NSSet*)				allBoundingBoxes
{
	NSMutableSet*	set = [NSMutableSet set];
	CGRect			r;
	NSInteger				i, m = [self elementCount];
	
	for( i = 0; i < m; ++i )
	{
		r = [self boundingBoxForElement:i];
		[set addObject:[NSValue valueWithCGRect:r]];
	}
	return set;
}


@end


#pragma mark -
#pragma mark **** partcode utilities ****

inline NSInteger			partcodeForElement( const NSInteger element )
{
	// returns a unique partcode for an element that contains just a single point (i.e. all of them except curveto)
	
	return (( element + 1 ) << 2 );
}


inline NSInteger			partcodeForElementControlPoint( const NSInteger element, const NSInteger controlPointIndex )
{
	// given the element and the index of the control point (0, 1 or 2 ), this returns a unique "partcode" that
	// can be used to refer to that specific control point in the path.
	
	return ((( element + 1 ) << 2 ) | ( controlPointIndex & 3 ));
}


inline NSInteger			arrayIndexForPartcode( const NSInteger pc )
{
	return ( pc & 3 );
}


inline NSInteger			elementIndexForPartcode( const NSInteger pc )
{
	// returns the element index a partcode is referring to
	
	return ( pc >> 2 ) - 1;
}

