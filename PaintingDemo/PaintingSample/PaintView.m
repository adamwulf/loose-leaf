//
//  PaintView.m
//  PaintingSample
//
//  Created by Sean Christmann on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaintView.h"
#import "NSThread+BlockAdditions.h"

@implementation PaintView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        hue = 0.0;
        [self initContext:frame.size];
        self.backgroundColor = [UIColor clearColor];
        self.clearsContextBeforeDrawing = NO;
//        [self.layer setDrawsAsynchronously:YES];
        UILabel* lbl = [[[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 50)] autorelease];
        lbl.text = @"PaintView";
        [self addSubview:lbl];
    }
    return self;
}

- (BOOL) initContext:(CGSize)size {
	float scaleFactor = [[UIScreen mainScreen] scale];
    
	int bitmapByteCount;
	int	bitmapBytesPerRow;
    int bitsPerComponent;
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
    bitsPerComponent = 8;
	bitmapBytesPerRow = (size.width * scaleFactor * 4); // only alpha
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	bitmapByteCount = (bitmapBytesPerRow * size.height * scaleFactor);
    
    
    //
    //
    // to change to alpha only:
    //
    // colorspace should be NULL
    // bitmapBytesPerRow should be * 1
    // kCGImageAlphaPremultipliedFirst should be kCGImageAlphaOnly
    cacheContext = CGBitmapContextCreate (NULL, size.width * scaleFactor, size.height * scaleFactor, bitsPerComponent, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst); //kCGImageAlphaOnly or kCGImageAlphaPremultipliedFirst);

    CGContextScaleCTM(cacheContext, scaleFactor, scaleFactor);
    CGContextSetAllowsAntialiasing(cacheContext, YES);
    CGContextSetShouldAntialias(cacheContext, YES);
    CGContextSetAlpha(cacheContext, 1);
    CGContextSetStrokeColorWithColor(cacheContext, [[UIColor blackColor] CGColor]);
/*
    [[NSThread mainThread] performBlock:^{
        CGContextSetStrokeColorWithColor(cacheContext, [[UIColor blackColor] CGColor]);
        CGContextFillEllipseInRect(cacheContext, CGRectMake(1, 1, 1, 1));
        CGContextSetBlendMode(cacheContext, kCGBlendModeClear);
        CGContextFillEllipseInRect(cacheContext, CGRectMake(1, 1, 1, 1));
        [self setNeedsDisplayInRect:CGRectMake(1, 1, 1, 1)];
        CGContextSetBlendMode(cacheContext, kCGBlendModeNormal);
    } afterDelay:1];
 */
    return YES;
}


#pragma mark - PaintTouchViewDelegate

-(void) tickHueWithFingerWidth:(CGFloat)fingerWidth{
//    hue += 0.3;
//    if(hue > 1.0) hue = 0.0;
//    UIColor *color = [UIColor colorWithHue:hue saturation:0.7 brightness:1.0 alpha:1.0];
//    CGContextSetStrokeColorWithColor(cacheContext, [color CGColor]);
    CGContextSetLineCap(cacheContext, kCGLineCapRound);
    CGContextSetLineWidth(cacheContext, fingerWidth / 3);
}

-(void) drawArcAtStart:(CGPoint)point1 end:(CGPoint)point2 controlPoint1:(CGPoint)ctrl1 controlPoint2:(CGPoint)ctrl2 withFingerWidth:(CGFloat)fingerWidth fromView:(UIView *)view{
    
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
    
    //
    // check to see if the bezier curve intersects this
    // paint frame at all, or if we can safely ignore it
    if(CGRectIntersectsRect(self.bounds, arcBoundingBox)){
        [self tickHueWithFingerWidth:fingerWidth];
        CGContextMoveToPoint(cacheContext, point1.x, point1.y);
        CGContextAddCurveToPoint(cacheContext, ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, point2.x, point2.y);
        
        CGContextStrokePath(cacheContext);
        
        CGRect rectToDraw = CGRectInset(arcBoundingBox, -fingerWidth, -fingerWidth);
        [self setNeedsDisplayInRect:rectToDraw];
    }else{
        // doesn't intersect this paint view at all
    }
}

-(void) drawDotAtPoint:(CGPoint)point withFingerWidth:(CGFloat)fingerWidth fromView:(UIView *)view{

    point = [view convertPoint:point toView:self];

    [self tickHueWithFingerWidth:fingerWidth];
    // draw a dot at point3
    // Draw a circle (filled)
    CGFloat dotDiameter = fingerWidth / 3;
    CGRect rectToDraw = CGRectMake(point.x - .5*dotDiameter, point.y - .5*dotDiameter, dotDiameter, dotDiameter);
    CGContextFillEllipseInRect(cacheContext, rectToDraw);
    [self setNeedsDisplayInRect:rectToDraw];
}

-(void) drawLineAtStart:(CGPoint)start end:(CGPoint)end withFingerWidth:(CGFloat)fingerWidth fromView:(UIView *)view{

    start = [view convertPoint:start toView:self];
    end = [view convertPoint:end toView:self];
    
    CGContextMoveToPoint(cacheContext, start.x, start.y);
    CGContextAddLineToPoint(cacheContext, end.x, end.y);
    CGContextStrokePath(cacheContext);
    CGRect dirtyPoint1 = CGRectMake(start.x-10, start.y-10, 20, 20);
    CGRect dirtyPoint2 = CGRectMake(end.x-10, end.y-10, 20, 20);
    CGRect rectToDraw = CGRectUnion(dirtyPoint1, dirtyPoint2);
    [self setNeedsDisplayInRect:rectToDraw];
}



- (void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef cacheImage = CGBitmapContextCreateImage(cacheContext);
    CGContextDrawImage(context, self.bounds, cacheImage);
    CGImageRelease(cacheImage);
}



-(void) dealloc{
    CGContextRelease(cacheContext);
//    free(cacheBitmap);
//    cacheBitmap = nil;
    [super dealloc];
}


@end
