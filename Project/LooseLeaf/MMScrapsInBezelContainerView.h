//
//  MMScapBubbleContainerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/31/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMSlidingSidebarContainerView.h"
#import "MMUntouchableView.h"
#import "MMScrapView.h"
#import "MMScrapSidebarContainerViewDelegate.h"
#import "MMScrapsOnPaperStateDelegate.h"
#import "MMCountBubbleButton.h"
#import "MMScrapsInSidebarStateDelegate.h"
#import "MMSidebarButtonDelegate.h"

@interface MMScrapsInBezelContainerView : MMSlidingSidebarContainerView<MMScrapsInSidebarStateDelegate,MMSidebarButtonDelegate>{
    __weak NSObject<MMScrapSidebarContainerViewDelegate>* bubbleDelegate;
}

@property (nonatomic, weak) NSObject<MMScrapSidebarContainerViewDelegate>* bubbleDelegate;
@property (nonatomic, strong) MMCountBubbleButton* countButton;
@property (readonly) NSArray* scrapsInSidebar;
@property (readonly) MMScrapsInSidebarState* scrapState;

-(id) initWithFrame:(CGRect)frame andCountButton:(MMCountBubbleButton *)countButton;

-(void) addScrapToBezelSidebar:(MMScrapView *)scrap animated:(BOOL)animated;

-(BOOL) containsScrap:(MMScrapView*)scrap;

-(BOOL) containsScrapUUID:(NSString*)scrapUUID;

-(void) didUpdateAccelerometerWithReading:(MMVector *)currentRawReading;

-(void) saveScrapContainerToDisk;

-(void) didTapOnScrapFromMenu:(MMScrapView*)scrap;

-(void) didTapOnScrapFromMenu:(MMScrapView*)scrap withPreferredScrapProperties:(NSDictionary*)properties;

-(void) loadFromDisk;

@end
