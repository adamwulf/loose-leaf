//
//  MMScrapPaperStackView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/29/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMEditablePaperStackView.h"
#import "MMScrapSidebarContainerViewDelegate.h"
#import "MMStretchScrapGestureRecognizerDelegate.h"
#import "MMImageSidebarContainerViewDelegate.h"
#import "MMShareItemDelegate.h"
#import "MMExportablePaperView.h"
#import "MMScrapViewOwnershipDelegate.h"
#import "MMCloudKitImportExportView.h"

@interface MMScrapPaperStackView : MMEditablePaperStackView<MMScrapViewOwnershipDelegate,MMPanAndPinchScrapGestureRecognizerDelegate,MMScrapSidebarContainerViewDelegate,MMStretchScrapGestureRecognizerDelegate,MMImageSidebarContainerViewDelegate,MMShareItemDelegate,MMInboxManagerDelegate>{
}

-(void) willResignActive;

-(void) didEnterBackground;

@end
