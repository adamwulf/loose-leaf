//
//  SLPaperStackView.h
//  Paper Stack
//
//  Created by Adam Wulf on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import <UIKit/UIKit.h>
#import "SLPaperView.h"
#import "NSMutableArray+StackAdditions.h"
#import "SLPaperIcon.h"
#import "SLPapersIcon.h"
#import "SLPlusIcon.h"
#import "SLLeftArrow.h"
#import "SLRightArrow.h"
#import "SLPaperButton.h"
#import "SLPlusButton.h"
#import "SLPolylineButton.h"
#import "SLPolygonButton.h"
#import "SLImageButton.h"
#import "SLTextButton.h"
#import "SLSidebarButtonDelegate.h"
#import "SLBezelInGestureRecognizer.h"

@interface SLPaperStackView : UIView<SLPaperViewDelegate,UIAccelerometerDelegate,SLSidebarButtonDelegate>{
    UIView* visibleStackHolder;
    UIView* hiddenStackHolder;
    SLPapersIcon* papersIcon;
    SLPaperIcon* paperIcon;
    SLPlusIcon* plusIcon;
    SLLeftArrow* leftArrow;
    SLRightArrow* rightArrow;
    
    SLPaperButton* documentBackgroundSidebarButton;
    SLPlusButton* addPageSidebarButton;
    SLPolylineButton* polylineButton;
    SLPolygonButton* polygonButton;
    SLImageButton* insertImageButton;
    SLTextButton* textButton;
    
    SLBezelInGestureRecognizer* fromRightBezelGesture;
    NSMutableSet* setOfPagesBeingPanned;
    
    BOOL isFirstReading;
    CGFloat accelerationX;
    CGFloat accelerationY;
    CGFloat currentRawReading;
    
    SLPaperView* inProgressOfBezeling;
}

@property (nonatomic, readonly) UIView* stackHolder;


-(void) addPaperToBottomOfStack:(SLPaperView*)page;

@end
