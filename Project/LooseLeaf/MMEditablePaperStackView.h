//
//  MMEditablePaperStackView.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/22/12.
//  Copyright (c) 2012 Milestone Made, LLC. All rights reserved.
//

#import "MMListPaperStackView.h"
#import "MMPaperButton.h"
#import "MMPlusButton.h"
#import "MMPolylineButton.h"
#import "MMPolygonButton.h"
#import "MMImageButton.h"
#import "MMTextButton.h"
#import "MMPencilButton.h"
#import "MMShareButton.h"
#import "MMMapButton.h"
#import "MMSidebarButtonDelegate.h"
#import "NSThread+BlockAdditions.h"
#import "MMRotationManager.h"
#import "MMRotationManagerDelegate.h"
#import "Constants.h"

/**
 * this class is responsible for the editable buttons and controls that show
 * outside of a page's view subviews
 */
@interface MMEditablePaperStackView : MMListPaperStackView<UIAccelerometerDelegate,MMSidebarButtonDelegate,MMRotationManagerDelegate>{
    // toolbar
    MMPaperButton* documentBackgroundSidebarButton;
    MMPlusButton* addPageSidebarButton;
    MMPolylineButton* polylineButton;
    MMPolygonButton* polygonButton;
    MMImageButton* insertImageButton;
    MMTextButton* textButton;
    MMPencilButton* pencilButton;
    MMShareButton* shareButton;
    MMMapButton* mapButton;
    
    MMTextButton* undoButton;
    MMTextButton* redoButton;
}

@end
