//
//  SLBackingStore.m
//  scratchpaper
//
//  Created by Adam Wulf on 11/12/12.
//
//

#import "SLBackingStore.h"
#import "SLBackingStoreManager.h"
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
    [[SLBackingStoreManager sharedInstace].delegate willSaveBackingStore:self];

    SLBackingStore* this = self;
    [this retain];
    [[SLBackingStoreManager sharedInstace].opQueue addOperationWithBlock:^{
        @synchronized(this){
            NSString* pathToBinaryData = [[SLBackingStore pathToSavedData] stringByAppendingPathComponent:[this.uuid stringByAppendingPathExtension:@"bin"]];
            [backingStoreData writeToFile:pathToBinaryData atomically:YES];
            
            NSString* pathToArrayData = [[SLBackingStore pathToSavedData] stringByAppendingPathComponent:[this.uuid stringByAppendingPathExtension:@"bez"]];
            NSMutableDictionary* dataToSave = [NSMutableDictionary dictionary];
            [dataToSave setObject:currentStrokeSegments forKey:@"currentStrokeSegments"];
            [dataToSave setObject:committedStrokes forKey:@"committedStrokes"];
            [dataToSave setObject:undoneStrokes forKey:@"undoneStrokes"];
            
            [NSKeyedArchiver archiveRootObject:dataToSave toFile:pathToArrayData];
            
            
            [[SLBackingStoreManager sharedInstace].delegate didSaveBackingStore:this];
            [this release];
        }
    }];
}

-(void) load{
    [[SLBackingStoreManager sharedInstace].delegate willLoadBackingStore:self];
    
    SLBackingStore* this = self;
    [this retain];
    [[SLBackingStoreManager sharedInstace].opQueue addOperationWithBlock:^{
        @synchronized(self){
            // TODO load a backing store
            NSString* pathToBinaryData = [[SLBackingStore pathToSavedData] stringByAppendingPathComponent:[self.uuid stringByAppendingPathExtension:@"bin"]];
            if([[NSFileManager defaultManager] fileExistsAtPath:pathToBinaryData]){
                backingStoreData = [[NSData dataWithContentsOfFile:pathToBinaryData] retain];
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
            
            //
            // debug
            //
            //
            // this code proves that the bytecount i use to malloc is the exact
            // same as the filesize byte count.
            //
            // so! what i need to do is allocate 2, maybe 3 of these void* pointers
            // and hand them out in a pool.
            //
            // that way, then a page is flushed, after its written to disk the malloc
            // isn't freed but used for the next backing store that loads data directly
            // into that memory.
            //
            // this way i'm not constantly re-allocating memory of the exact same size
            // only to free it soon after.
            //
            // http://stackoverflow.com/questions/9662490/load-file-to-nsdata-with-c
            // shows how to load a file into a pre-malloc'd are of memory
            //
            // also
            // when saving, i shouldn't bother writing to disk if the memory was blank anyways
            // instead, i should just force zero out all the memory and give it a new
            // pointer, which'll be much faster than loading in a bunch of zeros from disk.
            //
            //            memset(pointer, 0, length);
            //
            // can be used to re-set the buffer to zeroes when reusing a pointer for a blank
            // slate as opposed to reading in from disk to replace it
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:pathToBinaryData error:nil];
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            NSLog(@"length of file: %lld vs %d", fileSize, bitmapByteCount);
            
            
            if(fileSize != bitmapByteCount){
                // uh oh
                NSLog(@"backing store data file is not same size as context! %lld vs %d", fileSize, bitmapByteCount);
                [backingStoreData release];
                backingStoreData = nil;
            }
            if(!backingStoreData){
                NSLog(@"new for %@", uuid);
                backingStoreData = [[NSData dataWithBytesNoCopy:calloc(1, bitmapByteCount) length:bitmapByteCount freeWhenDone:YES] retain];
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
            CGColorSpaceRelease(colorSpace);
            
            NSLog(@"have context");
            
            [[SLBackingStoreManager sharedInstace].delegate didLoadBackingStore:self];

            NSLog(@"did tell");
            [this release];
        }
    }];
}


#pragma mark - Strokes and Undo/Redo

/**
 * to cancel a stroke, simply remove all the segments
 * from the current stroke and redisplay the view
 */
-(CGRect) cancelStroke{
    CGRect ret2 = CGRectZero;
    @synchronized(self){
        for(StrokeSegment* seg in currentStrokeSegments){
            if(CGRectEqualToRect(ret2, CGRectZero)){
                ret2 = [seg bounds];
            }else{
                ret2 = CGRectUnion(ret2, [seg bounds]);
            }
        }
        [currentStrokeSegments removeAllObjects];
    }
    return ret2;
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
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, fingerWidth / 1.5);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextSetMiterLimit(context, 20);
    CGContextSetFlatness(context, 1.0);
}

-(void) drawIntoContext:(CGContextRef)context intoBounds:(CGRect)bounds{
    @synchronized(self){
        if(backingStoreData){
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
        }else{
            // noop because i'm not loaded
        }
    }
}


#pragma mark - Dealloc

-(void) dealloc{
    CGContextRelease(cacheContext);
    [backingStoreData release];
    [uuid release];
    
    [currentStrokeSegments release];
    [committedStrokes release];
    [undoneStrokes release];
    
    [super dealloc];
}



@end
