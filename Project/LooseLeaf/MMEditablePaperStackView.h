//
//  MMEditablePaperStackView.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/22/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMListPaperStackView.h"
#import "MMUndoRedoButton.h"
#import "MMPaperButton.h"
#import "MMPlusButton.h"
#import "MMPolylineButton.h"
#import "MMPolygonButton.h"
#import "MMImageButton.h"
#import "MMTextButton.h"
#import "MMPencilAndPaletteView.h"
#import "MMPencilButton.h"
#import "MMColorButton.h"
#import "MMPencilEraserButton.h"
#import "MMShareButton.h"
#import "MMMapButton.h"
#import "MMRulerButton.h"
#import "MMHandButton.h"
#import "MMScissorButton.h"
#import "MMAdonitButton.h"
#import "MMPencilAndPaletteViewDelegate.h"
#import "NSThread+BlockAdditions.h"
#import "MMRotationManager.h"
#import "MMRotationManagerDelegate.h"
#import "MMStackManager.h"
#import "Constants.h"
#import "Pen.h"
#import "Eraser.h"
#import "MMScissorTool.h"
#import "PolygonTool.h"
#import "MMRulerView.h"
#import "PolygonToolDelegate.h"
#import "MMDrawingTouchGestureRecognizer.h"

@class MMMemoryProfileView;

/**
 * this class is responsible for the editable buttons and controls that show
 * outside of a page's view subviews
 */
@interface MMEditablePaperStackView : MMListPaperStackView<MMPaperViewDelegate,MMPencilAndPaletteViewDelegate,MMRotationManagerDelegate,UIScrollViewDelegate,PolygonToolDelegate,MMPageCacheManagerDelegate>{
    
    // managers
    MMStackManager* stackManager;
    
    // toolbar
    MMPlusButton* addPageSidebarButton;
    MMImageButton* insertImageButton;
    MMScissorButton* scissorButton;
    MMPencilAndPaletteView* pencilTool;
    MMPencilEraserButton* eraserButton;
    MMShareButton* shareButton;
    MMTextButton* settingsButton;

    MMUndoRedoButton* undoButton;
    MMUndoRedoButton* redoButton;

    MMRulerButton* rulerButton;
    MMHandButton* handButton;

    Pen* pen;
    Eraser* eraser;
    MMScissorTool* scissor;
    
    MMRulerView* rulerView;
}

-(void) saveStacksToDisk;

-(void) loadStacksFromDisk;

-(BOOL) hasPages;

// protected

-(void) addPageButtonTapped:(UIButton*)_button;

-(void) setButtonsVisible:(BOOL)visible;

-(void) setButtonsVisible:(BOOL)visible withDuration:(CGFloat)duration;

-(void) setMemoryView:(MMMemoryProfileView*)_memoryView;

-(void) finishedLoading;

-(BOOL) shouldPrioritizeSidebarButtonsForTaps;

-(void) bounceSidebarButton:(MMSidebarButton*)button;

@end
