//
//  SLBackingStore.h
//  scratchpaper
//
//  Created by Adam Wulf on 11/12/12.
//
//  A SLBackingStore manages the bytes that can be used as the
//  basis for a CGContext. This context is what PaintView uses to
//  draw on.
//
//  This lets us save/load these bytes on demad independant of
//  the PaintView or SLPaperView as needed

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface SLBackingStore : NSObject{
    //
    // the bitmap backing store for the strokes
    NSData* backingStoreData;
    CGContextRef cacheContext;
}

@property (nonatomic, readonly) CGContextRef cacheContext;

-(id) initWithSize:(CGSize)size;

@end
