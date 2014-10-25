//
//  MMEditablePaperView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/24/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperView.h"
#import <TouchShape/TouchShape.h>
#import "MMRulerToolGestureRecognizer.h"
#import "MMShapeBuilderView.h"
#import <JotUI/JotUI.h>

@interface MMEditablePaperView : MMPaperView<JotViewDelegate,JotViewStateProxyDelegate>{
    __weak JotView* drawableView;
    MMShapeBuilderView* shapeBuilderView;
    
    MMRulerToolGestureRecognizer* rulerGesture;

    JotViewStateProxy* paperState;
}

+(NSString*) pagesPathForUUID:(NSString*)uuidOfPage;
+(NSString*) bundledPagesPathForUUID:(NSString*)uuidOfPage;

@property (nonatomic, weak) JotView* drawableView;
@property (readonly) JotViewStateProxy* paperState;

-(BOOL) hasEditsToSave;
-(BOOL) isStateLoaded;
-(BOOL) isStateLoading;
-(void) unloadCachedPreview;
-(void) loadCachedPreview;
-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize)pagePtSize andScale:(CGFloat)scale andContext:(JotGLContext*)context;
-(void) unloadState;
-(void) updateThumbnailVisibility;
-(void) setEditable:(BOOL)isEditable;
-(BOOL) isEditable;
-(void) cancelCurrentStrokeIfAny;

// abstract
-(void) saveToDisk:(void (^)(BOOL didSaveEdits))onComplete;
-(NSString*) bundledPagesPath;
-(NSString*) pagesPath;
-(NSString*) thumbnailPath;
-(UIImage*) cachedImgViewImage;
-(void) addDrawableViewToContentView;

@end
