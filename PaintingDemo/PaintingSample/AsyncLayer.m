//
//  AsyncLayer.m
//  PaintingSample
//
//  Created by Adam Wulf on 9/7/12.
//
//

#import "AsyncLayer.h"

@implementation AsyncLayer

@synthesize cacheContext;



-(void) drawInContext:(CGContextRef)context{
    CGImageRef cacheImage = CGBitmapContextCreateImage(cacheContext);
    CGContextDrawImage(context, self.bounds, cacheImage);
    CGImageRelease(cacheImage);
    
    
    /*
    CGRect clipRect = CGContextGetClipBoundingBox(context);
    clipRect = CGRectInset(clipRect, .5, .5);
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextStrokeRect(context, clipRect);
     */
}

@end
