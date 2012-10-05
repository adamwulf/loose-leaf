///**********************************************************************************************************************************
///  DKGeometryUtilities.h
///  DrawKit �2005-2008 Apptree.net
///
///  Created by graham on 22/10/2006.
///
///	 This software is released subject to licensing conditions as detailed in DRAWKIT-LICENSING.TXT, which must accompany this source file. 
///
///**********************************************************************************************************************************


#ifdef __cplusplus
extern "C"
{
#endif


CGRect				CGRectFromTwoPoints( const CGPoint a, const CGPoint b );
CGRect				CGRectCentredOnPoint( const CGPoint p, const CGSize size );
CGRect				UnionOfTwoRects( const CGRect a, const CGRect b );
CGRect				UnionOfRectsInSet( const NSSet* aSet );
NSSet*				DifferenceOfTwoRects( const CGRect a, const CGRect b );
NSSet*				SubtractTwoRects( const CGRect a, const CGRect b );

BOOL				AreSimilarRects( const CGRect a, const CGRect b, const CGFloat epsilon );

CGFloat				PointFromLine( const CGPoint inPoint, const CGPoint a, const CGPoint b );
CGPoint				NearestPointOnLine( const CGPoint inPoint, const CGPoint a, const CGPoint b );
CGFloat				RelPoint( const CGPoint inPoint, const CGPoint a, const CGPoint b );
NSInteger			PointInLineSegment( const CGPoint inPoint, const CGPoint a, const CGPoint b );

CGPoint				BisectLine( const CGPoint a, const CGPoint b );
CGPoint				Interpolate( const CGPoint a, const CGPoint b, const CGFloat proportion);
CGFloat				LineLength( const CGPoint a, const CGPoint b );

CGFloat				SquaredLength( const CGPoint p );
CGPoint				DiffPoint( const CGPoint a, const CGPoint b );
CGFloat				DiffPointSquaredLength( const CGPoint a, const CGPoint b );
CGPoint				SumPoint( const CGPoint a, const CGPoint b );

CGPoint				EndPoint( CGPoint origin, CGFloat angle, CGFloat length );
CGFloat				Slope( const CGPoint a, const CGPoint b );
CGFloat				AngleBetween( const CGPoint a, const CGPoint b, const CGPoint c );
CGFloat				DotProduct( const CGPoint a, const CGPoint b );
CGPoint				Intersection( const CGPoint aa, const CGPoint ab, const CGPoint ba, const CGPoint bb );
CGPoint				Intersection2( const CGPoint p1, const CGPoint p2, const CGPoint p3, const CGPoint p4 );

CGRect				CentreRectOnPoint( const CGRect inRect, const CGPoint p );
CGPoint				MapPointFromRect( const CGPoint p, const CGRect rect );
CGPoint				MapPointToRect( const CGPoint p, const CGRect rect );
CGPoint				MapPointFromRectToRect( const CGPoint p, const CGRect srcRect, const CGRect destRect );
CGRect				MapRectFromRectToRect( const CGRect inRect, const CGRect srcRect, const CGRect destRect );

CGRect				ScaleRect( const CGRect inRect, const CGFloat scale );
CGRect				ScaledRectForSize( const CGSize inSize, CGRect const fitRect );
CGRect				CentreRectInRect(const CGRect r, const CGRect cr );

CGRect				NormalizedRect( const CGRect r );

//CGPoint			PerspectiveMap( CGPoint inPoint, CGSize sourceSize, CGPoint quad[4]);

CGPoint				NearestPointOnCurve( const CGPoint inp, const CGPoint bez[4], double* tValue );
CGPoint				Bezier( const CGPoint* v, const NSInteger degree, const double t, CGPoint* Left, CGPoint* Right );

CGFloat				BezierSlope( const CGPoint bez[4], const CGFloat t );

extern const CGPoint NSNotFoundPoint;


#ifdef __cplusplus
}
#endif

