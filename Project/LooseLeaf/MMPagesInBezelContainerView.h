//
//  MMPagesInBezelContainerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 9/27/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
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


@interface MMPagesInBezelContainerView : MMCountableSidebarContainerView <MMEditablePaperView*>
<MMScrapsInSidebarStateDelegate, MMSidebarButtonDelegate> {
    __weak NSObject<MMScrapSidebarContainerViewDelegate>* bubbleDelegate;
}

@property (nonatomic, weak) NSObject<MMScrapSidebarContainerViewDelegate>* bubbleDelegate;
@property (nonatomic, strong) MMCountBubbleButton* countButton;
@property (readonly) MMScrapsInSidebarState* sidebarScrapState;

- (id)initWithFrame:(CGRect)frame andCountButton:(MMCountBubbleButton*)countButton;

- (void)addScrapToBezelSidebar:(MMScrapView*)scrap animated:(BOOL)animated;

- (BOOL)containsView:(MMScrapView*)scrap;

- (BOOL)containsViewUUID:(NSString*)scrapUUID;

- (void)didUpdateAccelerometerWithReading:(MMVector*)currentRawReading;

- (void)saveScrapContainerToDisk;

- (void)didTapOnViewFromMenu:(MMScrapView*)scrap withPreferredProperties:(NSDictionary*)properties;

- (void)loadFromDisk;

- (void)didRotateToIdealOrientation:(UIInterfaceOrientation)orientation;


@end
