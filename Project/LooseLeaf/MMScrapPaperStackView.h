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
#import "MMInboxManagerDelegate.h"
#import "MMShareItemDelegate.h"
#import "MMCloudKitManagerDelegate.h"
#import "MMExportablePaperView.h"

@interface MMScrapPaperStackView : MMEditablePaperStackView<MMPanAndPinchScrapGestureRecognizerDelegate,MMScrapSidebarContainerViewDelegate,MMStretchScrapGestureRecognizerDelegate,MMImageSidebarContainerViewDelegate,MMInboxManagerDelegate,MMShareItemDelegate,MMCloudKitManagerDelegate>

-(void) importAndShowPage:(MMExportablePaperView*)page;

-(void) debug_forceScissorCut;

@end
