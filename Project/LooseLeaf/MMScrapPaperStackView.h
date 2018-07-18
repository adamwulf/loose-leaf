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
#import "MMShadowHandView.h"


@interface MMScrapPaperStackView : MMEditablePaperStackView <MMScrapViewOwnershipDelegate, MMPanAndPinchScrapGestureRecognizerDelegate, MMScrapSidebarContainerViewDelegate, MMStretchScrapGestureRecognizerDelegate, MMImageSidebarContainerViewDelegate, MMShareSidebarDelegate, MMInboxManagerDelegate> {
    __weak MMShadowHandView* silhouette;
}

@property (nonatomic, weak) MMShadowHandView* silhouette;

- (void)willResignActive;

- (void)didEnterBackground;

- (void)importImageAsNewPage:(UIImage*)imageToImport withAssetURL:(NSURL*)assetURL fromContainer:(NSString*)containerDescription referringApp:(NSString*)sourceApplication onComplete:(void (^)(MMExportablePaperView*))completionBlock;


- (void)deletingInboxItemGesture:(NSNotification*)note;
- (void)deleteInboxItemTapped:(NSNotification*)note;
- (void)deleteInboxItemTappedDown:(NSNotification*)note;

@end
