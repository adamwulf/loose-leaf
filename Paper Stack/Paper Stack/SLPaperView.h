//
//  SLPaperView.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/8/12.
//  Copyright (c) 2012 Skylight, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "SLPaperViewDelegate.h"
#import "SLDrawingGestureRecognizer.h"
#import "SLPanAndPinchGestureRecognizer.h"
#import "SLShadowedView.h"
#import "PaintView.h"
#import "PaintableViewDelegate.h"
#import "SLBackingStoreManagerDelegate.h"
#import "SLRenderManagerDelegate.h"

@interface SLPaperView : SLShadowedView<PaintableViewDelegate,SLBackingStoreManagerDelegate,SLRenderManagerDelegate>{
    
    NSString* uuid;
    NSDate* lastModified;
    NSDate* lastSaved;
    
    NSObject<SLPaperViewDelegate>* delegate;
    
    // properties for pinch gesture
    CGFloat preGestureScale;
    CGPoint normalizedLocationOfScale;
    
    // properties for pan gesture
    CGPoint firstLocationOfPanGestureInSuperView;
    CGRect frameOfPageAtBeginningOfGesture;
    NSInteger lastNumberOfTouchesForPanGesture;

    BOOL isBeingPannedAndZoomed;
    
    SLPanAndPinchGestureRecognizer* panGesture;
    
    BOOL isBrandNewPage;
    
    SLDrawingGestureRecognizer* drawGesture;
    UIActivityIndicatorView* activity;
    
    BOOL isFlushingPaintView;
    CGSize paintViewFrameSize;
    PaintView* paintView;
    UIImageView* thumbnailImageView;
    
    CGSize initialPageSize;
}

@property (nonatomic, readonly) NSString* uuid;
@property (nonatomic, readonly) NSDate* lastModified;
@property (nonatomic, readonly) CGSize initialPageSize;
@property (nonatomic, assign) NSObject<SLPaperViewDelegate>* delegate;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, readonly) BOOL isBeingPannedAndZoomed;
// this will only be true if the bezel gesture is triggered and the page is actively being panned
@property (nonatomic, readonly) NSInteger numberOfTimesExitedBezel;
@property (nonatomic, assign) BOOL isBrandNewPage;

- (id)initWithFrame:(CGRect)frame andUUID:(NSString*)_uuid;

-(BOOL) willExitToBezel:(SLBezelDirection)bezelDirection;

-(void) cancelAllGestures;
-(void) disableAllGestures;
-(void) enableAllGestures;

-(void) undo;
-(void) redo;

-(void) save;
-(void) flush;
-(BOOL) isFlushed;
-(void) load;




// thumbnail
-(NSArray*) arrayOfBlocksForDrawing;


@end
