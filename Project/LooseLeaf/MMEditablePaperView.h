//
//  MMEditablePaperView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/24/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperView.h"
#import <JotUI/JotUI.h>
#import <TouchShape/TouchShape.h>
#import "MMRulerToolGestureRecognizer.h"
#import "MMPolygonDebugView.h"
#import "MMPaperStateDelegate.h"
#import "MMEditablePaperViewDelegate.h"

@interface MMEditablePaperView : MMPaperView<JotViewDelegate,MMPaperStateDelegate>{
    UIImageView* cachedImgView;
    __weak JotView* drawableView;
    MMPolygonDebugView* polygonDebugView;
    
    MMRulerToolGestureRecognizer* rulerGesture;
}

@property (nonatomic, weak) JotView* drawableView;
@property (nonatomic, weak) NSObject<MMEditablePaperViewDelegate>* delegate;

+(dispatch_queue_t) loadUnloadStateQueue;

-(void) undo;
-(void) redo;
-(BOOL) hasEditsToSave;
-(BOOL) hasStateLoaded;
-(void) unloadCachedPreview;
-(void) loadCachedPreview;
-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize) pagePixelSize andContext:(JotGLContext*)context;
-(void) unloadState;
-(void) saveToDisk;
-(void) setCanvasVisible:(BOOL)isVisible;
-(void) setEditable:(BOOL)isEditable;



@end
