//
//  PaintView.m
//  PaintingSample
//
//  Created by Sean Christmann on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PaintView.h"

@implementation PaintView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        hue = 0.0;
        [self initContext:frame.size];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (BOOL) initContext:(CGSize)size {
	float scaleFactor = [[UIScreen mainScreen] scale];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    
    
	int bitmapByteCount;
	int	bitmapBytesPerRow;
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow = (size.width * 4);
	bitmapByteCount = (bitmapBytesPerRow * size.height);
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	cacheBitmap = malloc( bitmapByteCount );
	if (cacheBitmap == NULL){
		return NO;
	}
//	cacheContext = CGBitmapContextCreate (cacheBitmap, size.width, size.height, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst);
    cacheContext = CGBitmapContextCreate(NULL,
                                                 size.width * scaleFactor, size.height * scaleFactor,
                                                 8, size.width * scaleFactor * 4, colorSpace,
                                                 kCGImageAlphaPremultipliedFirst);
    CGContextScaleCTM(cacheContext, scaleFactor, scaleFactor);
    CGContextSetAllowsAntialiasing(cacheContext, YES);
    CGContextSetShouldAntialias(cacheContext, YES);

	
    // Somewhere in initialization code.
    UIColor *pattern = [UIColor colorWithPatternImage:[UIImage imageNamed:@"graphite.png"]];
    fillColor = [pattern CGColor];
    strokeColor = [pattern CGColor];
    
    return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGFloat newFingerWidth = [[touch valueForKey:@"pathMajorRadius"] floatValue];
    if(newFingerWidth < 2) newFingerWidth = 2;
    if(abs(newFingerWidth - fingerWidth) > 1){
        if(newFingerWidth > fingerWidth) fingerWidth += 1;
        if(newFingerWidth < fingerWidth) fingerWidth -= 1;
    }
    fingerWidth = newFingerWidth;
    point0 = CGPointMake(-1, -1);
    point1 = CGPointMake(-1, -1); // previous previous point
    point2 = CGPointMake(-1, -1); // previous touch point
    point3 = [touch locationInView:self]; // current touch point
    [self drawToCache:NO];
    [super touchesBegan:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGFloat newFingerWidth = [[touch valueForKey:@"pathMajorRadius"] floatValue];
    if(newFingerWidth < 2) newFingerWidth = 2;
    if(abs(newFingerWidth - fingerWidth) > 1){
        if(newFingerWidth > fingerWidth) fingerWidth += 1;
        if(newFingerWidth < fingerWidth) fingerWidth -= 1;
    }
    fingerWidth = newFingerWidth;
    point0 = point1;
    point1 = point2;
    point2 = point3;
    point3 = [touch locationInView:self];
    [self drawToCache:NO];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGFloat newFingerWidth = [[touch valueForKey:@"pathMajorRadius"] floatValue];
    if(newFingerWidth < 2) newFingerWidth = 2;
    if(abs(newFingerWidth - fingerWidth) > 1){
        if(newFingerWidth > fingerWidth) fingerWidth += 1;
        if(newFingerWidth < fingerWidth) fingerWidth -= 1;
    }else{
        fingerWidth = newFingerWidth;
    }
    point0 = point1;
    point1 = point2;
    point2 = point3;
    point3 = [touch locationInView:self];
    [self drawToCache:YES];
}
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
//    UITouch *touch = [touches anyObject];
}

- (void) drawToCache:(BOOL)lineEnded {
    hue += 0.005;
    if(hue > 1.0) hue = 0.0;
    UIColor *color = [UIColor colorWithHue:hue saturation:0.7 brightness:1.0 alpha:1.0];

    CGContextSetStrokeColorWithColor(cacheContext, [color CGColor]);
    CGContextSetFillColorWithColor(cacheContext, [color CGColor]);
    CGContextSetLineCap(cacheContext, kCGLineCapRound);
    CGContextSetLineWidth(cacheContext, fingerWidth / 3);
    CGContextSetPatternPhase(cacheContext, CGSizeMake(rand()%52, rand()%52));
    
    // Probably in |draw| method call.
    CGContextSetStrokeColorWithColor(cacheContext, strokeColor);
    CGContextSetFillColorWithColor(cacheContext, fillColor);
    

    if(point1.x > -1){
        CGContextSetBlendMode(cacheContext, kCGBlendModeOverlay);
        double x0 = (point0.x > -1) ? point0.x : point1.x; //after 4 touches we should have a back anchor point, if not, use the current anchor point
        double y0 = (point0.y > -1) ? point0.y : point1.y; //after 4 touches we should have a back anchor point, if not, use the current anchor point
        double x1 = point1.x;
        double y1 = point1.y;
        double x2 = point2.x;
        double y2 = point2.y;
        double x3 = point3.x;
        double y3 = point3.y;
        // Assume we need to calculate the control
        // points between (x1,y1) and (x2,y2).
        // Then x0,y0 - the previous vertex,
        //      x3,y3 - the next one.
        
        double xc1 = (x0 + x1) / 2.0;
        double yc1 = (y0 + y1) / 2.0;
        double xc2 = (x1 + x2) / 2.0;
        double yc2 = (y1 + y2) / 2.0;
        double xc3 = (x2 + x3) / 2.0;
        double yc3 = (y2 + y3) / 2.0;
        
        double len1 = sqrt((x1-x0) * (x1-x0) + (y1-y0) * (y1-y0));
        double len2 = sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1));
        double len3 = sqrt((x3-x2) * (x3-x2) + (y3-y2) * (y3-y2));
        
        double k1 = len1 / (len1 + len2);
        double k2 = len2 / (len2 + len3);
        
        double xm1 = xc1 + (xc2 - xc1) * k1;
        double ym1 = yc1 + (yc2 - yc1) * k1;
        
        double xm2 = xc2 + (xc3 - xc2) * k2;
        double ym2 = yc2 + (yc3 - yc2) * k2;
        double smooth_value = 0.8;
        // Resulting control points. Here smooth_value is mentioned
        // above coefficient K whose value should be in range [0...1].
        float ctrl1_x = xm1 + (xc2 - xm1) * smooth_value + x1 - xm1;
        float ctrl1_y = ym1 + (yc2 - ym1) * smooth_value + y1 - ym1;
        
        float ctrl2_x = xm2 + (xc2 - xm2) * smooth_value + x2 - xm2;
        float ctrl2_y = ym2 + (yc2 - ym2) * smooth_value + y2 - ym2;
        
        CGContextMoveToPoint(cacheContext, point1.x, point1.y);
        CGContextAddCurveToPoint(cacheContext, ctrl1_x, ctrl1_y, ctrl2_x, ctrl2_y, point2.x, point2.y);
        
        CGContextSetLineWidth(cacheContext, fingerWidth / 3 + 1);
        CGContextSetLineCap(cacheContext, kCGLineCapButt);
        CGContextSetAlpha(cacheContext, .5);
        CGContextStrokePath(cacheContext);
        
        CGContextMoveToPoint(cacheContext, point1.x, point1.y);
        CGContextAddCurveToPoint(cacheContext, ctrl1_x, ctrl1_y, ctrl2_x, ctrl2_y, point2.x, point2.y);
        
        CGContextSetLineCap(cacheContext, kCGLineCapRound);
        CGContextSetLineWidth(cacheContext, fingerWidth / 3);
        CGContextSetAlpha(cacheContext, .8);
        CGContextStrokePath(cacheContext);
        
        CGRect dirtyPoint1 = CGRectMake(point1.x-10, point1.y-10, 20, 20);
        CGRect dirtyPoint2 = CGRectMake(point2.x-10, point2.y-10, 20, 20);
        [self setNeedsDisplayInRect:CGRectUnion(dirtyPoint1, dirtyPoint2)];
    }else if(point2.x == -1){
        CGContextSetLineWidth(cacheContext, fingerWidth / 3);
        CGContextSetAlpha(cacheContext, 1);
        // draw a dot at point3
        // Draw a circle (filled)
        CGFloat dotDiameter = fingerWidth / 3;
        CGRect ellipseRect = CGRectMake(point3.x - .5*dotDiameter, point3.y - .5*dotDiameter, dotDiameter, dotDiameter);
        CGContextFillEllipseInRect(cacheContext, ellipseRect);
        [self setNeedsDisplayInRect:ellipseRect];
        
    }else if(point1.x == -1 && lineEnded){
        CGContextSetLineWidth(cacheContext, fingerWidth / 3);
        CGContextSetAlpha(cacheContext, 1);
        CGContextMoveToPoint(cacheContext, point2.x, point2.y);
        CGContextAddLineToPoint(cacheContext, point3.x, point3.y);
        CGContextStrokePath(cacheContext);
        CGRect dirtyPoint1 = CGRectMake(point2.x-10, point2.y-10, 20, 20);
        CGRect dirtyPoint2 = CGRectMake(point3.x-10, point3.y-10, 20, 20);
        [self setNeedsDisplayInRect:CGRectUnion(dirtyPoint1, dirtyPoint2)];
    }
}


- (void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef cacheImage = CGBitmapContextCreateImage(cacheContext);
    CGContextDrawImage(context, self.bounds, cacheImage);
    CGImageRelease(cacheImage);
}

@end
