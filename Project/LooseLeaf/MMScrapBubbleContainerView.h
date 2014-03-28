//
//  MMScapBubbleContainerView.h
//  LooseLeaf
//
//  Created by Adam Wulf on 8/31/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMSlidingSidebarView.h"
#import "MMScrapContainerView.h"
#import "MMScrapView.h"
#import "MMScapBubbleContainerViewDelegate.h"
#import "MMScrapBezelMenuViewDelegate.h"
#import "MMScrapsOnPaperStateDelegate.h"
#import "MMCountBubbleButton.h"

@interface MMScrapBubbleContainerView : MMSlidingSidebarView<MMScrapBezelMenuViewDelegate,MMScrapsOnPaperStateDelegate>{
    __weak NSObject<MMScapBubbleContainerViewDelegate>* bubbleDelegate;
}

@property (nonatomic, weak) NSObject<MMScapBubbleContainerViewDelegate>* bubbleDelegate;
@property (nonatomic, strong) MMCountBubbleButton* countButton;

-(id) initWithFrame:(CGRect)frame andCountButton:(MMCountBubbleButton *)countButton;

-(void) addScrapToBezelSidebar:(MMScrapView *)scrap animated:(BOOL)animated;

-(void) didUpdateAccelerometerWithRawReading:(CGFloat)currentRawReading andX:(CGFloat)xAccel andY:(CGFloat)yAccel andZ:(CGFloat)zAccel;

-(void) animateAndAddScrapBackToPage:(MMScrapView*)scrap;

-(void) saveToDisk;

@end
