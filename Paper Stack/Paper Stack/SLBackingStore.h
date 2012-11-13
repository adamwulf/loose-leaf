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
    CGSize idealSize;
    NSString* uuid;
    
    //
    // This array holds multiple StrokeSegment objects
    // for each segement of the user's current stroke
    //
    // this lets us keep the current stroke out of the
    // cacheContext and only rasterize it once the user
    // confirms the stroke
    NSMutableArray* currentStrokeSegments;
    NSMutableArray* committedStrokes;
    NSMutableArray* undoneStrokes;
    
}

@property (nonatomic, retain) NSString* uuid;

@property (nonatomic, readonly) CGContextRef cacheContext;

@property (nonatomic, readonly) NSMutableArray* currentStrokeSegments;
@property (nonatomic, readonly) NSMutableArray* committedStrokes;
@property (nonatomic, readonly) NSMutableArray* undoneStrokes;

-(id) initWithSize:(CGSize)size andUUID:(NSString*)uuid;
-(BOOL) cancelStroke;
-(void) commitStroke;
-(BOOL) undo;
-(BOOL) redo;

-(void) save;

-(void) drawIntoContext:(CGContextRef)context intoBounds:(CGRect)bounds;

@end
