//
//  MMScapBubbleContainerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/31/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMCountableSidebarContainerView.h"
#import "MMUntouchableView.h"
#import "MMScrapView.h"
#import "MMScrapSidebarContainerViewDelegate.h"
#import "MMScrapsOnPaperStateDelegate.h"
#import "MMCountBubbleButton.h"
#import "MMScrapsInSidebarStateDelegate.h"
#import "MMSidebarButtonDelegate.h"
#import "MMScrapsInSidebarState.h"


@interface MMScrapsInBezelContainerView : MMCountableSidebarContainerView <MMScrapView*>
<MMScrapsInSidebarStateDelegate> {
    __weak NSObject<MMScrapSidebarContainerViewDelegate>* bubbleDelegate;
}

@property (nonatomic, weak) NSObject<MMScrapSidebarContainerViewDelegate>* bubbleDelegate;
@property (readonly) MMScrapsInSidebarState* sidebarScrapState;

// scrap specific

- (void)saveScrapContainerToDisk;

- (void)loadFromDisk;

- (void)didUpdateAccelerometerWithReading:(MMVector*)currentRawReading;

- (void)didRotateToIdealOrientation:(UIInterfaceOrientation)orientation;

// only for undo/redo

- (void)didTapOnScrapFromMenu:(MMScrapView*)scrap withPreferredScrapProperties:(NSDictionary*)properties below:(BOOL)below;

@end
