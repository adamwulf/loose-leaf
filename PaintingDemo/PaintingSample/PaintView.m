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
    hue += 0.005;
    if(hue > 1.0) hue = 0.0;
    UIColor *color = [UIColor colorWithHue:hue saturation:0.7 brightness:1.0 alpha:1.0];
    CGContextSetStrokeColorWithColor(cacheContext, [color CGColor]);
    CGContextSetLineCap(cacheContext, kCGLineCapRound);
    CGContextSetLineWidth(cacheContext, fingerWidth / 3);
}

-(void) drawArcAtStart:(CGPoint)point1 end:(CGPoint)point2 controlPoint1:(CGPoint)ctrl1 controlPoint2:(CGPoint)ctrl2 withFingerWidth:(CGFloat)fingerWidth{
    [self tickHueWithFingerWidth:fingerWidth];
    CGContextMoveToPoint(cacheContext, point1.x, point1.y);
    CGContextAddCurveToPoint(cacheContext, ctrl1.x, ctrl1.y, ctrl2.x, ctrl2.y, point2.x, point2.y);
    
    CGContextStrokePath(cacheContext);
    
    CGRect dirtyPoint1 = CGRectMake(point1.x-10, point1.y-10, 20, 20);
    CGRect dirtyPoint2 = CGRectMake(point2.x-10, point2.y-10, 20, 20);
    CGRect rectToDraw = CGRectUnion(dirtyPoint1, dirtyPoint2);
    [self setNeedsDisplayInRect:rectToDraw];
}

-(void) drawDotAtPoint:(CGPoint)point withFingerWidth:(CGFloat)fingerWidth{
    [self tickHueWithFingerWidth:fingerWidth];
    // draw a dot at point3
    // Draw a circle (filled)
    CGFloat dotDiameter = fingerWidth / 3;
    CGRect rectToDraw = CGRectMake(point.x - .5*dotDiameter, point.y - .5*dotDiameter, dotDiameter, dotDiameter);
    CGContextFillEllipseInRect(cacheContext, rectToDraw);
    [self setNeedsDisplayInRect:rectToDraw];
}

-(void) drawLineAtStart:(CGPoint)start end:(CGPoint)end withFingerWidth:(CGFloat)fingerWidth{
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
