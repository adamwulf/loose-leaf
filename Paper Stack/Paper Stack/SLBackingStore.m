//
//  SLBackingStore.m
//  scratchpaper
//
//  Created by Adam Wulf on 11/12/12.
//
//

#import "SLBackingStore.h"

@implementation SLBackingStore

@synthesize cacheContext;

/**
 * creates a CGContext that is backed by manually allocated bytes.
 *
 * this will let us save/load those bytes on demand
 *
 * this bitmap context holds all of the ink that's been drawn onto
 * this paint view
 *
 *
 * Notes for alpha-less contexts:
 *
 * to change to alpha only:
 * in the CGBitmapContextCreate, colorspace should be NULL,
 * bitmapBytesPerRow should be * 1, and
 * kCGImageAlphaPremultipliedFirst should be kCGImageAlphaOnly
 *
 * if the context doesn't have alpha it won't be natively supported
 * by the device, so when it comes time to display the data it will
 * need to be converted to proper DeviceRGB anyways
 */
-(id) initWithSize:(CGSize)size{
    if(self = [super init]){
        //
        // scale factor for high resolution screens
        float scaleFactor = [[UIScreen mainScreen] scale];
        // Declare the number of bytes per row. Each pixel in the bitmap in this
        // example is represented by 4 bytes; 8 bits each of red, green, blue, and
        // alpha.
        int	bitmapBytesPerRow = (size.width * scaleFactor * 4); // only alpha;
        int bitsPerComponent = 8;
        int bitmapByteCount = (bitmapBytesPerRow * size.height * scaleFactor);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        //
        // load the bytes that will be the backing store for the context
        backingStoreData = [[NSData dataWithBytesNoCopy:malloc(bitmapByteCount) length:bitmapByteCount freeWhenDone:YES] retain];
        
        //
        // create the bitmap context that we'll use to cache
        // the drawn strokes
        cacheContext = CGBitmapContextCreate ((void*)[backingStoreData bytes], size.width * scaleFactor, size.height * scaleFactor, bitsPerComponent, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst);
        // set scale for high res display
        CGContextScaleCTM(cacheContext, scaleFactor, scaleFactor);
        // antialias the strokes
        CGContextSetAllowsAntialiasing(cacheContext, YES);
        CGContextSetShouldAntialias(cacheContext, YES);
        // allow transparency
        CGContextSetAlpha(cacheContext, 1);
    }
    return self;
}


// when saving this context out to disk, i should be able to use
// CGBitmapContextGetData to get the raw bytes  of the data
// and then save to disk.
//
// then, reading this from disk and using these bytes again
// to initialize a context should work.
//
// in theory!
//
// void* data = CGBitmapContextGetData(cacheContext);
// NSData* dataForFile = [NSData dataWithBytesNoCopy:data length:bitmapByteCount freeWhenDone:NO];
-(void) save{
    // TODO save a backing store
}

-(void) load{
    // TODO load a backing store
}


-(void) dealloc{
    CGContextRelease(cacheContext);
    [backingStoreData release];
    [super dealloc];
}


@end
