//
//  MMEditablePaperView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/24/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMPaperView.h"
#import <JotUI/JotUI.h>

@interface MMEditablePaperView : MMPaperView<JotViewDelegate>{
    UIImageView* cachedImgView;
    __weak JotView* drawableView;
}

@property (nonatomic, weak) JotView* drawableView;

-(void) undo;
-(void) redo;
-(BOOL) hasEditsToSave;
-(void) loadStateAsynchronously:(BOOL)async withSize:(CGSize) pagePixelSize andContext:(EAGLContext*)context andThen:(void (^)())block;
-(void) setBackgroundTextureToStartPage;
-(void) unloadState;
-(void) forceSaveToDisk;
-(void) saveToDisk;
-(void) setCanvasVisible:(BOOL)isVisible;
-(void) setEditable:(BOOL)isEditable;

@end
