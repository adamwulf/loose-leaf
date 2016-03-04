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

    // we want to be able to track extremely
    // efficiently 1) if we have a thumbnail loaded,
    // and 2) if we have (or don't) a thumbnail at all
    UIImage* cachedImgViewImage;
    // this defaults to NO, which means we'll try to
    // load a thumbnail. if an image does not exist
    // on disk, then we'll set this to YES which will
    // prevent any more thumbnail loads until this page
    // is saved
    BOOL definitelyDoesNotHaveAnInkThumbnail;
    BOOL isLoadingCachedInkThumbnailFromDisk;

    // YES if the file exists at the path, NO
    // if it *might* exist
    BOOL fileExistsAtInkPath;
    BOOL fileExistsAtPlistPath;
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
