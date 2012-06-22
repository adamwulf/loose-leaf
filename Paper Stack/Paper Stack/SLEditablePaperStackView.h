//
//  SLEditablePaperStackView.h
//  scratchpaper
//
//  Created by Adam Wulf on 6/22/12.
//  Copyright (c) 2012 Visere. All rights reserved.
//

#import "SLPaperStackView.h"
#import "SLPaperButton.h"
#import "SLPlusButton.h"
#import "SLPolylineButton.h"
#import "SLPolygonButton.h"
#import "SLImageButton.h"
#import "SLTextButton.h"
#import "SLPencilButton.h"
#import "SLShareButton.h"
#import "SLSidebarButtonDelegate.h"
#import <CoreMotion/CoreMotion.h>
#import "NSThread+BlocksAdditions.h"
#import "Constants.h"

@interface SLEditablePaperStackView : SLPaperStackView<UIAccelerometerDelegate,SLSidebarButtonDelegate>{
    // rotation
    BOOL isFirstReading;
    CGFloat accelerationX;
    CGFloat accelerationY;
    CGFloat currentRawReading;
    
    // toolbar
    SLPaperButton* documentBackgroundSidebarButton;
    SLPlusButton* addPageSidebarButton;
    SLPolylineButton* polylineButton;
    SLPolygonButton* polygonButton;
    SLImageButton* insertImageButton;
    SLTextButton* textButton;
    SLPencilButton* pencilButton;
    SLShareButton* shareButton;
    
    
}

@end
