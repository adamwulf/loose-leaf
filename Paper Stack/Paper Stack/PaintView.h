//
//  PaintView.h
//  PaintingSample
//
//  Created by Sean Christmann on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DrawKit-iOS/DrawKit-iOS.h>
#import <QuartzCore/QuartzCore.h>
#import "PaintableViewDelegate.h"
#import "PaintTouchViewDelegate.h"
#import "SLBackingStore.h"

@class SLPaperView;

@interface PaintView : UIView<PaintTouchViewDelegate> {
    //
    // the bitmap backing store for the strokes
    //
    // this handles creating the cgcontext to draw to
    // as well as saving to/from disk
    SLBackingStore* backingStore;
    
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
    
    //
    // the delegate that tells us which views
    // are "above" this view so that we can clip
    // the strokes properly
    NSObject<PaintableViewDelegate>* delegate;
    //
    // the clip path for this view only
    UIBezierPath* clipPath;

    //
    // the clip path that's cached for all views
    // above this view. this needs to be updated
    // whenever a view above us is moved/added/deleted
    UIBezierPath* cachedClipPath;
    
    //
    // for debugging
    CGFloat hue;
}

@property (nonatomic, assign) NSObject<PaintableViewDelegate>* delegate;

@property (nonatomic, retain) UIBezierPath* clipPath;

-(void) updateClipPath;

-(void) undo;
-(void) redo;

@end
