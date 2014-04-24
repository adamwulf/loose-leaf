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
#import "MMShapeBuilderView.h"

@interface MMEditablePaperView : MMPaperView<JotViewDelegate,JotViewStateProxyDelegate>{
    __weak JotView* drawableView;
    MMShapeBuilderView* shapeBuilderView;
    
    MMRulerToolGestureRecognizer* rulerGesture;
}

@property (nonatomic, weak) JotView* drawableView;
@property (readonly) JotViewStateProxy* paperState;

+(dispatch_queue_t) importThumbnailQueue;

-(void) undo;
-(void) redo;
-(BOOL) hasEditsToSave;
-(BOOL) hasStateLoaded;
-(void) unloadCachedPreview;
-(void) loadCachedPreview;
-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize) pagePixelSize andContext:(JotGLContext*)context;
-(void) unloadState;
-(void) saveToDisk:(void (^)(BOOL didSaveEdits))onComplete;
-(void) setCanvasVisible:(BOOL)isVisible;
-(void) setEditable:(BOOL)isEditable;
-(BOOL) isEditable;

// abstract
-(void) saveToDisk;
-(NSString*) pagesPath;
-(NSString*) thumbnailPath;
-(UIImage*) cachedImgViewImage;
-(void) addDrawableViewToContentView;

@end
