//
//  SLBackingStore.m
//  scratchpaper
//
//  Created by Adam Wulf on 11/12/12.
//
//

#import "SLBackingStore.h"
#import "NSThread+BlockAdditions.h"

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
        [self load];
        if(!backingStoreData){
            NSLog(@"new for %@", uuid);
            backingStoreData = [[NSData dataWithBytesNoCopy:malloc(bitmapByteCount) length:bitmapByteCount freeWhenDone:YES] retain];
        }

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
        NSString* pathToBinaryData = [[SLBackingStore pathToSavedData] stringByAppendingPathComponent:[self.uuid stringByAppendingPathExtension:@"bin"]];
        [backingStoreData writeToFile:pathToBinaryData atomically:YES];
        
        
        NSString* pathToArrayData = [[SLBackingStore pathToSavedData] stringByAppendingPathComponent:[self.uuid stringByAppendingPathExtension:@"bez"]];
        NSMutableDictionary* dataToSave = [NSMutableDictionary dictionary];
        [dataToSave setObject:currentStrokeSegments forKey:@"currentStrokeSegments"];
        [dataToSave setObject:committedStrokes forKey:@"committedStrokes"];
        [dataToSave setObject:undoneStrokes forKey:@"undoneStrokes"];
        
        [NSKeyedArchiver archiveRootObject:dataToSave toFile:pathToArrayData];
        
        NSLog(@"saved to: %@", pathToArrayData);
    }];
}

-(void) load{
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
}


-(void) dealloc{
    CGContextRelease(cacheContext);
    [backingStoreData release];
    [super dealloc];
}


@end
