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
    UIImageView* cachedImgView;
    __weak JotView* drawableView;
    MMShapeBuilderView* shapeBuilderView;
    
    MMRulerToolGestureRecognizer* rulerGesture;
}

@property (nonatomic, weak) JotView* drawableView;
@property (readonly) JotViewStateProxy* paperState;

-(void) undo;
-(void) redo;
-(BOOL) hasEditsToSave;
-(BOOL) hasStateLoaded;
-(void) unloadCachedPreview;
-(void) loadCachedPreview;
-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize) pagePixelSize andContext:(JotGLContext*)context;
-(void) unloadState;
-(void) saveToDisk:(void (^)(void))onComplete;
-(void) setCanvasVisible:(BOOL)isVisible;
-(void) setEditable:(BOOL)isEditable;
-(BOOL) isEditable;

// abstract
-(void) saveToDisk;
-(NSString*) pagesPath;
-(NSString*) thumbnailPath;
-(UIImage*) cachedImgViewImage;

@end
