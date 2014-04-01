//
//  MMBufferedImageView.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/30/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMBufferedImageView.h"

@implementation MMBufferedImageView{
    UIImage* image;
    CGFloat targetSize;
}

@synthesize image;

CGFloat buffer = 2;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.clearsContextBeforeDrawing = YES;
        targetSize = self.bounds.size.height - 2*buffer;
    }
    return self;
}

-(void) setImage:(UIImage *)_image{
    image = _image;
//    [self setNeedsDisplay];
}

-(void) drawRect:(CGRect)rect{
    if(image){
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat maxDim = self.bounds.size.height - 2*buffer;
        CGSize sizeToDraw = image.size;
        CGFloat scaleToDraw = 1.0;
        if(sizeToDraw.width >= sizeToDraw.height && sizeToDraw.width > maxDim){
            scaleToDraw = maxDim / sizeToDraw.width;
            sizeToDraw.height *= maxDim / sizeToDraw.width;
            sizeToDraw.width = maxDim;
        }else if(sizeToDraw.height >= sizeToDraw.width && sizeToDraw.height > maxDim){
            scaleToDraw = maxDim / sizeToDraw.height;
            sizeToDraw.width *= maxDim / sizeToDraw.height;
            sizeToDraw.height = maxDim;
        }
        
        CGContextSetAllowsAntialiasing(context, true);
        CGContextSetShouldAntialias(context, true);
        
        CGRect r = CGRectMake(buffer + (maxDim - sizeToDraw.width)/2, buffer + (maxDim - sizeToDraw.height)/2, sizeToDraw.width, sizeToDraw.height);
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, r.origin.x, r.origin.y);
        CGContextScaleCTM(context, scaleToDraw, scaleToDraw);
        [image drawAtPoint:CGPointZero];
        
        CGContextRestoreGState(context);
        
        CGContextSetLineWidth(context, 1);
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextStrokeRect(context, CGRectInset(r, .5, .5));
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextStrokeRect(context, CGRectInset(r, 1.5, 1.5));
    }
}

@end
