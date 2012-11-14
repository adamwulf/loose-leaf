//
//  PaintView.m
//  PaintingSample
//
//  Created by Sean Christmann on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaintView.h"
#import "NSThread+BlockAdditions.h"
#import "SLPaperView.h"
#import "StrokeSegment.h"

@implementation PaintView

@synthesize delegate;
@synthesize clipPath;
@synthesize uuid;

- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid{
    self = [super initWithFrame:frame];
    if (self) {
        self.uuid = _uuid;
        hue = 4.0;
        self.backgroundColor = [UIColor clearColor];
        self.clearsContextBeforeDrawing = NO;
        backingStoreSize = frame.size;
    }
    return self;
}

-(void) flush{
    [backingStore save];
    [backingStore release];
    backingStore = nil;
}
-(void) save{
    [backingStore save];
}
-(void) load{
    if(!backingStore){
        backingStore = [[SLBackingStore alloc] initWithSize:backingStoreSize andUUID:self.uuid];
        [backingStore load];
    }
}

#pragma mark - Drawing

/**
 * draws the input curve onto the bitmap context, taking into
 * account all views that may be obstructing this PaintView
 *
 * the result is that only the user-visible portions of the
 * PaintView will recieve ink
 *
 * TODO: change path from fill to stroke
 */
-(void) drawArcAtStart:(CGPoint)point1 end:(CGPoint)point2 controlPoint1:(CGPoint)ctrl1 controlPoint2:(CGPoint)ctrl2 withFingerWidth:(CGFloat)fingerWidth fromView:(SLPaperView *)view{
    
    // convert points from their touched view
    // to this view so that we can see if
    // they even hit us or not
    point1 = [view convertPoint:point1 toView:self];
    point2 = [view convertPoint:point2 toView:self];
    ctrl1 = [view convertPoint:ctrl1 toView:self];
    ctrl2 = [view convertPoint:ctrl2 toView:self];
    
    // find the extreme points of the bezier curve
    CGFloat minX = MIN(MIN(MIN(point1.x, point2.x), ctrl1.x), ctrl2.x);
    CGFloat minY = MIN(MIN(MIN(point1.y, point2.y), ctrl1.y), ctrl2.y);
    CGFloat maxX = MAX(MAX(MAX(point1.x, point2.x), ctrl1.x), ctrl2.x);
    CGFloat maxY = MAX(MAX(MAX(point1.y, point2.y), ctrl1.y), ctrl2.y);
    
    //
    // calculate a reasonable bounding box for this bezier curve.
    //
    // TODO: calculate a tighter bounding box for the curve
    //
    // we're actually a bit generous with this bounding box, we could
    // make it tighter ( http://processingjs.nihongoresources.com/bezierinfo/#extremities )
    // but this is fast and safe too
    __block CGRect rectToDraw = CGRectMake(minX, minY, maxX-minX, maxY-minY);
    rectToDraw = CGRectInset(rectToDraw, -fingerWidth, -fingerWidth);

    //
    // check to see if the bezier curve intersects this
    // paint frame at all, or if we can safely ignore it
    if(CGRectIntersectsRect(self.bounds, rectToDraw)){
        // calculate the clip path if needed
        [self updateCachedClipPathForContext:backingStore.cacheContext andDraw:NO];
        //
        // calculate a closed path for the input stroke
        UIBezierPath* strokedPath = [UIBezierPath bezierPath];
        [strokedPath moveToPoint:point1];
        [strokedPath addCurveToPoint:point2 controlPoint1:ctrl1 controlPoint2:ctrl2];
        //
        // now we know the stroke, so clip it to our
        // visible area
        UIBezierPath* clippedPath = [strokedPath unclosedPathFromIntersectionWithPath:cachedClipPath];

        // TODO should I check if clippedPath is empty here?
        if([clippedPath isEmpty]){
            NSLog(@"drawing empty path!");
        }

        [backingStore.currentStrokeSegments addObject:[StrokeSegment strokeWithFingerWidth:fingerWidth andRect:rectToDraw andPath:clippedPath]];
        
        [self setNeedsDisplayInRect:rectToDraw];
    }else{
        // doesn't intersect this paint view at all,
        // so don't draw it
    }
}

//
// TODO: dots are currently only drawing on the lowest PaintView,
// but should respect the clip path
-(void) drawDotAtPoint:(CGPoint)point withFingerWidth:(CGFloat)fingerWidth fromView:(SLPaperView *)view{

    // convert point from its touched view
    // to this view so that we can see if
    // they even hit us or not
    point = [view convertPoint:point toView:self];
    
    // draw a dot at point3
    // Draw a circle (filled)
    CGFloat dotDiameter = fingerWidth / 3;
    CGRect rectToDisplay = CGRectMake(point.x - .5*dotDiameter, point.y - .5*dotDiameter, dotDiameter, dotDiameter);

    // calculate the clip path if needed
    [self updateCachedClipPathForContext:backingStore.cacheContext andDraw:NO];

    // only draw the point if it is inside of
    // our visible area
    if([cachedClipPath containsPoint:point]){
        [backingStore.currentStrokeSegments addObject:[StrokeSegment strokeWithFingerWidth:fingerWidth andRect:rectToDisplay andPath:[UIBezierPath bezierPathWithOvalInRect:rectToDisplay] andFill:YES]];
        [self setNeedsDisplayInRect:rectToDisplay];
    }
}

//
// TODO: mirror the line drawing as is done in the arc drawing
-(void) drawLineAtStart:(CGPoint)start end:(CGPoint)end withFingerWidth:(CGFloat)fingerWidth fromView:(SLPaperView *)view{

    // convert points from their touched view
    // to this view so that we can see if
    // they even hit us or not
    start = [view convertPoint:start toView:self];
    end = [view convertPoint:end toView:self];
    
    // find the extreme points of the bezier curve
    CGFloat minX = MIN(start.x, end.x) - 10;
    CGFloat minY = MIN(start.y, end.y) - 10;
    CGFloat maxX = MAX(start.x, end.x) + 10;
    CGFloat maxY = MAX(start.y, end.y) + 10;
    
    //
    // calculate a reasonable bounding box for this bezier curve.
    //
    // we're actually a bit generous with this bounding box, we could
    // make it tighter ( http://processingjs.nihongoresources.com/bezierinfo/#extremities )
    // but this is fast and safe too
    CGRect rectToDraw = CGRectMake(minX, minY, maxX-minX, maxY-minY);
    rectToDraw = CGRectInset(rectToDraw, -fingerWidth, -fingerWidth);

    //
    // only draw if the line intersects us
    if(CGRectIntersectsRect(self.bounds, rectToDraw)){
        // calculate the clip path if needed
        [self updateCachedClipPathForContext:backingStore.cacheContext andDraw:NO];
        // calculate the line drawn...
        UIBezierPath* strokedPath = [UIBezierPath bezierPath];
        [strokedPath moveToPoint:start];
        [strokedPath addLineToPoint:end];
        // ...and clip that line to our visible area
        UIBezierPath* clippedPath = [strokedPath unclosedPathFromIntersectionWithPath:cachedClipPath];

        [backingStore.currentStrokeSegments addObject:[StrokeSegment strokeWithFingerWidth:fingerWidth andRect:rectToDraw andPath:clippedPath]];
        [self setNeedsDisplayInRect:rectToDraw];
    }else{
        // doesn't intersect our view at all
    }
}

#pragma mark - Strokes and Undo/Redo

/**
 * to cancel a stroke, simply remove all the segments
 * from the current stroke and redisplay the view
 */
-(void) cancelStroke{
    CGRect affectedCancelledRect = [backingStore cancelStroke];
    if(!CGRectEqualToRect(affectedCancelledRect, CGRectZero)){
        [self setNeedsDisplayInRect:affectedCancelledRect];
    }
}
/**
 * to commit the stroke, draw them to our backing store
 * and reset our current stroke cache to empty
 */
-(void) commitStroke{
    [backingStore commitStroke];
}

-(void) undo{
    if([backingStore undo]){
        [self setNeedsDisplay];
    }
}
-(void) redo{
    if([backingStore redo]){
        [self setNeedsDisplay];
    }
}


#pragma mark - UIView drawing

/**
 *
 * this is the draw rect that's used to show the paint
 *
 * it's commented out so that i can test only clipping
 * with paths in the below fuction w/o worrying about the
 * imagecontext
 *
 * TODO
 * future optimization to only stroke the StrokeSegments that
 * overlap the input rect
 */
- (void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [backingStore drawIntoContext:context intoBounds:self.bounds];
    
    if([delegate shouldDrawClipPath]){
        [self updateCachedClipPathForContext:context andDraw:YES];
    }
}



#pragma mark - Clipping

/**
 * this method returns the bezier that describes the clipped
 * area of this paint view. the default is the bounds of
 * this view
 */
-(UIBezierPath*) clipPath{
    if(!clipPath || [clipPath isEmpty]){
        [clipPath release];
        clipPath = [[UIBezierPath bezierPathWithRect:self.bounds] retain];
    }
    return clipPath;
}

/**
 * this method updates our cached clipping path for any strokes
 * that the user draws to this view.
 *
 * this method is expensive and should only be called when a view
 * "above" us is added/deleted/moved/changed etc
 */
-(void) updateClipPath{
    [cachedClipPath release];
    cachedClipPath = nil;
    [self updateCachedClipPathForContext:backingStore.cacheContext andDraw:NO];
}


/**
 * this is the work horse for clipping the pen
 *
 * loop through every view that's user-visible above
 * this view, and subtract each views visible area from
 * this view's visible area.
 *
 * the resulting UIBezierPath contains all of the area
 * that the user is allowed to draw in
 *
 * this method will store that resulting UIBezierPath in
 * cachedClipPath
 *
 * this path will only be updated if it is nil, otherwise
 * this method will do nothing.
 *
 * The clipping path will default to the view's bounds, unless
 * there is a custom clip path set in the view's clipPath property
 *
 * if we wanted to actually clip a context, then the following code
 * would do that with our cached clip path:
 *       CGContextAddRect(context, CGRectInfinite);
 *       CGContextAddPath(context, cachedClipPath.CGPath);
 *       CGContextEOClip(context);
 *
 * TODO: cache the value of my clip path + the views above me, so that if any view below me moves it
 * doesn't have to recalculate from scratch
 */
-(void) updateCachedClipPathForContext:(CGContextRef) context andDraw:(BOOL)draw{
    // timeBlock: is for debugging time profiling
//    [NSThread timeBlock:^{
        if(!cachedClipPath){
            // first, calculate our base clip path according to our own
            // bounds and visible area
            UIBezierPath* theClipPath = [self.clipPath bezierPathByFlatteningPathAndImmutable:YES];
            //
            // now, we need to subtract the views above us from our
            // visible area. this will clip out the portions of our view
            // that are hidden behind other views
            //
            // TODO: make sure we support 
            NSArray* overViews = [delegate paintableViewsAbove:self];
            for(PaintView* aView in overViews){
                // get a flat path of the view above me that we can operate on
                UIBezierPath* aClipPath = [aView.clipPath bezierPathByFlatteningPath];
                // if i'm rotated, unrotate my own rotation first
                [aClipPath applyTransform:CGAffineTransformInvert(self.delegate.transform)];
                // then add its own rotation
                [aClipPath applyTransform:aView.transform];
                // then adjust for offset
                CGPoint offset = [self convertPoint:aView.bounds.origin fromView:aView];
                [aClipPath applyTransform:CGAffineTransformMakeTranslation(offset.x, offset.y)];
                // now subtract it from my visible area
                theClipPath = [theClipPath pathFromDifferenceWithPath:aClipPath];
            }
            // update my cached clip path to reuse later
            [cachedClipPath release];
            cachedClipPath = [[theClipPath bezierPathByFlatteningPath] retain];
        }
        
        //
        // debug only:
        //
        // draw the clip path onto this view
        if(draw){
            CGContextSetStrokeColorWithColor(context, [self randomColor].CGColor);
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineWidth(context, 2);
            
            CGContextAddPath(context, cachedClipPath.CGPath);
            CGContextStrokePath(context);
        }
//    }];
}



#pragma mark - Helpers

/**
 * return true if this view contains the entire arc
 * insdie of it's user-visible area regardless
 * of views above or below this view
 *
 * TODO: this funtion is not entirely accurate
 * if my boudning box fully contains the curve, but 
 * my clipPath contains a hole that allows some of the curve
 * to bleed through, then this would return YES but should
 * be NO
 */
-(BOOL) fullyContainsArcAtStart:(CGPoint)point1
                            end:(CGPoint)point2
                  controlPoint1:(CGPoint)ctrl1
                  controlPoint2:(CGPoint)ctrl2
                withFingerWidth:(CGFloat)fingerWidth
                       fromView:(UIView*)view{
    // convert points from their touched view
    // to this view so that we can see if
    // they even hit us or not
    point1 = [view convertPoint:point1 toView:self];
    point2 = [view convertPoint:point2 toView:self];
    ctrl1 = [view convertPoint:ctrl1 toView:self];
    ctrl2 = [view convertPoint:ctrl2 toView:self];
    
    // find the extreme points of the bezier curve
    CGFloat minX = MIN(MIN(MIN(point1.x, point2.x), ctrl1.x), ctrl2.x);
    CGFloat minY = MIN(MIN(MIN(point1.y, point2.y), ctrl1.y), ctrl2.y);
    CGFloat maxX = MAX(MAX(MAX(point1.x, point2.x), ctrl1.x), ctrl2.x);
    CGFloat maxY = MAX(MAX(MAX(point1.y, point2.y), ctrl1.y), ctrl2.y);
    
    //
    // calculate a reasonable bounding box for this bezier curve.
    //
    // we're actually a bit generous with this bounding box, we could
    // make it tighter ( http://processingjs.nihongoresources.com/bezierinfo/#extremities )
    // but this is fast and safe too
    CGRect arcBoundingBox = CGRectMake(minX, minY, maxX-minX, maxY-minY);
    
    return CGRectContainsRect(self.bounds, arcBoundingBox);
}

/**
 * generate a random color
 * TODO: kill this when the debug color stuff isn't needed anymore
 */
-(UIColor*) randomColor{
    CGFloat _hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat _saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat _brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:_hue saturation:_saturation brightness:_brightness alpha:1];
    return color;
}

-(void) dealloc{
    [backingStore release];
    [super dealloc];
}




@end
