///**********************************************************************************************************************************
///  UIBezierPath-Geometry.h
///  DrawKit �2005-2008 Apptree.net
///
///  Created by graham on 22/10/2006.
///
///	 This software is released subject to licensing conditions as detailed in DRAWKIT-LICENSING.TXT, which must accompany this source file. 
///
///**********************************************************************************************************************************


@interface UIBezierPath (Geometry)

// simple transformations

- (UIBezierPath*)		scaledPath:(CGFloat) scale;
- (UIBezierPath*)		scaledPath:(CGFloat) scale aboutPoint:(CGPoint) cp;
- (UIBezierPath*)		rotatedPath:(CGFloat) angle;
- (UIBezierPath*)		rotatedPath:(CGFloat) angle aboutPoint:(CGPoint) cp;
- (UIBezierPath*)		insetPathBy:(CGFloat) amount;
- (UIBezierPath*)		horizontallyFlippedPathAboutPoint:(CGPoint) cp;
- (UIBezierPath*)		verticallyFlippedPathAboutPoint:(CGPoint) cp;
- (UIBezierPath*)		horizontallyFlippedPath;
- (UIBezierPath*)		verticallyFlippedPath;

- (CGPoint)				centreOfBounds;
- (CGFloat)				minimumCornerAngle;

// iterating over a path using a iteration delegate:

- (UIBezierPath*)		bezierPathByIteratingWithDelegate:(id) delegate contextInfo:(void*) contextInfo;

- (UIBezierPath*)		paralleloidPathWithOffset:(CGFloat) delta;
- (UIBezierPath*)		paralleloidPathWithOffset2:(CGFloat) delta;
- (UIBezierPath*)		paralleloidPathWithOffset22:(CGFloat) delta;
- (UIBezierPath*)		offsetPathWithStartingOffset:(CGFloat) delta1 endingOffset:(CGFloat) delta2;
- (UIBezierPath*)		offsetPathWithStartingOffset2:(CGFloat) delta1 endingOffset:(CGFloat) delta2;

// interpolating flattened paths:

- (UIBezierPath*)		bezierPathByInterpolatingPath:(CGFloat) amount;

// calculating a fillet

- (UIBezierPath*)		filletPathForVertex:(CGPoint[]) vp filletSize:(CGFloat) fs;

// roughening and randomising paths

- (UIBezierPath*)		bezierPathWithFragmentedLineSegments:(CGFloat) flatness;

// zig-zags and waves

- (UIBezierPath*)		bezierPathWithZig:(CGFloat) zig zag:(CGFloat) zag;
- (UIBezierPath*)		bezierPathWithWavelength:(CGFloat) lambda amplitude:(CGFloat) amp spread:(CGFloat) spread;

// getting the outline of a stroked path:

- (UIBezierPath*)		strokedPath;
- (UIBezierPath*)		strokedPathWithStrokeWidth:(CGFloat) width;

// breaking a path apart:

- (NSArray*)			subPaths;
- (NSInteger)			countSubPaths;

// converting to and from Core Graphics paths

- (CGPathRef)			newQuartzPath;
- (CGMutablePathRef)	newMutableQuartzPath;
- (CGContextRef)		setQuartzPath;
- (void)				setQuartzPathInContext:(CGContextRef) context isNewPath:(BOOL) np;

+ (UIBezierPath*)		bezierPathWithCGPathCustom:(CGPathRef) path;
+ (UIBezierPath*)		bezierPathWithPathFromContext:(CGContextRef) context;

// finding path lengths for points and points for lengths

- (CGPoint)				pointOnPathAtLength:(CGFloat) length slope:(CGFloat*) slope;
- (CGFloat)				slopeStartingPath;
- (CGFloat)				distanceFromStartOfPathAtPoint:(CGPoint) p tolerance:(CGFloat) tol;

- (NSInteger)			pointWithinPathRegion:(CGPoint) p;

// clipping utilities:

- (void)				addInverseClip;

// path trimming

- (CGFloat)				length;
- (CGFloat)				lengthWithMaximumError:(CGFloat) maxError;
- (CGFloat)				lengthOfElement:(NSInteger) i;
- (CGFloat)				lengthOfPathFromElement:(NSInteger) startElement toElement:(NSInteger) endElement;

- (CGPoint)				firstPoint;
- (CGPoint)				lastPoint;

// trimming utilities - modified source originally from A J Houghton, see copyright notice below

- (UIBezierPath*)		bezierPathByTrimmingToLength:(CGFloat) trimLength;
- (UIBezierPath*)		bezierPathByTrimmingToLength:(CGFloat) trimLength withMaximumError:(CGFloat) maxError;

- (UIBezierPath*)		bezierPathByTrimmingFromLength:(CGFloat) trimLength;
- (UIBezierPath*)		bezierPathByTrimmingFromLength:(CGFloat) trimLength withMaximumError:(CGFloat) maxError;

- (UIBezierPath*)		bezierPathByTrimmingFromBothEnds:(CGFloat) trimLength;
- (UIBezierPath*)		bezierPathByTrimmingFromBothEnds:(CGFloat) trimLength withMaximumError:(CGFloat) maxError;

- (UIBezierPath*)		bezierPathByTrimmingFromCentre:(CGFloat) trimLength;
- (UIBezierPath*)		bezierPathByTrimmingFromCentre:(CGFloat) trimLength withMaximumError:(CGFloat) maxError;

- (UIBezierPath*)		bezierPathByTrimmingFromLength:(CGFloat) startLength toLength:(CGFloat) newLength;
- (UIBezierPath*)		bezierPathByTrimmingFromLength:(CGFloat) startLength toLength:(CGFloat) newLength withMaximumError:(CGFloat) maxError;

- (UIBezierPath*)		bezierPathWithArrowHeadForStartOfLength:(CGFloat) length angle:(CGFloat) angle closingPath:(BOOL) closeit;
- (UIBezierPath*)		bezierPathWithArrowHeadForEndOfLength:(CGFloat)length angle:(CGFloat) angle closingPath:(BOOL) closeit;

- (void)				appendPathRemovingInitialMoveToPoint:(UIBezierPath*) path;


@end



// informal protocol for iterating over the elements in a bezier path using bezierPathByIteratingWithDelegate:contextInfo:

@interface NSObject (BezierElementIterationDelegate)

- (void)				path:(UIBezierPath*) path			// the new path that the delegate can build or modify from the information given
						elementIndex:(NSInteger) element			// the element index 
						type:(CGPathElement) type		// the element type
						points:(CGPoint*) p					// list of associated points 0 = next point, 1 = cp1, 2 = cp2 (for curves), 3 = last point on subpath
						subPathIndex:(NSInteger) spi				// which subpath this is
						subPathClosed:(BOOL) spClosed		// is the subpath closed?
						contextInfo:(void*) contextInfo;	// the context info


@end

// undocumented Core Graphics:

extern CGPathRef	CGContextCopyPath( CGContextRef context );

/*
 * Bezier path utility category (trimming)
 *
 * (c) 2004 Alastair J. Houghton
 * All Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *   3. The name of the author of this software may not be used to endorse
 *      or promote products derived from the software without specific prior
 *      written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER "AS IS" AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT OWNER BE LIABLE FOR ANY DIRECT, INDIRECT,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */


void	subdivideBezierAtT(const CGPoint bez[4], CGPoint bez1[4], CGPoint bez2[4], CGFloat t);

