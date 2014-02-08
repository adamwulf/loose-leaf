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
#import "MMEditablePaperViewDelegate.h"
#import "MMDrawingTouchGestureRecognizer.h"

/**
 * this class is responsible for the editable buttons and controls that show
 * outside of a page's view subviews
 */
@interface MMEditablePaperStackView : MMListPaperStackView<MMEditablePaperViewDelegate,MMPencilAndPaletteViewDelegate,MMRotationManagerDelegate,UIScrollViewDelegate,PolygonToolDelegate,MMPanGestureDelegate>{
    
    // managers
    MMStackManager* stackManager;
    
    // toolbar
    MMPaperButton* documentBackgroundSidebarButton;
    MMPlusButton* addPageSidebarButton;
    MMPolylineButton* polylineButton;
    MMImageButton* insertImageButton;
    MMScissorButton* scissorButton;
    MMTextButton* textButton;
    MMPencilAndPaletteView* pencilTool;
    MMPencilEraserButton* eraserButton;
    MMShareButton* shareButton;
    MMAdonitButton* settingsButton;
    MMMapButton* mapButton;
    
    MMUndoRedoButton* undoButton;
    MMUndoRedoButton* redoButton;

    MMRulerButton* rulerButton;
    MMHandButton* handButton;

    Pen* pen;
    Eraser* eraser;
    MMScissorTool* scissor;
    
    NSMutableSet* pagesWithLoadedCacheImages;
    MMRulerView* rulerView;
}

-(void) saveStacksToDisk;

-(void) loadStacksFromDisk;

-(BOOL) hasPages;

// protected

-(void) addPageButtonTapped:(UIButton*)_button;

-(void) setButtonsVisible:(BOOL)visible;


@end
