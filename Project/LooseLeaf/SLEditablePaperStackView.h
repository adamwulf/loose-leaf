//
//  SLEditablePaperStackView.h
//  Loose Leaf
//
//  Created by Adam Wulf on 6/22/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLListPaperStackView.h"
#import "MSPaperButton.h"
#import "MSPlusButton.h"
#import "MSPolylineButton.h"
#import "MSPolygonButton.h"
#import "MSImageButton.h"
#import "MSTextButton.h"
#import "MSPencilButton.h"
#import "MSShareButton.h"
#import "MSMapButton.h"
#import "MSSidebarButtonDelegate.h"
#import "NSThread+BlockAdditions.h"
#import "MSRotationManager.h"
#import "MSRotationManagerDelegate.h"
#import "Constants.h"


@interface SLEditablePaperStackView : SLListPaperStackView<UIAccelerometerDelegate,MSSidebarButtonDelegate,MSRotationManagerDelegate>{
    // toolbar
    MSPaperButton* documentBackgroundSidebarButton;
    MSPlusButton* addPageSidebarButton;
    MSPolylineButton* polylineButton;
    MSPolygonButton* polygonButton;
    MSImageButton* insertImageButton;
    MSTextButton* textButton;
    MSPencilButton* pencilButton;
    MSShareButton* shareButton;
    MSMapButton* mapButton;
    
    MSTextButton* undoButton;
    MSTextButton* redoButton;
}

@end
