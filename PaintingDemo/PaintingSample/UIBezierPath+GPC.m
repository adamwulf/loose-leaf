///**********************************************************************************************************************************
///  UIBezierPath+GPC.m
///  DrawKit �2005-2008 Apptree.net
///
///  Created by graham on 31/10/2006.
///
///	 This software is released subject to licensing conditions as detailed in DRAWKIT-LICENSING.TXT, which must accompany this source file. 
///
///**********************************************************************************************************************************

#ifdef qUseGPC

#import "UIBezierPath+GPC.h"
#import "UIBezierPath+Editing.h"
#import "DKGeometryUtilities.h"
#import "UIBezierPath+NSOSX.h"
//#import "UIBezierPath+Combinatorial.h"

#ifdef qUseCurveFit
#import "CurveFit.h"
#endif


//#define qUseLogPoly
#ifdef qUseLogPoly
static void		logPoly( gpc_polygon* poly );
#endif

static CGFloat flatness = 0.6;


NSString*	kDKCurveFittingPolicyDefaultsKey = @"DKCurveFittingPolicy";

#pragma mark -
@implementation UIBezierPath (GPC)
#pragma mark As a UIBezierPath

+(void) setDefaultFlatness:(CGFloat)_flatness{
    flatness = _flatness;
}

+(CGFloat) defaultFlatness{
    return flatness;
}

///*********************************************************************************************************************
///
/// method:			bezierPathWithGPCPolygon:
/// scope:			class method
/// overrides:
/// description:	converts a vector polygon in gpc format to an UIBezierPath
/// 
/// parameters:		<poly> a gpc polygon structure
/// result:			the same polygon as an UIBezierPath
///
/// notes:			
///
///********************************************************************************************************************

+ (UIBezierPath*)		bezierPathWithGPCPolygon:(gpc_polygon*) poly
{
	NSAssert( poly != NULL, @"attempt to create path from NULL poly");
	
	UIBezierPath*	path = [UIBezierPath bezierPath];
	CGPoint			p;
	NSInteger				cont;
	
	for( cont = 0; cont < poly->num_contours; ++cont )
	{
		p.x = poly->contour[cont].vertex[0].x;
		p.y = poly->contour[cont].vertex[0].y;
		[path moveToPoint:p];
		
		NSInteger vert;
		
		for( vert = 1; vert < poly->contour[cont].num_vertices; ++vert )
		{
			p.x = poly->contour[cont].vertex[vert].x;
			p.y = poly->contour[cont].vertex[vert].y;
			[path addLineToPoint:p];
		}
		
		[path closePath];
	}
	
	// set the default winding rule to be the one most useful for shapes
	// with holes.
	
    [path setUsesEvenOddFillRule:NO];
	
	return path;
}


///*********************************************************************************************************************
///
/// method:			setPathUnflatteningPolicy:
/// scope:			class method
/// overrides:
/// description:	sets the unflattening (curve fitting) policy for curve fitting flattened paths after a boolean op
/// 
/// parameters:		<sp> policy constant
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

+ (void)				setPathUnflatteningPolicy:(DKPathUnflatteningPolicy) sp
{
	[[NSUserDefaults standardUserDefaults] setInteger:sp forKey:kDKCurveFittingPolicyDefaultsKey];
}


///*********************************************************************************************************************
///
/// method:			pathUnflatteningPolicy
/// scope:			class method
/// overrides:
/// description:	returns the unflattening (curve fitting) policy for curve fitting flattened paths after a boolean op
/// 
/// parameters:		none
/// result:			the current unflattening policy
///
/// notes:			
///
///********************************************************************************************************************

+ (DKPathUnflatteningPolicy)	pathUnflatteningPolicy
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:kDKCurveFittingPolicyDefaultsKey];
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			gpcPolygon
/// scope:			instance method
/// extends:		UIBezierPath
/// description:	converts a bezier path to a gpc polygon format structure
/// 
/// parameters:		none
/// result:			a newly allocated gpc polygon structure
///
/// notes:			the caller is responsible for freeing the returned object (in contrast to usual cocoa rules)
///
///********************************************************************************************************************

- (gpc_polygon*)		gpcPolygon
{
	return [self gpcPolygonWithFlatness:0.01];
}


///*********************************************************************************************************************
///
/// method:			gpcPolygonWithFlatness
/// scope:			instance method
/// extends:		UIBezierPath
/// description:	converts a bezier path to a gpc polygon format structure
/// 
/// parameters:		<flatness> the flatness value for converting curves to vector form
/// result:			a newly allocated gpc polygon structure
///
/// notes:			the caller is responsible for freeing the returned object (in contrast to usual cocoa rules)
///
///********************************************************************************************************************

- (gpc_polygon*)		gpcPolygonWithFlatness:(CGFloat) flatness
{
	CGFloat savedFlatness = [[self class] defaultFlatness];
	
	[[self class] setDefaultFlatness:flatness];
	
	UIBezierPath*			flat = [self bezierPathByFlatteningPath];
	CGPathElement		elem;
	CGPoint					ap[3];
	NSInteger				i, ec = [flat elementCount];
	gpc_polygon*			poly;
	
	[[self class] setDefaultFlatness:savedFlatness];
	[flat setUsesEvenOddFillRule:[self usesEvenOddFillRule]];
	
	// allocate memory for the poly.
	
	poly = (gpc_polygon*) malloc( sizeof( gpc_polygon ));
	
	if ( poly == NULL )
		return NULL;
		
	poly->contour = NULL;
	poly->hole = NULL;
	
	// how many contours do we need?
	
	NSInteger subs;
	[flat getPathMoveToCount:&subs lineToCount:NULL curveToCount:NULL closePathCount:NULL];
	poly->num_contours = subs;

	poly->contour = (gpc_vertex_list*) malloc( sizeof( gpc_vertex_list ) * poly->num_contours );
	
	if ( poly->contour == NULL )
	{
		gpc_free_polygon( poly );
		return NULL;
	}
	
	// how many elements in each contour?
	
	NSInteger es = 0;
	
	for( i = 0; i < poly->num_contours; ++i )
	{
		NSInteger spc = [flat subPathCountStartingAtElement:es];
	
		// allocate enough memory to hold this many points
				
		poly->contour[i].num_vertices = spc - 1;
		poly->contour[i].vertex = (gpc_vertex*) malloc( sizeof( gpc_vertex ) * spc );
		
		es += spc;
	}
	
	// es will now keep track of which contour we are adding to; k is the element index within it.
	
	NSInteger k = 0;
	es = -1;
	
	for( i = 0; i < ec; ++i )
	{
//        NSLog(@"asking for %d of %d", i, [flat elementCount]);
//        if(i >= [flat elementCount]){
//            NSLog(@"oh no");
//        }
		elem = [flat elementAtIndex:i associatedPoints:ap];
		
		switch( elem.type )
		{
			case kCGPathElementMoveToPoint:
				// begins a new contour. Note that gcp_polygons don't bother to close the path or even make the last vertex equal to the first,
				// thus we don't need to track the opening point or deal with a closePath element.
				
				++es;
				k = 0;
				
				// sanity check es - must not exceed contour count - 1
				
				if ( es >= poly->num_contours )
				{
					LogEvent_(kWheneverEvent, @"discrepancy in contour count versus number of subpaths encountered - bailing");
					
					gpc_free_polygon( poly );
					return NULL;
				}
			
				// fall through to record the vertex for the moveto
			
			case kCGPathElementAddLineToPoint:
				// add a vertex to the list
				poly->contour[es].vertex[k].x = ap[0].x;
				poly->contour[es].vertex[k].y = ap[0].y;
				++k;
				break;
			
			case kCGPathElementAddCurveToPoint:
				// should never happen - we have already converted the path to a flat version. Bail.
				LogEvent_(kWheneverEvent, @"got a curveto unexpectedly - bailing");
				gpc_free_polygon( poly );
				return NULL;
			
			case kCGPathElementCloseSubpath:
				break;
			
			default:
				break;
		}
	}
	
	return poly;
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			subPathCountStartingAtElement:
/// scope:			instance method
/// extends:		UIBezierPath
/// description:	counts the number of separate subpath in the path starting from a given element
/// 
/// parameters:		<se> the index of some element in the path
/// result:			integer, the number of subpaths after and including se (actually the number of moveTo ops)
///
/// notes:			
///
///********************************************************************************************************************

- (NSInteger)					subPathCountStartingAtElement:(NSInteger) se
{
	// returns the number of elements in the subpath starting at element <se>. The caller is responsible for setting se
	// correctly - it should be the index of a 'moveto' element. This counts up until the next moveTo or the end of
	// the path, and returns the element count.
	
	CGPathElement	et;
	NSInteger					sp, i, ec = [self elementCount];
	
	sp = 1;
	
	for( i = se + 1; i < ec; ++i )
	{
		et = [self elementAtIndex:i];
		
		if ( et.type == kCGPathElementMoveToPoint )
			break;
			
		++sp;
	}
	
	return sp;
}




#pragma mark -
///*********************************************************************************************************************
///
/// method:			intersectsPath:
/// scope:			instance method
/// extends:		UIBezierPath
/// description:	tests whether this path intersects another
/// 
/// parameters:		<path> another path to test against
/// result:			YES if the paths intersect, NO otherwise
///
/// notes:			this works by computing the intersection of the two paths and checking if it's empty. Because it
///					does a full-blown intersection, it is not necessarily a trivial operation. It is accurate for
///					curves, etc however. It is worth trying to eliminate all obvious non-intersecting cases prior to
///					calling this where performance is critical - this does however return quickly if the bounds do not
///					intersect.
///
///********************************************************************************************************************

- (BOOL)				intersectsPath:(UIBezierPath*) path
{
	CGRect		bbox = [path bounds];
	
	if ( CGRectIntersectsRect( bbox, [self bounds]))
	{
		// bounds intersect, so it's a possibility - find the intersection and see if it's empty.
	
		UIBezierPath* ip = [self pathFromIntersectionWithPath:path];
		
		return ![ip isEmpty];
	}
	else
		return NO;
}


///*********************************************************************************************************************
///
/// method:			pathFromPath:usingBooleanOperation:
/// scope:			instance method
/// extends:		UIBezierPath
/// description:	creates a new path from a boolean operation between this path and another path
/// 
/// parameters:		<otherPath> another path which is combined with this one's path
///					<op> the operation to perform - constants defined in gpc.h
/// result:			a new path (may be empty in certain cases)
///
/// notes:			this applies the current flattening policy set for the class. If the policy is auto, this looks
///					at the makeup of the contributing paths to determine whether to unflatten or not. If both source
///					paths consist solely of line elements (no bezier curves), then no unflattening is performed.
///
///********************************************************************************************************************

- (UIBezierPath*)		pathFromPath:(UIBezierPath*) otherPath usingBooleanOperation:(gpc_op) op
{
	BOOL simplify = NO;
	
	if ([[self class] pathUnflatteningPolicy] == kDKPathUnflattenAlways)
		simplify = YES;
	else if ([[self class] pathUnflatteningPolicy] == kDKPathUnflattenAuto)
	{
		// for auto, if both this path and the other path have no curve segments, simplify is NO, otherwise YES.
		
		NSInteger cs, co;
		
		[self getPathMoveToCount:NULL lineToCount:NULL curveToCount:&cs closePathCount:NULL];
		[otherPath getPathMoveToCount:NULL lineToCount:NULL curveToCount:&co closePathCount:NULL];
		
		if ( cs == 0 && co == 0 )
			simplify = NO;
		else
			simplify = YES;
	}
	
	return [self pathFromPath:otherPath usingBooleanOperation:op unflattenResult:simplify];
}


///*********************************************************************************************************************
///
/// method:			pathFromPath:usingBooleanOperation:unflattenResult:
/// scope:			private instance method
/// extends:		UIBezierPath
/// description:	creates a new path from a boolean operation between this path and another path
/// 
/// parameters:		<otherPath> another path which is combined with this one's path
///					<op> the operation to perform - constants defined in gpc.h
///					<unflattenResult> YES to attempt curve fitting on the result, NO to leave it in vector form
/// result:			a new path (may be empty in certain cases)
///
/// notes:			the unflattening flag is passed directly - the curve fitting policy of the class is ignored
///
///********************************************************************************************************************

- (UIBezierPath*)		pathFromPath:(UIBezierPath*) otherPath usingBooleanOperation:(gpc_op) op unflattenResult:(BOOL) uf
{
	UIBezierPath*	result;
	gpc_polygon		*a, *b, *c;
	
	a = [self gpcPolygon];
	b = [otherPath gpcPolygon];
	
	if ( a == NULL || b == NULL )
	{
		LogEvent_( kReactiveEvent, @"unable to create at least one of the operand polygons - bailing");
		
		if( a != NULL )
			gpc_free_polygon( a );
			
		if( b != NULL )
			gpc_free_polygon( b );
	
		return nil;
	}
	
	c = (gpc_polygon*) malloc( sizeof( gpc_polygon ));
	
	gpc_polygon_clip( op, a, b, c );
	
#ifdef qUseLogPoly
	logPoly( a );
	logPoly( b );
	logPoly( c );
#endif

	// if the result is equal to one of the operands, then return the original path that the operand was derived from. This
	// avoids unnecessary conversion of paths when the operation didn't result in a unique new path. 

	if( equalPolys( a, c ))
	{
		result = self;
		uf = NO;
	}
	else if( equalPolys( b, c ))
	{
		result = otherPath;
		uf = NO;
	}
	else
		result = [UIBezierPath bezierPathWithGPCPolygon:c];
	
	gpc_free_polygon( a );
	gpc_free_polygon( b );
	gpc_free_polygon( c );
	
	if ( uf )
		return [result bezierPathByUnflatteningPath];
	else
		return result;
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			pathFromUnionWithPath:
/// scope:			instance method
/// extends:		UIBezierPath
/// description:	creates a new path which is the union of this path and another path
/// 
/// parameters:		<otherPath> another path which is unioned with this one's path
/// result:			a new path
///
/// notes:			curve fitting policy for the class is applied to this method
///
///********************************************************************************************************************

- (UIBezierPath*)		pathFromUnionWithPath:(UIBezierPath*) otherPath
{
	// if the paths are disjoint, this can be accomplished using a simple concatentation of the paths, which
	// is preferable to avoid losing original control points and needing to curve-fit.
	
	if( !CGRectIntersectsRect( [self bounds], [otherPath bounds]))
	{
		[self appendPath:otherPath];
		return self;
	}
	else
	{
		// the bounds intersect, but do the paths? It's worth checking even though it's expensive, because we really
		// don't want to curve fit paths unless absolutely necessary
		
		if([self intersectsPath:otherPath])
			return [self pathFromPath:otherPath usingBooleanOperation:GPC_UNION];
		else
		{
			[self appendPath:otherPath];
			return self;
		}
	}
}


///*********************************************************************************************************************
///
/// method:			pathFromIntersectionWithPath:
/// scope:			instance method
/// extends:		UIBezierPath
/// description:	creates a new path which is the intersection of this path and another path
/// 
/// parameters:		<otherPath> another path which is intersected with this one's path
/// result:			a new path (possibly empty)
///
/// notes:			curve fitting policy for the class is applied to this method. If the paths bounds do not intersect,
///					returns nil
///
///********************************************************************************************************************

- (UIBezierPath*)		pathFromIntersectionWithPath:(UIBezierPath*) otherPath
{
	if( ! CGRectIntersectsRect([self bounds], [otherPath bounds]))
		return nil;
	else
		return [self pathFromPath:otherPath usingBooleanOperation:GPC_INT];
}


///*********************************************************************************************************************
///
/// method:			pathFromDifferenceWithPath:
/// scope:			instance method
/// extends:		UIBezierPath
/// description:	creates a new path which is the difference of this path and another path
/// 
/// parameters:		<otherPath> another path which is subtracted from this one's path
/// result:			a new path (possibly empty)
///
/// notes:			curve fitting policy for the class is applied to this method. If the paths bounds do not
///					intersect, returns self, on the basis that subtracting the other path doesn't change this one.
///
///********************************************************************************************************************

- (UIBezierPath*)		pathFromDifferenceWithPath:(UIBezierPath*) otherPath
{
	if( ! CGRectIntersectsRect([self bounds], [otherPath bounds]))
		return self;
	else
		return [self pathFromPath:otherPath usingBooleanOperation:GPC_DIFF];
}


///*********************************************************************************************************************
///
/// method:			pathFromExclusiveOrWithPath:
/// scope:			instance method
/// extends:		UIBezierPath
/// description:	creates a new path which is the xor of this path and another path
/// 
/// parameters:		<otherPath> another path which is xored with this one's path
/// result:			a new path (possibly empty)
///
/// notes:			curve fitting policy for the class is applied to this method
///
///********************************************************************************************************************

- (UIBezierPath*)		pathFromExclusiveOrWithPath:(UIBezierPath*) otherPath
{
	// if the paths are disjoint, this is equivalent to a union, or simple path concatenation
	
	if( !CGRectIntersectsRect( [self bounds], [otherPath bounds]))
	{
		[self appendPath:otherPath];
		return self;
	}
	else
		return [self pathFromPath:otherPath usingBooleanOperation:GPC_XOR];
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			bezierPathByUnflatteningPath
/// scope:			instance method
/// extends:		UIBezierPath
/// description:	creates a new path which is the unflattened version of this
/// 
/// parameters:		none
/// result:			the unflattened path (curve fitted)
///
/// notes:			
///
///********************************************************************************************************************

- (UIBezierPath*)		bezierPathByUnflatteningPath
{
	if([self isEmpty])
		return self;

#ifdef qUseCurveFit
	CGSize ps = [self bounds].size;
	
	CGFloat epsilon = MIN( ps.width, ps.height ) / 1000.0;
	
	LogEvent_(kInfoEvent, @"curve fit epsilon: %f", epsilon );

	return smartCurveFitPath( self, epsilon, kDKDefaultCornerThreshold );
#else
	return self;
#endif
}


@end



#pragma mark -
#pragma mark - gpc polygon utilities

NSUInteger checksumPoly( gpc_polygon* poly )
{
	// returns a simple checksum of the polygon which is a weighted sum of the number of vertices and the number of contours. Polys can be roughly compared for equality
	// by testing the checksum. If they are different, the polys are definitely different. If the same, they are possibly the same, but will need further checks to be
	// certain.
	
	NSUInteger cs = 0;
	NSUInteger cc = (NSUInteger)poly->num_contours;
	NSUInteger i, vc;
	
	for( i = 0; i < cc; ++i )
	{
		vc = (NSUInteger)poly->contour[i].num_vertices;
		cs += vc * ( i + 1 );
	}
	
	cs += cc * ( i + 4 );
	
	return cs;
}


CGRect   boundsOfPoly( gpc_polygon* poly )
{
	// returns the bounding box of the poly by iterating over all vertices.
	
	double		minX, maxX, minY, maxY;
	gpc_vertex	vertex;
	
	minX = minY = DBL_MAX;
	maxX = maxY = -DBL_MAX;
	
	NSInteger c, v;
	
	for( c = 0; c < poly->num_contours; ++c )
	{
		for( v = 0; v < poly->contour[c].num_vertices; ++v )
		{
			vertex = poly->contour[c].vertex[v];
			
			if( vertex.x > maxX )
				maxX = vertex.x;
				
			if( vertex.x < minX )
				minX = vertex.x;
				
			if( vertex.y > maxY )
				maxY = vertex.y;
				
			if( vertex.y < minY )
				minY = vertex.y;
		}
	}
	
	return CGRectFromTwoPoints(CGPointMake( minX, minY ), CGPointMake( maxX, maxY ));
}


BOOL	 equalPolys( gpc_polygon* polyA, gpc_polygon* polyB )
{
	// compares two polys. Considered equal if they have the same checksum and the same bbox.
	
	NSUInteger csa, csb;
	
	csa = checksumPoly( polyA );
	csb = checksumPoly( polyB );
	
	if ( csa == csb )
	{
		CGRect bbA, bbB;
		
		bbA = boundsOfPoly( polyA );
		bbB = boundsOfPoly( polyB );
		
		return AreSimilarRects( bbA, bbB, 0.001 );
	}
	
	return NO;
}


BOOL	 intersectingPolys( gpc_polygon* polyA, gpc_polygon* polyB )
{
	// returns YES if the bounds rects of the two polys intersect. This can be used as an initial check before doing something more
	// expensive.
	
	CGRect bbA, bbB;
	
	bbA = boundsOfPoly( polyA );
	bbB = boundsOfPoly( polyB );
	
	return CGRectIntersectsRect( bbA, bbB );
}


#ifdef qUseLogPoly
static void		logPoly( gpc_polygon* poly )
{
	// dumps the contents of the poly to the log

	LogEvent_(kReactiveEvent, @"gpc_polygon: %p (checksum = %d)", poly, checksumPoly(poly));
	LogEvent_(kReactiveEvent, @"bbox = %@", NSStringFromRect( boundsOfPoly(poly)));
	LogEvent_(kReactiveEvent, @"contours: %d\n", poly->num_contours );
	
	NSInteger cont;
	
	for( cont = 0; cont < poly->num_contours; ++cont )
	{
		LogEvent_(kReactiveEvent, @"contour #%d: %d vertices", cont, poly->contour[cont].num_vertices );
		
		NSInteger vert;
		
		for( vert = 0; vert < poly->contour[cont].num_vertices; ++vert )
			LogEvent_(kReactiveEvent, @"{ %f, %f },", poly->contour[cont].vertex[vert].x, poly->contour[cont].vertex[vert].y );
			
		LogEvent_(kReactiveEvent, @"------ end of contour %d ------", cont );
	}
	LogEvent_(kReactiveEvent, @"------ end of polygon ------" );
}
#endif


#endif /* defined (qUseGPC) */
