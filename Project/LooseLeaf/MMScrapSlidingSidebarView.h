//
//  MMScapBubbleContainerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/31/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMSlidingSidebarView.h"
#import "MMUntouchableView.h"
#import "MMScrapView.h"
#import "MMScrapSlidingSidebarViewDelegate.h"
#import "MMScrapSidebarContentViewDelegate.h"
#import "MMScrapsOnPaperStateDelegate.h"
#import "MMCountBubbleButton.h"

@interface MMScrapSlidingSidebarView : MMSlidingSidebarView<MMScrapSidebarContentViewDelegate,MMScrapsOnPaperStateDelegate>{
    __weak NSObject<MMScrapSlidingSidebarViewDelegate>* bubbleDelegate;
}

@property (nonatomic, weak) NSObject<MMScrapSlidingSidebarViewDelegate>* bubbleDelegate;
@property (nonatomic, strong) MMCountBubbleButton* countButton;

-(id) initWithFrame:(CGRect)frame andCountButton:(MMCountBubbleButton *)countButton;

-(void) addScrapToBezelSidebar:(MMScrapView *)scrap animated:(BOOL)animated;

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading andX:(CGFloat)xAccel andY:(CGFloat)yAccel andZ:(CGFloat)zAccel;

-(void) animateAndAddScrapBackToPage:(MMScrapView*)scrap;

-(void) saveToDisk;

@end
