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
#import "MMPencilButton.h"
#import "MMPencilEraserButton.h"
#import "MMShareButton.h"
#import "MMMapButton.h"
#import "MMRulerButton.h"
#import "MMHandButton.h"
#import "MMSidebarButtonDelegate.h"
#import "NSThread+BlockAdditions.h"
#import "MMRotationManager.h"
#import "MMRotationManagerDelegate.h"
#import "MMStackManager.h"
#import "Constants.h"
#import "Pen.h"
#import "Eraser.h"

/**
 * this class is responsible for the editable buttons and controls that show
 * outside of a page's view subviews
 */
@interface MMEditablePaperStackView : MMListPaperStackView<JotViewDelegate,MMSidebarButtonDelegate,MMRotationManagerDelegate>{
    
    // managers
    MMStackManager* stackManager;
    
    // toolbar
    MMPaperButton* documentBackgroundSidebarButton;
    MMPlusButton* addPageSidebarButton;
    MMPolylineButton* polylineButton;
    MMPolygonButton* polygonButton;
    MMImageButton* insertImageButton;
    MMTextButton* scissorButton;
    MMTextButton* textButton;
    MMPencilButton* pencilButton;
    MMPencilEraserButton* eraserButton;
    MMShareButton* shareButton;
    MMMapButton* mapButton;
    
    MMUndoRedoButton* undoButton;
    MMUndoRedoButton* redoButton;

    MMRulerButton* rulerButton;
    MMHandButton* handButton;

    Pen* pen;
    Eraser* eraser;
}

-(void) saveStacksToDisk;

-(void) loadStacksFromDisk;

-(BOOL) hasPages;

@end
