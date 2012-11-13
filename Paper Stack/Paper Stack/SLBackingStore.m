//
//  SLBackingStore.m
//  scratchpaper
//
//  Created by Adam Wulf on 11/12/12.
//
//

#import "SLBackingStore.h"
#import "NSThread+BlockAdditions.h"
#import "StrokeSegment.h"

@implementation SLBackingStore

@synthesize cacheContext;
@synthesize currentStrokeSegments;
@synthesize committedStrokes;
@synthesize undoneStrokes;
@synthesize uuid;

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
-(id) initWithSize:(CGSize)size andUUID:(NSString*)_uuid{
    if(self = [super init]){
        
        currentStrokeSegments = [[NSMutableArray alloc] init];
        committedStrokes = [[NSMutableArray alloc] init];
        undoneStrokes = [[NSMutableArray alloc] init];
        
        //
        // uuid is used for loading/saving
        self.uuid = _uuid;
        idealSize = size;
        //
        // load the bytes that will be the backing store for the context
        [self load];
        
    }
    return self;
}



#pragma mark - Save and Load

+(NSString*) pathToSavedData{
    // get documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    // add the data file name
    return basePath;
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
    [NSThread performBlockInBackground:^{
        @synchronized(self){
            NSString* pathToBinaryData = [[SLBackingStore pathToSavedData] stringByAppendingPathComponent:[self.uuid stringByAppendingPathExtension:@"bin"]];
            [backingStoreData writeToFile:pathToBinaryData atomically:YES];
            
            
            NSString* pathToArrayData = [[SLBackingStore pathToSavedData] stringByAppendingPathComponent:[self.uuid stringByAppendingPathExtension:@"bez"]];
            NSMutableDictionary* dataToSave = [NSMutableDictionary dictionary];
            [dataToSave setObject:currentStrokeSegments forKey:@"currentStrokeSegments"];
            [dataToSave setObject:committedStrokes forKey:@"committedStrokes"];
            [dataToSave setObject:undoneStrokes forKey:@"undoneStrokes"];
            
            [NSKeyedArchiver archiveRootObject:dataToSave toFile:pathToArrayData];
            
            NSLog(@"saved to: %@", pathToArrayData);
        }
    }];
}

-(void) load{
    @synchronized(self){
        // TODO load a backing store
        NSString* pathToBinaryData = [[SLBackingStore pathToSavedData] stringByAppendingPathComponent:[self.uuid stringByAppendingPathExtension:@"bin"]];
        if([[NSFileManager defaultManager] fileExistsAtPath:pathToBinaryData]){
            backingStoreData = [[NSData dataWithContentsOfMappedFile:pathToBinaryData] retain];
            NSLog(@"loaded for %@", uuid);
        }

        NSString* pathToArrayData = [[SLBackingStore pathToSavedData] stringByAppendingPathComponent:[self.uuid stringByAppendingPathExtension:@"bez"]];

        if([[NSFileManager defaultManager] fileExistsAtPath:pathToArrayData]){
            NSDictionary* dataFromDisk = [NSKeyedUnarchiver unarchiveObjectWithFile:pathToArrayData];
            [currentStrokeSegments removeAllObjects];
            [committedStrokes removeAllObjects];
            [undoneStrokes removeAllObjects];
            [currentStrokeSegments addObjectsFromArray:[dataFromDisk objectForKey:@"currentStrokeSegments"]];
            [committedStrokes addObjectsFromArray:[dataFromDisk objectForKey:@"committedStrokes"]];
            [undoneStrokes addObjectsFromArray:[dataFromDisk objectForKey:@"undoneStrokes"]];
            
            NSLog(@"loaded curves %d %d %d", [currentStrokeSegments count], [committedStrokes count], [undoneStrokes count]);
        }
        
        
        //
        // scale factor for high resolution screens
        float scaleFactor = [[UIScreen mainScreen] scale];
        // Declare the number of bytes per row. Each pixel in the bitmap in this
        // example is represented by 4 bytes; 8 bits each of red, green, blue, and
        // alpha.
        int	bitmapBytesPerRow = (idealSize.width * scaleFactor * 4); // only alpha;
        int bitsPerComponent = 8;
        int bitmapByteCount = (bitmapBytesPerRow * idealSize.height * scaleFactor);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        

        if(!backingStoreData){
            NSLog(@"new for %@", uuid);
            backingStoreData = [[NSData dataWithBytesNoCopy:malloc(bitmapByteCount) length:bitmapByteCount freeWhenDone:YES] retain];
        }
        
        //
        // create the bitmap context that we'll use to cache
        // the drawn strokes
        cacheContext = CGBitmapContextCreate ((void*)[backingStoreData bytes], idealSize.width * scaleFactor, idealSize.height * scaleFactor, bitsPerComponent, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst);
        // set scale for high res display
        CGContextScaleCTM(cacheContext, scaleFactor, scaleFactor);
        // antialias the strokes
        CGContextSetAllowsAntialiasing(cacheContext, YES);
        CGContextSetShouldAntialias(cacheContext, YES);
        // allow transparency
        CGContextSetAlpha(cacheContext, 1);
    }
}


#pragma mark - Strokes and Undo/Redo

/**
 * to cancel a stroke, simply remove all the segments
 * from the current stroke and redisplay the view
 */
-(BOOL) cancelStroke{
    BOOL ret = NO;
    @synchronized(self){
        ret = [currentStrokeSegments count] > 0;
        [currentStrokeSegments removeAllObjects];
    }
    return ret;
}

/**
 * to commit the stroke, draw them to our backing store
 * and reset our current stroke cache to empty
 */
-(void) commitStroke{
    @synchronized(self){
        [committedStrokes addObject:[NSArray arrayWithArray:currentStrokeSegments]];
        if([committedStrokes count] > kUndoLimit){
            [self drawStroke:[committedStrokes objectAtIndex:0] intoContext:cacheContext];
            [committedStrokes removeObjectAtIndex:0];
        }
        [undoneStrokes removeAllObjects];
        [currentStrokeSegments removeAllObjects];
    }
}

-(BOOL) undo{
    @synchronized(self){
        if([committedStrokes count]){
            [undoneStrokes addObject:[committedStrokes lastObject]];
            [committedStrokes removeLastObject];
            return YES;
        }
    }
    return NO;
}
-(BOOL) redo{
    @synchronized(self){
        if([undoneStrokes count]){
            [committedStrokes addObject:[undoneStrokes lastObject]];
            [undoneStrokes removeLastObject];
            return YES;
        }
    }
    return NO;
}


/**
 * helper method to draw our cache of stroke segments
 * to an arbitrary context
 */
-(void) drawStroke:(NSArray*)stroke intoContext:(CGContextRef)context{
    for(StrokeSegment* segment in stroke){
        // time the drawing
        // update our pen properties
        [self tickHueWithFingerWidth:segment.fingerWidth forContext:context];
        // now draw it
        CGContextAddPath(context, segment.path.CGPath);
        if(segment.shouldFillInsteadOfStroke){
            CGContextFillPath(context);
        }else{
            CGContextStrokePath(context);
        }
    }
}


#pragma mark - Drawing

/**
 * TODO: refactor into proper Pen class
 *
 * sets some basic pen properties of the context
 */
-(void) tickHueWithFingerWidth:(CGFloat)fingerWidth forContext:(CGContextRef)context{
    //    hue += 0.3;
    //    if(hue > 1.0) hue = 0.0;
    //    UIColor *color = [UIColor colorWithHue:hue saturation:0.7 brightness:1.0 alpha:1.0];
    //    CGContextSetStrokeColorWithColor(cacheContext, [color CGColor]);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, fingerWidth / 1.5);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextSetMiterLimit(context, 20);
    CGContextSetFlatness(context, 1.0);
}

-(void) drawIntoContext:(CGContextRef)context intoBounds:(CGRect)bounds{
    CGImageRef cacheImage = CGBitmapContextCreateImage(cacheContext);
    CGContextDrawImage(context, bounds, cacheImage);
    CGImageRelease(cacheImage);
    
    //
    // draw all the undo states
    for(NSArray* stroke in committedStrokes){
        [self drawStroke:stroke intoContext:context];
    }
    
    //
    // draw the active stroke, if any, to the screen context
    [self drawStroke:currentStrokeSegments intoContext:context];
}


#pragma mark - Dealloc

-(void) dealloc{
    CGContextRelease(cacheContext);
    [backingStoreData release];
    [super dealloc];
}



@end
